#!/bin/bash
set -eux
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [[ -f "$SCRIPT_DIR/.env" ]]; then
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/.env"
fi
NAMESPACE=${NAMESPACE:-fluent-bit-logging}
ELASTIC_CLOUD_ID=${ELASTIC_CLOUD_ID:?}
ELASTIC_CLOUD_AUTH=${ELASTIC_CLOUD_AUTH:?}

# Make sure to do this first
/bin/bash "$SCRIPT_DIR/../cluster-log-access/service-account-creation.sh"

echo "Setting up Fluent Bit to Elastic Cloud from helm chart in $NAMESPACE"

# Add both with and without slashes as considered different
helm repo add fluent https://fluent.github.io/helm-charts || helm repo add fluent https://fluent.github.io/helm-charts/

# Set up the appropriate variables and substitute them
# shellcheck disable=SC2016
envsubst '$ELASTIC_CLOUD_AUTH,$ELASTIC_CLOUD_ID' < "$SCRIPT_DIR/values-elastic-cloud.yaml" > "$SCRIPT_DIR/values-elastic-cloud-actual.yaml"

helm upgrade --install fluent-bit fluent/fluent-bit \
    --namespace "$NAMESPACE" \
    --values "$SCRIPT_DIR/../cluster-log-access/values.yaml" \
    --values "$SCRIPT_DIR/../cluster-metrics-access/values.yaml" \
    --values "$SCRIPT_DIR/values-elastic-cloud-actual.yaml" \
    --debug --wait "$@"
