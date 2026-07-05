# Source from demo scripts: resolve AWS credentials for Terraform and AWS CLI.
#
# Priority:
#   1. Demo-local .aws/credentials (if present)
#   2. Default AWS credential chain (~/.aws/credentials, env vars, SSO, etc.)

resolve_aws_credentials() {
  local demo_dir="$1"

  if [ -f "$demo_dir/.aws/credentials" ]; then
    export AWS_SHARED_CREDENTIALS_FILE="$demo_dir/.aws/credentials"
    echo "Using AWS credentials: $demo_dir/.aws/credentials"
    return 0
  fi

  unset AWS_SHARED_CREDENTIALS_FILE
  echo "Using default AWS credentials (~/.aws/credentials or environment)"
}

verify_aws_credentials() {
  local aws_cli="$1"

  if ! ACCOUNT_ID=$("$aws_cli" sts get-caller-identity --query Account --output text 2>/dev/null); then
    echo "ERROR: No valid AWS credentials found."
    echo ""
    echo "Either:"
    echo "  1. Create $2/.aws/credentials with a [default] profile, or"
    echo "  2. Run: aws configure"
    echo "  3. Or export AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY"
    return 1
  fi

  echo "  AWS account: $ACCOUNT_ID"
  return 0
}

get_tfvar() {
  local file="$1"
  local key="$2"
  grep -E "^[[:space:]]*${key}[[:space:]]*=" "$file" | head -1 \
    | sed -E 's/^[[:space:]]*[^=]+=[[:space:]]*"([^"]+)".*/\1/'
}

verify_quicksight_username() {
  local aws_cli="$1"
  local account_id="$2"
  local region="$3"
  local username="$4"
  local tfvars_label="$5"

  local users
  if ! users=$("$aws_cli" quicksight list-users \
    --aws-account-id "$account_id" \
    --namespace default \
    --region "$region" \
    --query "UserList[].UserName" \
    --output text 2>/dev/null); then
    echo "WARNING: Could not list QuickSight users — skipping username check"
    return 0
  fi

  for u in $users; do
    if [ "$u" = "$username" ]; then
      echo "  QuickSight user: $username"
      return 0
    fi
  done

  echo "ERROR: quicksight_username '$username' is not a valid QuickSight user."
  echo ""
  echo "Valid users in account $account_id:"
  for u in $users; do
    echo "  - $u"
  done
  echo ""
  echo "Update quicksight_username in $tfvars_label (QuickSight profile icon → username)."
  return 1
}
