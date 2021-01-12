# Helm Charts

Helm charts are provided to facilitate the deployment and configuration of SysFlow on Kubernetes.

These charts have been tested on [minikube](https://minikube.sigs.k8s.io/) and [IBM Cloud Kubernetes Service](https://www.ibm.com/cloud/kubernetes-service). They shoud work on vanilla Kubernetes installations but it's possible that minor differences in how authentication is handled by different cloud providers require small modifications to the charts.

> These scripts have been tested with helm versions 2 and 3. Some helm commands may not work with other versions of helm.

## Prerequisites

- kubectl ([installing kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl))
- Helm ([installing helm](https://helm.sh/docs/intro/install))
- Docker (optional)

## Install minikube (optional)

To deploy SysFlow on a local Kubernetes instance (for development or testing), start by installing minikube in your macOS, Linux, or Windows system.

For example, to install minikube in Linux distributions, run:

```bash
 curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
 sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

Then, start your cluster:

```bash
minikube start
```

> Note: to install SysFlow on minikube, set `sfcollector.ebpf` and `sfcollector.mountEtc` to `true` and change `sfcollector.tag` to `bpf` in `values.yaml` located inside each chart. 

Check the [minikube docs](https://minikube.sigs.k8s.io/docs/start/) for additional installation options.

> Tip: run `eval $(minikube docker-env)` to allow your Docker CLI to connect to minikube's Docker environment.

The recommended driver for minikube is VirtualBox. Check the [VirtualBox docs](https://www.virtualbox.org/wiki/Downloads) for installation instructions for your environment.

> A note about Docker pull limits: If you run into an error when deploying SysFlow on minikube, check the logs to see if it's related to the Docker pull limit being reached. It most likely is. To work around this inconvenience, connect to Minikube's Docker environment (see above), log into Docker with `docker login` command, and pull the desired images manually, before installing the helm charts. Make sure the images pull policies are set to the default value `IfNotPresent`.

## Deploy SysFlow

The SysFlow agent can be deployed in S3 (batch) or rsyslog (stream) export configurations.

### Installing the SysFlow agent with S3 Exporter

In this configuration, SysFlow exports the collected telemetry as trace files (batches of SysFlow records) to any S3-compliant object storage service.

<center>
    <img src="https://sysflow.readthedocs.io/en/latest/_static/SF_Collector_Exporter.png" width="45%" height="45%" />
    <figcaption>SysFlow agent deployed with telemetry data exported to S3-compliant object storage.</figcaption>
</center>

This chart is located in `charts/sf-exporter-chart`, which deploys the SysFlow Collector and Exporter as a daemonset. The collector monitors the node, and writes trace files to a shared memory volume `/mnt/data` which the exporter manages and reads from to push completed traces to a S3-compliant object storage. The `/mnt/data/` is mapped to a tmpfs filesystem, and you can specify its size using the `tmpfsSize`.

Installation scripts are provided to make installation easier. These scripts set up the environment including k8s secrets for S3 authentication. To connect to an S3-compliant data store, first take note of which port the S3 data store (`s3Port`) is configured. Minio installations listen on port 9000 by default. Also, if TLS is enabled on the S3 datastore, ensure `s3Secure` is `true`. Ensure that the `s3Bucket` is set to the desired S3 bucket location. The `s3Location`, `s3AccessKey` and `s3SecretKey` and `s3Endpoint` are each passed in through the installation script if you use it.

To deploy the SysFlow agent with S3 export:

```
./scripts/installExporterChart.sh <s3_region> <s3_access_key> <s3_secret_key> <s3_endpoint> <s3_bucket>
```

### Installing the SysFlow agent with rsyslog exporter

In this configuration, SysFlow exports the collected telemetry as trace files (batches of SysFlow records) to any S3-compliant object storage service.

<center>
    <img src="https://sysflow.readthedocs.io/en/latest/_static/SF_Collector_Processor.png" width="45%" height="45%" />
    <figcaption>SysFlow agent deployed with telemetry data exported to a rsyslog collector.</figcaption>
</center>

This chart is located in `charts/sf-processor-chart`, which deploys the SysFlow Collector and Processor as a daemonset. The collector monitors the node, and streams SysFlow records to the processor, which executes a configurable edge analytic pipeline and export events to a rsyslog endpoint.

To deploy the SysFlow agent with rsyslog export:

```
./scripts/installProcessorChart.sh <syslog_host> <syslog_port> <syslog_proto>
```

### Checking installation

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

To check the log output of the processor container in a pod:
```
kubectl logs -f -c sfprocessor <podname>  -n sysflow
```

### Removing the SysFlow agent

To remove the SysFlow agent:
```
./scripts/deleteChart.sh
```

### Advanced customizations

Most of the defaults should work out of the box. The collector is currently set to rotating files in 5 min intervals (or 300 seconds). CGroup resource limits can be set on the collector, exporter, and processor to limit resource usage. These can be adjusted depending on requirements and resources limitations.

> Note: `sfcollector.dropMode` is set to `true` by default for performance considerations. If tracking `mmap` is required, set it to `false`.

Kubernetes can use different container runtimes. Older versions used the docker runtime; however, newer versions typically run either containerd or crio.  It's important to know which runtime you have if you want to get the full benefits of SysFlow. You tell the collector which runtime you are using based on the sock file you refer to in the `criPath` variable. If you are using the `docker` runtime, leave `criPath` blank. If you are using containerd, set `criPath` to "/var/run/containerd/containerd.sock" and if you are using crio, set `criPath` to "/var/run/crio/crio.sock". If SysFlow files are empty or the container name variable is set to `incomplete` in SysFlow traces, this typically means that the runtime socket is not connected properly.

> Note: the installation script installs the pods into a K8s namespace called `sysflow`.

Below is the list of customizable attributes for the charts, organized by component. These can be modified directly into the `values.yaml` located in each chart's directory. They can also be set directly into the helm command invoked by our installation scripts through `--set <attribute>=<value>` parameters.

#### SysFlow Collector (sf-exporter-chart | sf-processor-chart)

| parameter | description | default |
|-|-|-|
| sfcollector.imagepullpolicy | Pull policy for image (Always\|Never\|IfNotPresent) | IfNotPresent |
| sfcollector.repository | Image repository | sysflowtelemetry/sf-collector |
| sfcollector.tag | Image tag | latest |
| sfcollector.interval | Interval in seconds to roll new trace files | 300 |
| sfcollector.outDir | Directory in which collector writes trace files | /mnt/data/ |
| sfcollector.filter | Filter expression | "\"container.type!=host and container.name!=sfexporter and container.name!=sfcollector\"" |
| sfcollector.criPath | Container runtime socket path.  Use this "/var/run/containerd/containerd.sock"if running containerd runtime.  Use "/var/run/crio/crio.sock" if running crio runtime. | "" |
| sfcollector.dropMode | Drop mode filters syscalls in the kernel before they are passed up to the collector,  resulting in much better performance and fewer event drops. Note: It filters mmap  system calls from the event stream. | true |
| sfcollector.fileOnly | Filters out any descriptor that is not a file, including unix sockets and pipes | false |
| sfcollector.procFlow | Enables the creation of process flows | false |
| sfcollector.readMode | Sets mode for reads: `0` enables recording all file reads as flows. `1` disables all file reads.   `2` disables recording file reads to noisy directories: "/proc/", "/dev/", "/sys/", "//sys/",  "/lib/",  "/lib64/", "/usr/lib/", "/usr/lib64/". | 0 |
| sfcollector.ebpf | Enables ebpf probe (required for minikube deployment) | false |
| sfcollector.mountEtc | Mounts etc directory in container (required for minikube and Google COS) | false |

#### SysFlow Exporter (sf-exporter-chart)

| parameter | description | default |
|-|-|-|
| sfexporter.imagepullpolicy | Pull policy for image (Always\|Never\|IfNotPresent) | IfNotPresent |
| sfexporter.repository | Image repository | sysflowtelemetry/sf-exporter |
| sfexporter.tag | Image tag | latest |
| sfexporter.interval | Interval in seconds to export trace files to S3 | 30 |
| sfexporter.outDir | Directory from which exporter reads trace files | /mnt/data/ |
| sfexporter.s3Endpoint | S3 host address | "\<ip address\>" |
| sfexporter.s3Port | S3 port | 9000 |
| sfexporter.s3Bucket | S3 bucket where to push traces | "\<s3 bucket\>" |
| sfexporter.s3Location | S3 location | "\<s3 region\>" |
| sfexporter.s3AccessKey | S3 access key | "\<s3 access key\>" |
| sfexporter.s3SecretKey | S3 secret key | "\<s3 secret key\>" |
| sfexporter.s3Secure | S3 connection, `true` if TLS-enabled, `false` otherwise | false |

#### SysFlow Processor (sf-processor-chart)

| parameter | description | default |
|-|-|-|
| sfprocessor.imagepullpolicy | Pull policy for image (Always\|Never\|IfNotPresent) | IfNotPresent |
| sfprocessor.repository | Image repository | sysflowtelemetry/sf-processor |
| sfprocessor.tag | Image tag | latest |
| sfprocessor.export | Export type (`terminal`\|`file`\|`syslog`) | syslog |
| sfprocessor.syslogHost | rsyslog host address | localhost |
| sfprocessor.syslogPort | rsyslog port | 514 |
| sfprocessor.syslogProto | rsyslog protocol (`udp`\|`tcp`\|`tcp+tls`) | tcp |