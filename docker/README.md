# Docker

## Introduction

This repository contains utility scripts to deploy a docker telemetry stack.

### Deployment

Three deployment configurations are described below: _local_ (collector-only), _S3_ (batch) export mode, and _rsyslog_ (stream) export mode. The local deployment stores collected traces on the local filesystem and the full stack deployments export the collected traces to a S3-compatible object storage server or streams SysFlow records to remote syslog server.

### Pre-requisites

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

### Setup

Clone this repository and change directory as follows:

```bash
git clone git@github.com:sysflow-telemetry/sf-deployments.git
cd sf-deployments/docker
```

## Local deployment: SysFlow collection probe only

This deployment will install the Sysflow collection probe only, i.e., without an exporter to an external data store (e.g., S3). See below for the deploytment of the full telemetry stack.

### Start the collection probe

Start the telemetry probe, which will be ran in a container.

> Tip: add container.type!=host to `FILTER` string located inside this script to filter out host (non-containerized) events.

```bash
docker-compose -f docker-compose.collector.yml up
```

### Stop the collection probe

```bash
docker-compose -f docker-compose.collector.yml down
```

## S3 export deployment

This deployment configuration includes the SysFlow Collector and S3 Exporter

<center>
    <img src="https://sysflow.readthedocs.io/en/latest/_static/SF_Collector_Exporter.png" width="45%" height="45%" />
    <figcaption>SysFlow agent deployed with telemetry data exported to S3-compliant object storage.</figcaption>
</center>

### Create docker secrets for S3 authentication

Create the docker secrets used to connect to the S3 object store:

```bash
echo "<s3 access key>" > ./secrets/access_key
echo "<s3 secret key>" > ./secrets/secret_key
```

### Start the telemetry stack

To start the telemetry stack:

> Note: edit the compose file directly for additional settings.

```bash
docker-compose -f docker-compose.exporter.yml 
               -e EXPORTER\_ID=<hostname|any other name>
               -e NODE\_IP=<host IP>
               -e S3\_ENDPOINT=<S3 URL|IP> 
               -e S3\_PORT=<S3 port> 
               -e S3\_LOCATION=<S3 location> 
               -e S3\_BUCKET=<S3 bucket> 
               -e SECURE=<true|false> up
```

To start the telemetry stack with a local minio object store:

```bash
docker-compose -f docker-compose.minio.yml -f docker-compose.exporter.yml 
               -e EXPORTER\_ID=$HOSTNAME
               -e NODE\_IP="localhost"
               -e S3\_ENDPOINT="minio" 
               -e S3\_PORT=9000
               -e S3\_LOCATION="local" 
               -e S3\_BUCKET="sysflow"
               -e SECURE="false" up
```

### Stop telemetry stack

To stop the telemetry stack:

```bash
docker-compose -f docker-compose.exporter.yml down
```

To stop the local telemetry stack:

```bash
docker-compose -f docker-compose.minio.yml -f docker-compose.exporter.yml down
```

## RSyslog export deployment with edge processing capabilities

This deployment configuration includes the SysFlow Collector and Processor with rsyslog exporter

<center>
    <img src="https://sysflow.readthedocs.io/en/latest/_static/SF_Collector_Processor.png" width="45%" height="45%" />
    <figcaption>SysFlow agent deployed with telemetry data exported to a rsyslog collector.</figcaption>
</center>

### Start the telemetry stack

To start the telemetry stack:

> Note: edit the compose file directly for additional settings.

```bash
docker-compose -f docker-compose.processor.yml 
               -e EXPORTER\_ID=<hostname|any other name>
               -e NODE\_IP=<host IP>
               -e EXPORTER\_SOURCE=<hostname|any other name> 
               -e EXPORTER\_HOST=<rsyslog host IP> 
               -e EXPORTER\_PORT=<rsyslog port (e.g., 514)> 
               -e EXPORTER\_PROTO=<udp|tcp|tcp+tls (e.g., tcp)>                                
```

### Stop telemetry stack

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

## Inspect example traces

Sample trace files are provided in `tests`. Copy them into `/mnt/data` to inspect inside sysprint's environment.

```bash
sysprint /mnt/data/tests/client-server/tcp-client-server.sf
```

> Tip: other samples can be found in the tests directory