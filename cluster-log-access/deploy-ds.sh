#!/bin/bash
set -eux
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

NAMESPACE=${NAMESPACE:-fluent-bit-logging}
IMAGE=${IMAGE:-registry.connect.redhat.com/calyptia/fluent-bit:1.8.12}

/bin/bash "$SCRIPT_DIR/service-account-creation.sh"

echo "Setting up Fluent Bit daemonset in $NAMESPACE"

cat << EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
  namespace: $NAMESPACE
data:
  fluent-bit.conf: |-
    [SERVICE]
        Daemon Off
        Log_Level Info
        HTTP_Server On
        HTTP_Listen 0.0.0.0
        HTTP_Port 2020
        Health_Check On
        Parsers_File parsers.conf

    [INPUT]
        Name tail
        Path /var/log/containers/*.log
        multiline.parser docker, cri
        Tag kube.*
        Mem_Buf_Limit 5MB
        Skip_Long_Lines On

    [INPUT]
        Name systemd
        Tag host.*
        Systemd_Filter _SYSTEMD_UNIT=kubelet.service
        Read_From_Tail On

    [FILTER]
        Name kubernetes
        Match kube.*
        Merge_Log On
        Keep_Log Off
        K8S-Logging.Parser On
        K8S-Logging.Exclude On

    [OUTPUT]
        Name stdout
        Match *
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluent-bit
  namespace: $NAMESPACE
spec:
  selector:
    matchLabels:
      app: fluent-bit
  template:
    metadata:
      labels:
        app: fluent-bit
    spec:
      serviceAccountName: fluent-bit
      containers:
        - name: fluent-bit
          image: $IMAGE
          securityContext:
            runAsUser: 0
            seLinuxOptions:
              type: spc_t
            readOnlyRootFilesystem: true
            allowPrivilegeEscalation: false
          ports:
            - containerPort: 2020
          volumeMounts:
            - name: config-volume
              mountPath: /fluent-bit/etc/fluent-bit.conf
              subPath: fluent-bit.conf
            - name: varlogcontainers
              readOnly: true
              mountPath: /var/log/containers
            - name: varlogpods
              readOnly: true
              mountPath: /var/log/pods
      volumes:
        - name: config-volume
          configMap:
            name: fluent-bit-config
        - name: varlogcontainers
          hostPath:
            path: /var/log/containers
        - name: varlogpods
          hostPath:
            path: /var/log/pods
---
EOF