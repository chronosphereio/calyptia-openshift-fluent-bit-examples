# Access cluster metrics with Fluent Bit on Openshift

Assuming the [set up to allow log file access](../cluster-log-access/service-account-creation.sh), this provides the extra volume mounts for the host `/proc` and `/sys` for the Fluent Bit helm chart.

The intention is it can be used in combination with the other Helm value files, e.g. see the Grafana Cloud [deployment script](../grafana-cloud/deploy-helm.sh).

```bash
$ ../cluster-log-access/service-account-creation.sh
$ helm upgrade --install fluent-bit fluent/fluent-bit \
    --values "../cluster-log-access/values.yaml" \
    --values "./values.yaml" \
...
```

The volumes get mounted as `/host/proc` and `/host/sys`, plus an extra configuration file as `/fluent-bit/etc/input-node-exporter.conf` is provided that sets up the [node exporter input plugin](https://docs.fluentbit.io/manual/pipeline/inputs/node-exporter-metrics) to use those mounts.
This configuration file needs to be included in the overall configuration somewhere, probably as part of the output configuration.

```yaml
config:
  outputs: |
    @include input-node-exporter.conf

    [OUTPUT]
        name prometheus_remote_write
...
```

## Non-Helm deployments

If you are not using Helm then the same set up can be replicated by mounting the host `/proc` and `/sys` file systems as read-only to `/host/proc` and `/host/sys` then repeating the input configuration to use these paths.

```
[INPUT]
    name            node_exporter_metrics
    tag             node_metrics
    path.procfs     /host/proc
    path.sysfs      /host/sys
```

Make sure to run the service account creation set up as indicated above.
