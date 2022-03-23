# Fluent Bit usage on OpenShift by example

This repository contains helpful examples and scripts to use Fluent Bit on Openshift.

Originally created for https://calyptia.com/2022/03/23/how-to-send-openshift-logs-and-metrics-to-datadog-elastic-and-grafana/

All the examples in here are generally tested with OpenShift Code Ready Containers (CRC) to run a test cluster and the Helm chart to deploy.

Simple bash scripts are provided to make it easy to follow and port to any platform.

To use you will need to set up your credentials as variables and run the `deploy-helm.sh` script in the appropriate subdirectory.

For example, to use Grafana Cloud:
```bash
$ git clone https://github.com/calyptia/openshift-fluent-bit-examples.git
$ cd openshift-fluent-bit-examples
$ cat << EOF > grafana-cloud/.env
export GRAFANA_CLOUD_PROM_USERNAME=XXX
export GRAFANA_CLOUD_LOKI_USERNAME=XXX
export GRAFANA_CLOUD_APIKEY=XXX
export GRAFANA_CLOUD_PROM_URL=prometheus-prod-01-eu-west-0.grafana.net
export GRAFANA_CLOUD_LOKI_URL=logs-prod-eu-west-0.grafana.net
EOF
$ ./grafana-cloud/deploy-helm.sh
```
Remember to replace with your own settings as provided in Grafana UI, similarly for the other options just create a `.env` file with the relevant details or ensure they are set when the script runs.
