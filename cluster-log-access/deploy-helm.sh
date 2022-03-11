#!/bin/bash
set -eux
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

NAMESPACE=${NAMESPACE:-fluent-bit-logging}

# Make sure to do this first
/bin/bash "$SCRIPT_DIR/service-account-creation.sh"

echo "Setting up Fluent Bit from helm chart in $NAMESPACE"

# Add both with and without slashes as considered different
helm repo add fluent https://fluent.github.io/helm-charts || helm repo add fluent https://fluent.github.io/helm-charts/

helm upgrade --install fluent-bit fluent/fluent-bit \
    --namespace "$NAMESPACE" \
    --values "$SCRIPT_DIR/values.yaml" \
    --values "$SCRIPT_DIR/values-null-output.yaml" \
    --debug --wait "$@"
