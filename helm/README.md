# SysFlow Helm Charts

The sf-deployments repository  contains a set of helm charts (under the helm directory) used to deploy the sysflow collector, exporter, and analytics engine driver into
a K8s environment.  It also contains a test harness for testing the telemetry infrastructure against various workloads.  Think of
helm as a package manager for deploying kubernetes pods and services into a cloud.  The charts tell Helm how to conduct these 
deployments and allow the user to change a wide array of configurations.

The SysFlow telemetry infrastructure is designed such that it should be deployable in any cloud environment.  Currently, due to 
resource limitations we have only been able to test infrastructure on IBM Cloud.  As time permits, we will test deployment on other 
public/private cloud offerings. There are likely some minor differences in how the authentication works on each cloud which could
require changes to these charts.


## Helm

A detailed discussion of Helm is beyond the scope of this documentation.  Please see:  

https://helm.sh/ 

for all things Helm related.

If you haven't already done so, please setup helm TLS:  

https://github.com/helm/helm/blob/master/docs/tiller_ssl.md

## Prerequisites 

This document assumes that you have helm installed on your machine and configured to point to the desired k8s environment.  The document
also assumes that you have docker images:  sf-exporter, sf-collector, and sf-analytics available in a docker registry for deployment.  Finally, the 
document assumes that you have an S3 compliant object store setup, and a spark instance configured (if using the sf-analytics-chart).

## Clone the Repository

First, clone the repo with the following command:
```
git clone git@github.ibm.com:sysflow/sf-helm-charts.git .
cd sf-helm-charts
```

## Helm - sf-exporter-chart 

The sf-exporter-chart resides in the sf-exporter-chart folder.  The exporter chart is a kubernetes daemonset, which deploys the sf-collector, and the
sf-exporter to each node in the cluster.  The sf-collector monitors the node, and writes sysflow to a shared mount <code>/mnt/data</code>.  The sf-exporter
reads from the <code>/mnt/data</code> and pushes completed files to an S3 compliant object store for analysis before deleting them.  

An install script called <code>./installExporterChart</code> is provided to make using the helm chart easier.  This script sets up the environment including k8s secrets.   To use it, first go into the sf-exporter-chart directory and copy <code>values.yaml</code> to <code>values.yaml.local</code> and begin tailoring this yaml to your environment.  Note that some of values set in here are passable through the installation script for safety reasons.

```
# Default values for sysporter-chart.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

registry:
  secretName: container-insights-secret


sfcollector:
  repository: us.icr.io/csa-ci/sysporter
  tag: runtime
  imagePullPolicy: Always
  interval: 300
  outDir: /mnt/data/
  filter: "-f \"container.type!=host and container.type=docker and container.name!=sfexporter and container.name!=sfcollector and container.name!=skydive-agent\""
sfexporter:
  repository: us.icr.io/seccloud/sf-exporter
  tag: latest
  imagePullPolicy: Always
  cosEndpoint: s3.us-south.objectstorage.service.networklayer.com
  cosPort: 443
  interval: 5
  cosBucket: test-sf-ch-research-dev
  cosLocation: us-south
  cosAccessKey: <cos access key>
  cosSecretKey: <cos secret key>

outDir: /mnt/data/
nameOverride: "sfexporter"
fullnameOverride: ""
tmpfsSize: 500Mi

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 100m
    memory: 128Mi

nodeSelector: {}

tolerations: []

affinity: {}
```
Most of the defaults should work in any environment.  Ensure that the repository locations for both the sfcollector and sfexporter are pointing to the correct location.  The collector is
currently set to rotating files in 5 min intervals (or 300 seconds).   The <code>/mnt/data/</code> is mapped to a tmpfs filesystem, and you can specify its size using the <code>tmpfsSize</code>.  
CGroup resource limits can be set on the collector and exporter to limit resource usage.  These can be adjusted depending on requirements and resources limitations.

Ensure that the <code>cosBucket</code> is set to the desired S3 bucket location.   The cosLocation, cosAccessKey and cosSecretKey are each passed in through the installation if you use it.

```
./installExporterChart <cos_region> <cos_access_key> <cos_secret_key>
```

Note the install script installs the pods into a K8s namespace called <code>security-advisor-insights</code>

To delete the exporter chart run:

```
./deleteExporterChart
```

## Helm - sf-analytics-chart 

The sf-analytics-chart helm chart is for deploying the SysFlow analytics framework driver into a k8s environment.  The driver is designed to launch spark-based analytics jobs at intervals to consume any SysFlow's pushed to an S3 compliant object store.   The current implementation of the helm chart assumes an IBM
analytics engine (spark pipeline) is configured.  The helm chart and driver should work with a vanilla spark installation on another cloud, but we need to test this in the future.

As with the exporter, there is an install script called <code>./installAnalyticsChart</code> is provided to make using the helm chart easier.  This script sets up the environment including k8s secrets.   To use it, first go into the sf-analytics-chart directory and copy <code>values.yaml</code> to <code>values.yaml.local</code> and begin tailoring this yaml to your environment.  Note that some of values set in here are passable through the installation script for safety reasons.

```
# Default values for sysalyzer-chart.
# This is a YAML-formatted file.
# Declare variables to be passed into your templates.

replicaCount: 1

image:
  repository: us.icr.io/seccloud/sf-analytics
  tag: latest
  pullPolicy: Always
  secretName: container-insights-secret

nameOverride: ""
fullnameOverride: sfanalytics

sfanalytics:
  iamEndpoint: "https://iam.cloud.ibm.com/identity/token"
  iamApiKey: "iamAPIKey"
  interval: 300
  timeout: 5
  cosBucket: "test-sf-ch-research-dev"
  cosLocation: "us-south"
  cosEndpoint: "s3.us-south.objectstorage.service.networklayer.com"
  cosPort: 443
  aeEndpoint: "https://chs-qea-159-mn001.us-south.ae.appdomain.cloud"
  aeUpload: "True"
  aeUser: "ae user"
  aePwd: "ae pwd"
  debug: "True"
  kpInstanceId: "kp instance"
  aeExecutorMem: "3g"
  aeDriverMem: "3g"

resources: {}
  # We usually recommend not to specify default resources and to leave this as a conscious
  # choice for the user. This also increases chances charts run on environments with little
  # resources, such as Minikube. If you do want to specify resources, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  # limits:
  #  cpu: 100m
  #  memory: 128Mi
  # requests:
  #  cpu: 100m
  #  memory: 128Mi

nodeSelector: {}

tolerations: []
```

The install script takes 6 sensitive pieces of information.  Note in this case analytics engine refers to the IBM Analytics Engine, key protect = IBM key protect, and IAM refers to the IAM service credentials for IBM cloud:

```
Usage : ./installAnalyticsChart<cos_region> <iam_api_key> <ae_user> <ae_password> <ae_endpoint> <kp_instance_id>
<cos_region> value is either us-south or eu-gb
<iam_api_key> is the api key present in iam service credentials
<ae_user> is the analytics engine user
<ae_password> is the analytics engine password
<ae_endpoint> is the analytics engine endpoint
<kp_instance_id> is the key protect instance id
```
To delete the analytics chart run the following:

```
./deleteAnalyticsChart
```


## Useful IBM Cloud commands:

### list all images in the registry
ibmcloud cr image-list

### list pods running in cluster in the security-advisor-insights namespace
kubectl get pods -n security-advisor-insights

### get more information on a pod (why it failed for example)
kubectl describe pod <pod name>

### init helm chart with tls keys

helm init --debug  --tiller-tls --tiller-tls-cert ./tiller.cert.pem --tiller-tls-key ./tiller.key.pem --tiller-tls-verify --tls-ca-cert ca.cert.pem --service-account=tiller
