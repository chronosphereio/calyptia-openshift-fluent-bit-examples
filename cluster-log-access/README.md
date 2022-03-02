A simple example to deploy Fluent Bit, either with the Helm chart or as explicit daemonset, so that it sends all logs to `stdout`.

1. `crc start`
2. [`service-account-creation.sh`](./service-account-creation.sh)
3. [`deploy-helm.sh`](./deploy-helm.sh) or [`deploy-ds.sh`](./deploy-ds.sh)

Now, just get the output from the pod:
```
$ kubectl logs --namespace fluent-bit-logging $(kubectl get pods --namespace fluent-bit-logging -l "app.kubernetes.io/name=fluent-bit,app.kubernetes.io/instance=fluent-bit" -o jsonpath="{.items[0].metadata.name}")
Fluent Bit v1.8.12
* Copyright (C) 2019-2021 The Fluent Bit Authors
* Copyright (C) 2015-2018 Treasure Data
* Fluent Bit is a CNCF sub-project under the umbrella of Fluentd
* https://fluentbit.io

[2022/03/02 10:06:25] [ info] [engine] started (pid=1)
[2022/03/02 10:06:25] [ info] [storage] version=1.1.5, initializing...
[2022/03/02 10:06:25] [ info] [storage] in-memory
[2022/03/02 10:06:25] [ info] [storage] normal synchronization mode, checksum disabled, max_chunks_up=128
[2022/03/02 10:06:25] [ info] [cmetrics] version=0.2.2
[2022/03/02 10:06:25] [ info] [input:tail:tail.0] multiline core started
[2022/03/02 10:06:25] [ info] [filter:kubernetes:kubernetes.0] https=1 host=kubernetes.default.svc port=443
[2022/03/02 10:06:25] [ info] [filter:kubernetes:kubernetes.0] local POD info OK
[2022/03/02 10:06:25] [ info] [filter:kubernetes:kubernetes.0] testing connectivity with API server...
[2022/03/02 10:06:25] [ info] [filter:kubernetes:kubernetes.0] connectivity OK
[2022/03/02 10:06:25] [ info] [http_server] listen iface=0.0.0.0 tcp_port=2020
[2022/03/02 10:06:25] [ info] [sp] stream processor started
[2022/03/02 10:06:25] [ info] [input:tail:tail.0] inotify_fs_add(): inode=79852208 watch_fd=1 name=/var/log/containers/apiserver-56bdf9c9c4-xgdbt_openshift-apiserver_fix-audit-permissions-4c26716eb2ffdd1fb06048437f8114bdf5eef4d76dc3ad8a7dc7dd8e88923b69.log
```

You can also use some of the Helm charts to deploy Loki, etc. for testing from: https://github.com/calyptia/fluent-bit-devtools
Make sure to set the output plugin to forward to whatever tool you decide to use.
