#!/bin/bash
set -eu
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

NAMESPACE=${NAMESPACE:-fluent-bit-logging}

# Make sure to do this first for Openshift
/bin/bash "$SCRIPT_DIR/../cluster-log-access/service-account-creation.sh"

echo "Setting up Fluent Bit to local Grafana stack from helm chart in $NAMESPACE"

# Add both with and without slashes as considered different
helm repo add fluent https://fluent.github.io/helm-charts || helm repo add fluent https://fluent.github.io/helm-charts/
helm repo add grafana https://grafana.github.io/helm-charts || helm repo add grafana https://grafana.github.io/helm-charts/
helm repo update

# Deploy Loki stack
helm upgrade --install loki grafana/loki-stack --namespace="$NAMESPACE" --create-namespace --debug --wait -f "$SCRIPT_DIR/values-stack.yaml" 

echo "Loki stack deployed, use loki.$NAMESPACE for Fluent Bit configuration inside K8S - outside requires ingress set up."
echo
echo "To port forward Grafana to localhost:80 'kubectl port-forward --namespace $NAMESPACE service/loki-grafana 3000:80'"
echo "Credentials are "
echo -n "admin:"
kubectl get secret --namespace "$NAMESPACE" loki-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

if [[ "${SKIP_FLUENT_BIT:-no}" == "no" ]]; then
    helm upgrade --install fluent-bit fluent/fluent-bit \
        --namespace "$NAMESPACE" \
        --values "$SCRIPT_DIR/../cluster-log-access/values.yaml" \
        --values "$SCRIPT_DIR/../cluster-metrics-access/values.yaml" \
        --values "$SCRIPT_DIR/values-fluent.yaml" \
        --debug --wait "$@"
else
    echo "Skipping Fluent Bit deployment"
fi
