This document describes how to use the Red Hat OpenShift (OC) Operator for deploying both the SysFlow exporter and collector as pods on OpenShift platforms.  The exporter pushes SysFlow files at intervals to an S3 compliant data 
store, like IBM cloud object store (COS) or minio.   The operator is helm based and has been tested with OpenShift 3.11 and 4.3.  In the near future we hope to have a golang or ansible-based operator and have everything available
in the operator catalog.  For now, the operator is available on docker hub.


## Prerequisites:

1. Familiarize yourself with the operator-sdk:  https://github.com/operator-framework/operator-sdk/blob/master/doc/user-guide.md
2. S3 compliant object store - Currently tested with IBM's cloud object store, and minio object store (https://docs.min.io/). 
    * Setup IBM Cloud Object store: https://cloud.ibm.com/docs/services/cloud-object-storage/iam?topic=cloud-object-storage-getting-started
3. Create Cloud Object Store HMAC Access ID, and Secret Key.
    * For IBM Cloud Object store: https://cloud.ibm.com/docs/services/cloud-object-storage/iam?topic=cloud-object-storage-service-credentials
4. Knowledge of OpenShift/K8s.

## Clone the Repository

First, clone the repo with the following command:
```
git clone https://github.com/sysflow-telemetry/sf-deployments.git sf-deployments
cd sf-deployments/operator
```
Here are the steps in getting an OC operator deployed in an OpenShift cluster:

1. Login to your OpenShift cluster using the `oc` client tool. `oc login ...`
2. Create the sysflow project: `oc project sysflow`
3. Create a secret file for the S3 access id, and secret key.  Use the following file as a template: https://github.com/sysflow-telemetry/sf-deployments/blob/master/operator/secrets.yaml and call the secret: `sfexporterchart-secrets`. 
   Note: that access id and secret key values have to be base64 encoded in the file. You can generate the b64 encoding by doing:  `echo -n <s3 access id> | base64` and copying it into the yaml file
4. Install the secret into the sysflow project: `oc create -f secrets.yaml`
5. Edit the `operator/deploy/crds/charts.helm.k8s.io_v1alpha1_sfexporterchart_cr.yaml` for your deployment:


```
apiVersion: charts.helm.k8s.io/v1alpha1
kind: SfExporterChart
metadata:
  name: sfexporterchart
spec:
  # Default values copied from <project_dir>/helm-charts/sf-exporter-chart/values.yaml
  
  fullnameOverride: ""
  nameOverride: sfexporter
  registry:
    secretName: ""
  resources: {}
  sfcollector:
    filter: "container.type!=host and container.name!=sfexporter
      and container.name!=sfcollector"
    interval: 300
    outDir: /mnt/data/
    repository: sysflowtelemetry/sf-collector
    tag: edge
    imagePullPolicy: Always
  sfexporter:
    interval: 30
    outDir: /mnt/data/
    repository: sysflowtelemetry/sf-exporter
    s3Bucket: sysflow-bucket
    s3Endpoint: s3.private.us-south.cloud-object-storage.appdomain.cloud
    #s3Endpoint: s3.us-south.cloud-object-storage.appdomain.cloud
    s3Location: us-south
    s3Port: 443
    s3Secure: "true"
    tag: edge
    imagePullPolicy: Always
  tmpfsSize: 500Mi
```

Most of the defaults should work in any environment.  The collector is
currently set to rotating files in 5 min intervals (or 300 seconds).   The `/mnt/data/` is mapped to a tmpfs filesystem, and you can specify its size using the `tmpfsSize`.  

For connecting to an S3 compliant data store, first take note of which port the S3 data store (`s3Port`) is configured.  IBM Cloud COS listens on port 443, but certain minio installations can listen on 
port 9000.  Also, if TLS is enabled on the S3 datastore, ensure `s3Secure` is `true`.  Ensure that the `s3Bucket` is set to the desired S3 bucket location.   The `s3Endpoint`  is either the domain name or IP
address of the COS instance, while `s3Location` is set to a region (COS) or location (minio).  Example values are above.

6. Change into the `operator` directory.  There are a set of pre-defined scripts to make deployment easier.
7.  Run the following commands to deploy the operator into your cluster:
    1. `./createCRD` -  deploys the custom resource definition.
    2. `./deployOperator.sh` - deploys the operator proper.
    3. `./applyCR` - applies the Custom Resource.
8. The operator should now have deployed the collector and exporter.
9. Check to see that they are operational `oc get pods -n sysflow`
10. If one of the containers is not functioning properly, you can check its logs by doing: `oc logs -f <podname> -c <sfcollector or sfexporter> -n sysflow` 
11. You can enter the containers via: `oc exec -it <podname> -c <sfcollector or sfexporter> -n sysflow /bin/bash` 
12. To delete the operator/sysflow pod, do the following:
    1. `./cleanup.sh`
    2. `./clearCRD`
