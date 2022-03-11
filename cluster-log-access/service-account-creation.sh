#!/bin/bash
set -eux

NAMESPACE=${NAMESPACE:-fluent-bit-logging}

echo "Setting up SCC and associated service account in $NAMESPACE"

cat << EOF | kubectl apply -f -
kind: Namespace
apiVersion: v1
metadata:
  name: $NAMESPACE
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: fluent-bit-openshift
  namespace: $NAMESPACE
---
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: fluent-bit-scc
allowHostPorts: false
priority: null
requiredDropCapabilities:
  - CHOWN
  - DAC_OVERRIDE
  - FSETID
  - FOWNER
  - SETGID
  - SETUID
  - SETPCAP
  - NET_BIND_SERVICE
  - KILL
allowPrivilegedContainer: false
runAsUser:
  type: RunAsAny
users: []
allowHostDirVolumePlugin: true
allowHostIPC: false
forbiddenSysctls:
  - '*'
seLinuxContext:
  type: RunAsAny
readOnlyRootFilesystem: true
fsGroup:
  type: RunAsAny
groups: []
defaultAddCapabilities: null
supplementalGroups:
  type: RunAsAny
volumes:
  - configMap
  - emptyDir
  - hostPath
  - secret
allowHostPID: false
allowHostNetwork: false
allowPrivilegeEscalation: false
allowedCapabilities: null
defaultAllowPrivilegeEscalation: false
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: fluent-bit-role
  namespace: $NAMESPACE
rules:
  - verbs:
      - use
    apiGroups:
      - security.openshift.io
    resources:
      - securitycontextconstraints
    resourceNames:
      - fluent-bit-scc
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: fluent-bit-role-binding
  namespace: $NAMESPACE
subjects:
  - kind: ServiceAccount
    name: fluent-bit-openshift
    namespace: $NAMESPACE
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: fluent-bit-role
---
EOF
