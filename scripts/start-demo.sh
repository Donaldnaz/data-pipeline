#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$(dirname "$SCRIPT_DIR")"
# shellcheck source=lib/aws-env.sh
source "$SCRIPT_DIR/lib/aws-env.sh"

TFVARS="${TFVARS:-environments/dev.tfvars}"
TFVARS_PATH="$DEMO_DIR/$TFVARS"

# ------------------------------------------------------------------------------
# Preflight checks
# ------------------------------------------------------------------------------

if [ ! -f "$TFVARS_PATH" ]; then
  echo "ERROR: $TFVARS not found."
  echo "Run: cp environments/dev.tfvars.example environments/dev.tfvars"
  echo "Then set quicksight_username in dev.tfvars."
  exit 1
fi

resolve_aws_credentials "$DEMO_DIR"

if ! command -v terraform >/dev/null 2>&1; then
  echo "ERROR: terraform not found in PATH"
  exit 1
fi

AWS=$(command -v aws)
if [ -z "$AWS" ]; then
  echo "ERROR: aws CLI not found in PATH"
  exit 1
fi

KAGGLE_DIR="$DEMO_DIR/kaggleData"
for csv in \
  iran_war_oil_prices_daily_2026.csv \
  iran_war_gas_prices_by_state.csv \
  iran_war_key_events_timeline.csv; do
  if [ ! -f "$KAGGLE_DIR/$csv" ]; then
    echo "ERROR: Missing dataset file: $KAGGLE_DIR/$csv"
    exit 1
  fi
done

echo "Checking AWS credentials..."
verify_aws_credentials "$AWS" "$DEMO_DIR" || exit 1

QS_USER=$(get_tfvar "$TFVARS_PATH" "quicksight_username")
AWS_REGION_CFG=$(get_tfvar "$TFVARS_PATH" "aws_region")
echo "Checking QuickSight username..."
verify_quicksight_username "$AWS" "$ACCOUNT_ID" "${AWS_REGION_CFG:-us-east-1}" "$QS_USER" "$TFVARS" || exit 1

# ------------------------------------------------------------------------------
# Demo run
# ------------------------------------------------------------------------------

echo ""
echo "========================================="
echo " Iran War Oil Shock 2026 - Full Demo"
echo " Using: $TFVARS"
echo "========================================="
echo ""

cd "$DEMO_DIR"

echo "-----------------------------------------"
echo " Step 1: Deploy infrastructure"
echo "-----------------------------------------"
terraform init -input=false
terraform apply -auto-approve -input=false -var-file="$TFVARS"
echo ""

ENVIRONMENT=$(terraform output -raw environment)
AWS_REGION=$(terraform output -raw aws_region)
CRAWLER=$(terraform output -raw glue_crawler_name)
WORKGROUP=$(terraform output -raw athena_workgroup)
GLUE_DB=$(terraform output -raw glue_database)
ATHENA_URL=$(terraform output -raw athena_console_url)
DASHBOARD_URL=$(terraform output -raw quicksight_dashboard_url)
ANALYSIS_URL=$(terraform output -raw quicksight_analysis_url)
PROJECT_NAME="${CRAWLER%-crawler}"

echo "  Environment:  $ENVIRONMENT"
echo "  Project:        $PROJECT_NAME"
echo "  Region:         $AWS_REGION"
echo ""

echo "-----------------------------------------"
echo " Step 2: Start Glue Crawler"
echo "         (CSVs uploaded by Terraform)"
echo "-----------------------------------------"

CRAWLER_STATE=$("$AWS" glue get-crawler --name "$CRAWLER" --region "$AWS_REGION" \
  --query "Crawler.State" --output text 2>/dev/null || echo "UNKNOWN")

if [ "$CRAWLER_STATE" = "RUNNING" ]; then
  echo "  Crawler already running — waiting for it to finish..."
else
  echo "  Starting crawler: $CRAWLER"
  "$AWS" glue start-crawler --name "$CRAWLER" --region "$AWS_REGION"
  echo "  Waiting for crawler to start..."
  sleep 5
fi

echo "  Waiting for crawler to finish (catalogs all 3 tables)..."
while true; do
  STATE=$("$AWS" glue get-crawler --name "$CRAWLER" --region "$AWS_REGION" \
    --query "Crawler.State" --output text)
  LAST_CRAWL=$("$AWS" glue get-crawler --name "$CRAWLER" --region "$AWS_REGION" \
    --query "Crawler.LastCrawl.Status" --output text 2>/dev/null || echo "NONE")

  if [ "$STATE" = "READY" ] && { [ "$LAST_CRAWL" = "SUCCEEDED" ] || [ "$LAST_CRAWL" = "FAILED" ]; }; then
    if [ "$LAST_CRAWL" = "FAILED" ]; then
      REASON=$("$AWS" glue get-crawler --name "$CRAWLER" --region "$AWS_REGION" \
        --query "Crawler.LastCrawl.ErrorMessage" --output text)
      echo "  ERROR: Crawler failed — $REASON"
      exit 1
    fi
    echo "  Crawler finished — 3 tables registered in Glue Data Catalog."
    break
  fi

  echo "  Crawler state: $STATE (last crawl: $LAST_CRAWL) — waiting 10s..."
  sleep 10
done
echo ""

echo "-----------------------------------------"
echo " Step 3: Run sample Athena query"
echo "         (Regional gas price impact)"
echo "-----------------------------------------"

QUERY="SELECT region, COUNT(*) AS states, ROUND(AVG(gas_price_mar19_2026),3) AS avg_current_price, ROUND(AVG(gas_price_prewar_feb27),3) AS avg_prewar_price, ROUND(AVG(price_increase_since_war),3) AS avg_dollar_increase, ROUND(AVG(pct_increase_since_war),1) AS avg_pct_increase FROM iran_war_gas_prices_by_state GROUP BY region ORDER BY avg_current_price DESC;"

QUERY_EXEC=$("$AWS" athena start-query-execution \
  --query-string "$QUERY" \
  --work-group "$WORKGROUP" \
  --region "$AWS_REGION" \
  --query-execution-context "{\"Database\":\"${GLUE_DB}\"}" \
  --query "QueryExecutionId" --output text)

echo "  Execution ID: $QUERY_EXEC"
echo "  Waiting for results..."

while true; do
  QSTATUS=$("$AWS" athena get-query-execution \
    --query-execution-id "$QUERY_EXEC" \
    --region "$AWS_REGION" \
    --query "QueryExecution.Status.State" --output text)
  if [ "$QSTATUS" = "SUCCEEDED" ]; then break; fi
  if [ "$QSTATUS" = "FAILED" ] || [ "$QSTATUS" = "CANCELED" ]; then
    echo "  ERROR: Query ended with status $QSTATUS"
    "$AWS" athena get-query-execution \
      --query-execution-id "$QUERY_EXEC" \
      --region "$AWS_REGION" \
      --query "QueryExecution.Status.StateChangeReason" --output text
    exit 1
  fi
  echo "  Query state: $QSTATUS — waiting 5s..."
  sleep 5
done

echo ""
echo "  Gas Price Impact by US Region (war day 20 vs pre-war):"
echo ""
"$AWS" athena get-query-results \
  --query-execution-id "$QUERY_EXEC" \
  --region "$AWS_REGION" \
  --query "ResultSet.Rows[*].Data[*].VarCharValue" \
  --output table
echo ""

echo "-----------------------------------------"
echo " Step 4: Trigger QuickSight SPICE Ingestion"
echo "-----------------------------------------"

for DS_SUFFIX in oil-prices gas-prices key-events; do
  DS_ID="${PROJECT_NAME}-${DS_SUFFIX}"
  INGESTION_ID="ingest-$(date +%s)-${DS_SUFFIX}"
  echo "  Triggering ingestion for dataset: ${DS_ID}"
  if "$AWS" quicksight create-ingestion \
    --aws-account-id "$ACCOUNT_ID" \
    --data-set-id "$DS_ID" \
    --ingestion-id "$INGESTION_ID" \
    --region "$AWS_REGION" >/dev/null 2>&1; then
    echo "    Ingestion started: $INGESTION_ID"
  else
    echo "    Warning: Failed to trigger ingestion for ${DS_ID}"
  fi
done

echo ""
echo "========================================="
echo " Demo Complete!"
echo "========================================="
echo ""
echo "  Environment: $ENVIRONMENT"
echo "  Project:     $PROJECT_NAME"
echo ""
echo "  Tables in Athena (database: ${GLUE_DB}):"
echo "    iran_war_oil_prices_daily_2026  — daily Brent/WTI/Dubai + Hormuz traffic"
echo "    iran_war_gas_prices_by_state    — pump prices for all 50 states"
echo "    iran_war_key_events_timeline    — 11 key war events with Brent price"
echo ""
echo "  6 pre-built named queries in workgroup: ${WORKGROUP}"
echo "    01-brent-daily-trend"
echo "    02-us-gas-price-impact"
echo "    03-gas-price-by-state"
echo "    04-regional-gas-summary"
echo "    05-key-events-price-correlation"
echo "    06-hormuz-closure-impact"
echo ""
echo "  Athena console:"
echo "  $ATHENA_URL"
echo ""
echo "  QuickSight Dashboard:"
echo "  $DASHBOARD_URL"
echo ""
echo "  QuickSight Analysis:"
echo "  $ANALYSIS_URL"
echo ""
