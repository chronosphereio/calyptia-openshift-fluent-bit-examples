#!/bin/bash
# Copyright 2021 Calyptia, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file  except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the  License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
set -eu
# Simple script to provision a Kubernetes cluster using KIND: https://kind.sigs.k8s.io/

# Override with a different name if you want
CLUSTER_NAME=${CLUSTER_NAME:-kind}
# The fluent bit image under test
FLUENT_BIT_IMAGE=${FLUENT_BIT_IMAGE:-fluent/fluent-bit:latest}

if ! command -v kind &> /dev/null; then 
  echo "Unable to find KIND, please install: https://kind.sigs.k8s.io/"
  exit 1
fi

# Delete the old cluster (if it exists)
kind delete cluster --name="${CLUSTER_NAME}" 2>/dev/null

# Create KIND cluster with 3 worker nodes, control node can support ingress too if required
kind create cluster --name="${CLUSTER_NAME}" --config - <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
# featureGates:
#  EphemeralContainers: true
#  APIServerTracing: true
#  KubeletTracing: true
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
- role: worker
- role: worker
- role: worker
EOF

# Preload the cluster with the Fluent Bit image on every node
docker pull "${FLUENT_BIT_IMAGE}"
kind load docker-image "${FLUENT_BIT_IMAGE}" --name="${CLUSTER_NAME}"

echo "Cluster created successfully"
echo "Use 'kind load docker-image <image tag>' to push images into the nodes, otherwise they will be pulled"
