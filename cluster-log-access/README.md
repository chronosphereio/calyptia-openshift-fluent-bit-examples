A simple example to deploy Fluent Bit, either with the Helm chart or as explicit daemonset, so that it sends all logs to `stdout`.

1. `crc start`
2. [`deploy-helm.sh`](./deploy-helm.sh)

Now, just get the output from the pod:
```
kubectl logs --namespace fluent-bit-logging $(kubectl get pods --namespace fluent-bit-logging -l "app.kubernetes.io/name=fluent-bit,app.kubernetes.io/instance=fluent-bit" -o jsonpath="{.items[0].metadata.name}")
```