#!/bin/bash
set -eux
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

NAMESPACE=${NAMESPACE:-fluent-bit-logging}

# Make sure to do this first
/bin/bash "$SCRIPT_DIR/../cluster-log-access/service-account-creation.sh"

echo "Setting up Fluent Bit to Grafana Cloud from helm chart in $NAMESPACE"

# Add both with and without slashes as considered different
helm repo add fluent https://fluent.github.io/helm-charts || helm repo add fluent https://fluent.github.io/helm-charts/

# Set up the appropriate variables and substitute them
envsubst '$GRAFANA_CLOUD_USERNAME,$GRAFANA_CLOUD_APIKEY,$GRAFANA_CLOUD_PROM_URL,$GRAFANA_CLOUD_LOKI_URL' < "$SCRIPT_DIR/values-grafana-cloud.yaml" > "$SCRIPT_DIR/values-grafana-cloud-actual.yaml"

helm upgrade --install fluent-bit fluent/fluent-bit \
    --namespace "$NAMESPACE" \
    --values "$SCRIPT_DIR/../cluster-log-access/values.yaml" \
    --values "$SCRIPT_DIR/values-grafana-cloud-actual.yaml" \
    --debug --wait
