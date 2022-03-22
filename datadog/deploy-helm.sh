#!/bin/bash
set -eux
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export NAMESPACE=${NAMESPACE:-fluent-bit-logging-datadog}
DATADOG_SERVICE=${DATADOG_SERVICE:-'openshift-cluster'}
DATADOG_SOURCE=${DATADOG_SOURCE:-'openshift-helm'}
DATADOG_TAGS=${DATADOG_TAGS:-'team:logs'}

# Make sure to do this first
/bin/bash "$SCRIPT_DIR/../cluster-log-access/service-account-creation.sh"

echo "Setting up Fluent Bit to Datadog from helm chart in $NAMESPACE"

# Add both with and without slashes as considered different
helm repo add fluent https://fluent.github.io/helm-charts || helm repo add fluent https://fluent.github.io/helm-charts/

# Set up the appropriate variables and substitute them
if [[ -f "$SCRIPT_DIR/.env" ]]; then
    # shellcheck disable=SC1091
    source "$SCRIPT_DIR/.env"
fi

# shellcheck disable=SC2016
envsubst '$DATADOG_API_KEY,$DATADOG_SERVICE,$DATADOG_SITE,$DATADOG_SOURCE,$DATADOG_TAGS' < "$SCRIPT_DIR/values-datadog.yaml" > "$SCRIPT_DIR/values-datadog-actual.yaml"

helm upgrade --install fluent-bit fluent/fluent-bit \
    --namespace "$NAMESPACE" \
    --values "$SCRIPT_DIR/../cluster-log-access/values.yaml" \
    --values "$SCRIPT_DIR/../cluster-metrics-access/values.yaml" \
    --values "$SCRIPT_DIR/values-datadog-actual.yaml" \
    --debug --wait "$@"
