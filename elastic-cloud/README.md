# Send logs and metrics to Elastic Cloud from Openshift

Make sure to either export the relevant credentials first or add them to a `.env` file:
```
$ cat .env
```

Then we can just use the scripts here:
1. `crc start`
2. [`deploy-helm.sh`](./deploy-helm.sh)