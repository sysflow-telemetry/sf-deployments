# Helm Charts

The sf-deployments repository  contains a set of helm charts (under the helm directory) used to deploy the sysflow collector, and exporter into a K8s environment. It also contains a test harness for testing the telemetry infrastructure against 
various workloads. Think of helm as a package manager for deploying kubernetes pods and services into a cloud.  The charts tell Helm how to conduct these deployments and allow the user to change a wide array of configurations.

The SysFlow telemetry infrastructure is designed such that it should be deployable in any cloud environment. It has been tested on IBM Cloud, and as time permits, we will test it on other 
public/private cloud offerings. There are likely some minor differences in how the authentication works on each cloud which could require changes to these charts.

NOTE: This document has been tested with helm version 2.12, 2.16, and 3.1.  Some helm commands may not work with other versions of helm.  We've tested the framework on k8s versions 1.14, 1.15, 1.16. 

## Prerequisites

1. Install Helm: https://helm.sh/ 
2. Setup TLS for Helm: https://v2.helm.sh/docs/tiller_ssl/
3. S3 compliant object store - Currently tested with IBM's cloud object store, and minio object store (https://docs.min.io/). 
    * Setup IBM Cloud Object store: https://cloud.ibm.com/docs/services/cloud-object-storage/iam?topic=cloud-object-storage-getting-started
5. Create Cloud Object Store HMAC Access ID, and Secret Key.
    * For IBM Cloud Object store: https://cloud.ibm.com/docs/services/cloud-object-storage/iam?topic=cloud-object-storage-service-credentials 

## Clone the Repository

First, clone the repo with the following command:
```
git clone git clone https://github.com/sysflow-telemetry/sf-deployments.git .
cd sf-deployments/helm
```

## Helm - sf-exporter-chart 

The sf-exporter-chart resides in the `sf-exporter-chart` folder.  The exporter chart is a kubernetes daemonset, which deploys the sf-collector, and the sf-exporter to each node in the cluster.  The sf-collector monitors the node, and writes sysflow to a shared mount `/mnt/data`.  The sf-exporter reads from the `/mnt/data` and pushes completed files to an S3 compliant object store for analysis before deleting them.  

An install script called `./installExporterChart` is provided to make using the helm chart easier.  This script sets up the environment including k8s secrets. To use it, first go into the sf-exporter-chart directory and copy `values.yaml` to `values.yaml.local` and begin tailoring this yaml to your environment. Note that some of values set in here are passable through the installation script for safety reasons.  Note that the install and delete scripts assume that tls is NOT installed.  To support tls, simply add `--tls` to the helm commands at the bottom of each file.

```
registry:
  secretName: ""

# sysflow collection probe parameters
sfcollector:
  # image repository
  repository: sysflowtelemetry/sf-collector
  # image tag
  tag: latest
  # timeout in seconds to start roll a new trace files
  interval: 300
  # output directory, where traces are written to inside container
  outDir: /mnt/data/
  # collection filter
  filter: "\"container.type!=host and container.name!=sfexporter and container.name!=sfcollector\""
  #Use this criPath if running docker runtime
  #criPath: ""
  #uUse this criPath if running containerd runtime
  criPath: "/var/run/containerd/containerd.sock"
  #uUse this criPath if running crio runtime
  #criPath: "/var/run/crio/crio.sock"


# sysflow exporter parameters
sfexporter:
  # image repository
  repository: sysflowtelemetry/sf-exporter
  # image tag
  tag: latest
  # export inverval
  interval: 30
  # directory where traces are read from inside container
  outDir: /mnt/data/
  # object store address (overridden by install script)
  s3Endpoint: "<ip address>"
  # object store port
  s3Port: 443
  # object store bucket where to push traces
  s3Bucket: sysflow-bucket
  # object store location (overridden by install script)
  s3Location: us-south
  # object store access key (overridden by install script)
  s3AccessKey: "<s3_access_key>"
  # object store secret key (overridden by install script)
  s3SecretKey: "<s3_secret_key>"
  # object store connection, 'true' if TLS-enabled, 'false' otherwise
  s3Secure: "false"

nameOverride: "sfexporter"
fullnameOverride: ""
tmpfsSize: 500Mi # size of tmpfs shared volume between collector and exporter (where traces are written)
```
Most of the defaults should work in any environment.  The collector is
currently set to rotating files in 5 min intervals (or 300 seconds).   The `/mnt/data/` is mapped to a tmpfs filesystem, and you can specify its size using the `tmpfsSize`.  
CGroup resource limits can be set on the collector and exporter to limit resource usage.  These can be adjusted depending on requirements and resources limitations.

For connecting to an S3 compliant data store, first take note of which port the S3 data store (`s3Port`) is configured.  IBM Cloud COS listens on port 443, but certain minio installations can listen on 
port 9000.  Also, if TLS is enabled on the S3 datastore, ensure `s3Secure` is `true`.  Ensure that the `s3Bucket` is set to the desired S3 bucket location.   The `s3Location`, `s3AccessKey` and `s3SecretKey` and `s3Endpoint` are each passed in through the installation script if you use it.

Kubernetes can use different container runtimes.  Older versions used the docker runtime; however, newer versions typically run either containerd or crio.  It's important to know which runtime you have if you want to get the full benefits of sysflow. You tell the collector which runtime 
you are using based on the sock file you refer too in the `criPath` variable.  If you are using the `docker` runtime, leave `criPath` blank.  If you are using containerd, set `criPath` to "/var/run/containerd/containerd.sock" and if you are using crio, set `criPath` to "/var/run/crio/crio.sock".
If SysFlow files are empty or the container name variable is set to `incomplete` in SysFlow traces, this typically means that the runtime socket is not connected properly.

There are two versions of the install script.  One in `sf-deployments/helm/helm-scpts-v2` works with helm version 2, while the other in `sf-deployments/helm/helm-scpts-v3` works with version 3. Run the script from the `helm` directory. For example:
```
./helm-scpts-v2/installExporterChart <s3_region> <s3_access_key> <s3_secret_key> <s3_endpoint>
   <s3_region> value is the region in the S3 compliant object store (e.g., us-south)
   <s3_access_key> is the access key present in S3 compliant service credentials
   <s3_secret_key> is the secret key present in S3 compliant service credentials
   <s3_endpoint> is the address of the S3 compliant object store (e.g., s3.us-south.cloud-object-storage.appdomain.cloud)
```


Note the install script installs the pods into a K8s namespace called `sysflow`

To check that the install worked, run:

```
kubectl get pods -n sysflow
```

To check the log output of the collector container in a pod:

```
kubectl logs -f -c sfcollector <podname>  -n sysflow
```

To check the log output of the exporter container in a pod:

```
kubectl logs -f -c sfexporter <podname>  -n sysflow
```

To delete the exporter chart run:

```
./helm-scpts-v2/deleteExporterChart
```
