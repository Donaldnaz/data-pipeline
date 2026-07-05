# Iran War Oil Shock 2026 — S3 → Glue → Athena → QuickSight Demo

A beginner-friendly demo that provisions a complete serverless analytics pipeline on AWS using Terraform — one command to deploy everything, one command to destroy it all.

**Dataset:** [Iran War Oil Shock 2026 | Brent & Gas Tracker](https://www.kaggle.com/datasets/alitaqishah/iran-war-oil-shock-2026-brent-and-gas-tracker)

## Architecture

```
kaggleData/ (3 CSV files — direct S3 upload)
        │
        ▼
   Amazon S3
   ├── iran_war_oil_prices_daily_2026/iran_war_oil_prices_daily_2026.csv
   ├── iran_war_gas_prices_by_state/iran_war_gas_prices_by_state.csv
   └── iran_war_key_events_timeline/iran_war_key_events_timeline.csv
        │
        ▼
  AWS Glue Crawler  ──►  Glue Data Catalog
  (single crawler,        ├── iran_war_oil_prices_daily_2026
   3 S3 targets)          ├── iran_war_gas_prices_by_state
                          └── iran_war_key_events_timeline
        │
        ▼
  AWS Glue ETL Job (optional)
  CSV → Parquet (partitioned by phase / region / category)
        │
        ▼
  Amazon Athena  (6 pre-built named queries)
        │
        ▼
  Amazon QuickSight
  (line chart, choropleth map, KPI cards, event annotations)
```

## Dataset Schema

### `iran_war_oil_prices_daily_2026` (23 rows)
| Column | Description |
|---|---|
| `date` | Trading date |
| `brent_usd_barrel` | Brent crude price (USD/barrel) |
| `wti_usd_barrel` | WTI crude price |
| `dubai_usd_barrel` | Dubai crude price |
| `us_gas_avg_gallon` | US national average retail gas price |
| `us_diesel_avg_gallon` | US national average diesel price |
| `strait_hormuz_daily_ships` | Ship transits through Strait of Hormuz |
| `iran_production_mbpd` | Iran oil production (million barrels/day) |
| `brent_vs_prewar_pct` | % change vs Feb 27 pre-war baseline |
| `gas_vs_prewar_pct` | % gas price change vs pre-war |
| `gas_change_from_prewar_dollars` | Dollar increase from pre-war |
| `phase` | War phase label |
| `war_day` | Day number since war started (Feb 28) |
| `key_event` | Key event description for that day |

### `iran_war_gas_prices_by_state` (50 rows — all US states)
| Column | Description |
|---|---|
| `state` | US state name |
| `region` | West / Midwest / Northeast / South |
| `gas_price_jan08_2026` | Price before tensions escalated |
| `gas_price_prewar_feb27` | Price day before war |
| `gas_price_mar19_2026` | Price on war day 20 |
| `price_increase_since_war` | Dollar increase since war |
| `pct_increase_since_war` | % increase since war |
| `price_vs_national_avg` | Deviation from national average |

### `iran_war_key_events_timeline` (11 rows)
| Column | Description |
|---|---|
| `date` | Event date |
| `event_title` | Short event name |
| `description` | Full event description |
| `war_day` | Day number since war started |
| `category` | Conflict Start / Energy Infrastructure / Policy Response / Price Record / Military Escalation |
| `brent_price_that_day` | Brent price on that day |

## What Gets Created

| Resource | Purpose |
|---|---|
| **S3** (raw-data) | Stores all 3 CSV files under separate prefixes |
| **S3** (athena-results) | Stores Athena query output |
| **S3** (glue-scripts) | Hosts the PySpark ETL script |
| **Glue CSV Classifier** | Correctly parses headers and quoted fields |
| **Glue Crawler** (1) | Catalogs all 3 S3 prefixes → 3 tables |
| **Glue Database** | Logical namespace in Data Catalog |
| **Glue ETL Job** | Converts all 3 CSVs to Parquet (partitioned) |
| **Athena Workgroup** | Enforces result location + SSE encryption |
| **6 Athena Named Queries** | Pre-built oil shock analysis queries |
| **QuickSight IAM Role** | Grants QuickSight access to Athena + S3 |
| **QuickSight Data Source & Datasets** | Connects to Athena and prepares tables for visualization |
| **QuickSight Analysis & Dashboard** | Full pre-built visual dashboard with charts and KPIs |

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- AWS CLI installed
- AWS credentials placed in `.aws/credentials` in this demo directory
- The 3 Kaggle CSV files already present in `kaggleData/`
- Environment config copied and filled in:

```bash
cp environments/dev.tfvars.example environments/dev.tfvars
# Edit quicksight_username and tags in dev.tfvars
```

## Usage

### Deploy and run the full pipeline (one click)

```bash
./scripts/start-demo.sh
```

This will:
1. `terraform apply -var-file=environments/dev.tfvars` — create all AWS infrastructure and upload CSVs to S3
2. Start the Glue Crawler and wait for all 3 tables to be cataloged
3. Run the regional gas price summary query and print the results
4. Trigger QuickSight SPICE ingestion and print dashboard URLs

### Deploy infrastructure only

```bash
./scripts/deploy.sh
```

### Destroy everything (one click)

```bash
./scripts/cleanup-demo.sh
```

Removes all S3 buckets (including data), Glue resources, Athena workgroup, and IAM roles.

### Override environment config

Use a different tfvars file by setting `TFVARS`:

```bash
TFVARS=environments/staging.tfvars ./scripts/deploy.sh
```

Or run Terraform directly:

```bash
terraform plan -var-file=environments/dev.tfvars
terraform apply -var-file=environments/dev.tfvars
```

## Pre-built Athena Named Queries

After the crawler finishes, all 6 queries are available in the Athena console under the workgroup.

| Query Name | What it shows |
|---|---|
| `01-brent-daily-trend` | Daily Brent/WTI/Dubai prices + key events |
| `02-us-gas-price-impact` | National gas & diesel trend + Hormuz traffic |
| `03-gas-price-by-state` | All 50 states: pre-war → war day 20 prices |
| `04-regional-gas-summary` | Average % price increase by US region |
| `05-key-events-price-correlation` | War events joined with Brent price that day |
| `06-hormuz-closure-impact` | Brent price vs Hormuz ship count over time |

## QuickSight Dashboard Automatically Provisioned

The Terraform configuration **automatically deploys** a complete QuickSight dashboard with a custom dark energy theme (`MIDNIGHT` base). You do not need to build it manually.

**3 sheets, 11 visuals:**

| Sheet | Visuals |
|---|---|
| **Global Oil & Gas Prices** | Highest Brent Crude Price; Highest WTI Crude Price; Peak Brent Rise vs Feb 27; Highest National Gas Price; Global Crude Benchmarks Over Time; Brent Price & Hormuz Shipping Disruptions |
| **US Pump Prices by State** | Where Gas Prices Are Highest (Mar 19, 2026); States Ranked by Gas Price (Mar 19); Regional Average: Before War vs Mar 19 |
| **War Events vs Oil Prices** | War Events Plotted Against Brent Price; Event Timeline with Brent Price |

Price fields use `AVERAGE` aggregation (not `SUM` on daily rows). Currency and percent columns are formatted via `column_configurations`.

> **Important Setup Note:** While the dashboard is automatically created, QuickSight still requires manual permission configuration to read your AWS resources.
>
> Go to **Manage QuickSight** → **Security & permissions** → click **Manage** under QuickSight access to AWS services. Make sure **Athena** is checked, and for **Amazon S3**, check both the bucket starting with `<project_name>-raw-data` and `<project_name>-athena-results`.

## Change AWS Region

Edit `aws_region` in `environments/dev.tfvars`, then re-apply:

```bash
terraform apply -var-file=environments/dev.tfvars
```

## File Structure

```
s3-athena-quicksight-demo/
├── main.tf                 # Root orchestration (module calls + state migration)
├── versions.tf             # Terraform, AWS provider, default_tags
├── variables.tf            # All input variables (values set via tfvars)
├── outputs.tf              # Console URLs, bucket names, crawler command
├── environments/
│   ├── dev.tfvars.example  # Committed template — copy to dev.tfvars
│   └── dev.tfvars          # Local config (gitignored)
├── modules/
│   ├── s3/                 # Raw data, Athena results, and Glue scripts buckets
│   ├── iam/                # Glue and QuickSight IAM roles and policies
│   ├── glue/               # Data Catalog, crawler, and optional ETL job
│   ├── athena/             # Workgroup and 6 named queries
│   └── quicksight/         # Theme, data source, datasets, analysis, template, dashboard
├── .gitignore
├── .aws/
│   └── credentials                              # AWS credentials (never committed)
├── kaggleData/
│   ├── iran_war_oil_prices_daily_2026.csv       # Daily Brent/WTI/Dubai + Hormuz
│   ├── iran_war_gas_prices_by_state.csv         # Pump prices for all 50 states
│   └── iran_war_key_events_timeline.csv         # 11 war events with Brent price
└── scripts/
    ├── deploy.sh                                # Deploy infrastructure only
    ├── start-demo.sh                            # Full end-to-end pipeline
    └── cleanup-demo.sh                          # Destroy all resources
```
