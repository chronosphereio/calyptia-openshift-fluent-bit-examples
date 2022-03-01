#!/bin/bash
set -eux
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

NAMESPACE=${NAMESPACE:-fluent-bit-logging}

/bin/bash "$SCRIPT_DIR/service-account-creation.sh"

echo "Setting up Fluent Bit from helm chart in $NAMESPACE"

helm repo add fluent https://fluent.github.io/helm-charts || helm repo add fluent https://fluent.github.io/helm-charts/

helm upgrade --install fluent-bit fluent/fluent-bit --namespace "$NAMESPACE" -f "$SCRIPT_DIR/values.yaml"
