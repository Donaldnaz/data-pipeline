#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$(dirname "$SCRIPT_DIR")"
# shellcheck source=lib/aws-env.sh
source "$SCRIPT_DIR/lib/aws-env.sh"

TFVARS="${TFVARS:-environments/dev.tfvars}"
if [ ! -f "$DEMO_DIR/$TFVARS" ]; then
  echo "ERROR: $TFVARS not found."
  echo "Copy environments/dev.tfvars.example to environments/dev.tfvars and set quicksight_username."
  exit 1
fi

resolve_aws_credentials "$DEMO_DIR"

AWS=$(command -v aws || true)
if [ -z "$AWS" ] || ! verify_aws_credentials "$AWS" "$DEMO_DIR"; then
  exit 1
fi

echo "========================================="
echo " Iran War Oil Shock 2026 - Cleanup"
echo " Using: $TFVARS"
echo "========================================="
echo ""

cd "$DEMO_DIR"

terraform init -input=false
terraform destroy -auto-approve -input=false -var-file="$TFVARS"

echo ""
echo "========================================="
echo " All demo resources deleted. Account clean."
echo "========================================="
