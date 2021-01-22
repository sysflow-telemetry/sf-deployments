# Docker

This repository contains utility scripts to deploy a docker telemetry stack. 

## Pre-requisites

- Docker ([installing Docker](https://docs.docker.com/engine/install/))
- Docker Compose ([installing Compose](https://docs.docker.com/compose/install/))

To guarantee a smooth deployment, the kernel headers must be installed in the host operating system.

This can usually be done on Debian-like distributions with:

```bash
apt-get -y install linux-headers-$(uname -r)
```

Or, on RHEL-like distributions:

```bash
yum -y install kernel-devel-$(uname -r)
```

## Deploy SysFlow

Three deployment configurations are described below: _local_ (collector-only), _S3_ (batch) export mode, and _rsyslog_ (stream) export mode. The local deployment stores collected traces on the local filesystem and the full stack deployments export the collected traces to a S3-compatible object storage server or streams SysFlow records to remote syslog server.

### Setup

Clone this repository and change directory as follows:

```bash
git clone https://github.com/sysflow-telemetry/sf-deployments.git
cd sf-deployments/docker
```

### Local collection probe only

This deployment will install the Sysflow collection probe only, i.e., without an exporter to an external data store (e.g., S3). See below for the deploytment of the full telemetry stack.

To start the telemetry probe (collector only):

```bash
docker-compose -f docker-compose.collector.yml up
```

> Tip: add container.type!=host to `FILTER` string located in `./config/.env.collector` to filter out host (non-containerized) events.

To stop the collection probe:

```bash
docker-compose -f docker-compose.collector.yml down
```

### S3 export deployment

This deployment configuration includes the SysFlow Collector and S3 Exporter.

<center>
    <img src="https://sysflow.readthedocs.io/en/latest/_static/SF_Collector_Exporter.png" width="45%" height="45%" />
    <figcaption>SysFlow agent deployed with telemetry data exported to S3-compliant object storage.</figcaption>
</center>

First, create the docker secrets used to connect to the S3 object store:

```bash
echo "<s3 access key>" > ./secrets/access_key
echo "<s3 secret key>" > ./secrets/secret_key
```

Then, configure the S3 endpoint in the exporter settings (default values point to a local minio object store described below). Exporter configuration is located in `./config/.env.exporter`. Collector settings can be changed in `./config/.env.collector`. Additional settings can be configured directly in compose file.

To start the telemetry stack:

```bash
docker-compose -f docker-compose.exporter.yml up
```

To start the telemetry stack with a local minio object store:

```bash
docker-compose -f docker-compose.minio.yml -f docker-compose.exporter.yml up
```

To stop the telemetry stack:

```bash
docker-compose -f docker-compose.exporter.yml down
```

To stop the local minio instance and the telemetry stack:

```bash
docker-compose -f docker-compose.minio.yml -f docker-compose.exporter.yml down
```

### RSyslog export deployment with edge processing

This deployment configuration includes the SysFlow Collector and Processor with rsyslog exporter.

<center>
    <img src="https://sysflow.readthedocs.io/en/latest/_static/SF_Collector_Processor.png" width="45%" height="45%" />
    <figcaption>SysFlow agent deployed with telemetry data exported to a rsyslog collector.</figcaption>
</center>

First, configure the rsyslog endpoint in the processor settings. Processor configuration is located in `./config/.env.processor`. Collector settings can be changed in `./config/.env.collector`. Additional settings can be configured directly in compose file.

To start the telemetry stack:

```bash
docker-compose -f docker-compose.processor.yml up                                
```

To stop the telemetry stack:

```bash
docker-compose -f docker-compose.processor.yml down
```

## Sysflow trace inspection

Run `sysprint` and point it to a trace file. In the examples below, `sysprint` is an alias for:

```bash
docker run --rm -v /mnt/data:/mnt/data sysflowtelemetry/sysprint
```

### Tabular output

```bash
sysprint /mnt/data/<trace name>
```

### JSON output

```bash
sysprint -o json /mnt/data/<trace name>
```

### CSV output

```bash
sysprint -o csv /mnt/data/<trace name>
```

### Inspect traces exported to an object store

```bash
sysprint -i s3 -c <s3_endpoint> -a <s3_access_key> -s <s3_secret_key> <bucket_name>
```

> Tip: see all options of the `sysprint` utility with `-h` option.

### Inspect example traces

Sample trace files are provided in `tests`. Copy them into `/mnt/data` to inspect inside sysprint's environment.

```bash
sysprint /mnt/data/tests/client-server/tcp-client-server.sf
```

> Tip: other samples can be found in the tests directory

## Analyzing collected traces

A [Jupyter environment](https://hub.docker.com/r/sysflowtelemetry/sfnb) is also available for inspecting and implementing analytic notebooks on collected SysFlow data. It includes APIs for data manipulation using Pandas dataframes and a native query language (`sfql`) with macro support. To start it locally with example notebooks, run:

```bash
git clone https://github.com/sysflow-telemetry/sf-apis.git && cd sf-apis
docker run --rm -d --name sfnb --user $(id -u):$(id -g) --group-add users -v $(pwd)/pynb:/home/jovyan/work -p 8888:8888 sysflowtelemetry/sfnb
```

Then, open a web browser and point it to `http://localhost:8888` (alternatively, the remote server name or IP where the notebook is hosted). To obtain the notebook authentication token, run `docker logs sfnb`.
