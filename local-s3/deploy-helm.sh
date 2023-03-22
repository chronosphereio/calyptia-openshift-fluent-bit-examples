#!/bin/bash
set -eux
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

NAMESPACE=${NAMESPACE:-fluent-bit-logging}

# Set this to $PWD/values-fluent-local-all.yaml for Loki + S3 logs all locally
VALUES_FILE=${VALUES_FILE:-$SCRIPT_DIR/values-fluent.yaml}

# Make sure to do this first for Openshift
/bin/bash "$SCRIPT_DIR/../cluster-log-access/service-account-creation.sh"

echo "Setting up Fluent Bit to local Minio from helm chart in $NAMESPACE"

# Add both with and without slashes as considered different
helm repo add fluent https://fluent.github.io/helm-charts || helm repo add fluent https://fluent.github.io/helm-charts/
helm repo add minio https://charts.min.io || helm repo add minio https://charts.min.io/
helm repo update

# Deploy Minio as S3 example
helm upgrade --install --create-namespace --namespace "$NAMESPACE" minio minio/minio \
    --values "$SCRIPT_DIR/values-minio.yaml" \
    --debug --wait "$@"

echo "Set up Minio so now set up buckets, etc. using login rootuser:rootpass123"
echo "To port forward Minio console 'kubectl port-forward --namespace $NAMESPACE svc/minio-console 9001'"

if [[ "${DEPLOY_LOKI_STACK:-no}" != "no" ]]; then 
    SKIP_FLUENT_BIT=yes \
    /bin/bash "$SCRIPT_DIR"/../local-loki-prometheus/deploy-helm.sh
    VALUES_FILE=$SCRIPT_DIR/values-fluent-local-all.yaml
fi

if [[ "${SKIP_FLUENT_BIT:-no}" == "no" ]]; then
    helm upgrade --install fluent-bit fluent/fluent-bit \
        --namespace "$NAMESPACE" \
        --values "$SCRIPT_DIR/../cluster-log-access/values.yaml" \
        --values "$SCRIPT_DIR/../cluster-metrics-access/values.yaml" \
        --values "$VALUES_FILE" \
        --debug --wait "$@"
else
    echo "Skipping Fluent Bit deployment"
fi
