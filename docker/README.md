# Docker

## Introduction
This repository contains utility scripts to deploy a docker telemetry stack.

### Deployment
A _local collection_ (Option 1) and a _full stack_ (Option 2) deployment models are described below. The local deployment stores collected traces on the local filesystem and the full stack deployment exports the collected traces to a S3-compatible object storage server. 

### Prerequisites
To guarantee a smooth deployment, the kernel headers must be installed in the host operating system.

This can usually be done on Debian-like distributions with:
```
apt-get -y install linux-headers-$(uname -r)
```
Or, on RHEL-like distributions:
```
yum -y install kernel-devel-$(uname -r)
```

### Setup

Clone the repository and navigate to this directory.

```
git clone git@github.com:sysflow-telemetry/sf-deployments.git
cd sf-deployments/docker
```

## Option 1: Local telemetry deployment: Sysflow collection probe only

This deployment will install the Sysflow collection probe only, i.e., without an exporter to a data store (e.g., COS).  See below for the deploytment of the full telemetry stack.

## Start collection probe 
Start the telemetry probe, which will be ran in a container.

> Tip: add container.type!=host to FILTER string located inside this script to filter out host (non-containerized) events.

```
docker-compose -f docker-compose.collector.yml up
```

### Stop collection probe
```
docker-compose -f docker-compose.collector.yml down
```

### RSyslog exporter (optional)
If exporting to rsyslog (e.g., QRadar), specify the IP and port of the remote syslog server:
```
docker run --name sf-exporter \
    -e SYSLOG_HOST=<RSYSLOG IP> \
    -e SYSLOG_PORT=<RSYSLOG PORT> \
    -e NODE_IP=<EXPORTER HOST IP> \
    -e INTERVAL=15 \
    -e DIR=/mnt/data \
    -v /mnt/data:/mnt/data \
    sysflowtelemetry/sf-exporter:latest
```

## Option 2: Full telemetry stack deployment: Sysflow collector probe and S3 exporter
> Note: skip this if deploying locally.

### Create docker secrets
Create the docker secrets used to connect to the object store:
```
echo "<s3 access key>" > ./secrets/access_key
echo "<s3 secret key>" > ./secrets/secret_key
```
### Start telemetry stack (with local object store)
```
docker-compose -f docker-compose.minio.yml -f docker-compose.yml up
```
### Stop telemetry stack (with local object store)
```
docker-compose -f docker-compose.minio.yml -f docker-compose.yml down
```
### Start telemetry stack (external object store)
If exporting to a remote object store, modify the exporter settings in `docker-compose.yml` and run:
```
docker-compose -f docker-compose.yml up
```
### Stop telemetry stack (external object store)
```
docker-compose -f docker-compose.yml down
```

## Sysflow trace inspection
Run the `sysprint` script and point it to a trace file.

### Tabular output
```
./sysprint /mnt/data/<trace name>
```

### JSON output
```
./sysprint -o json /mnt/data/<trace name>
```

### CSV output
```
./sysprint -o csv /mnt/data/<trace name>
```

### Inspect traces exported to an object store:
```
./sysprint -i s3 -c <s3_endpoint> -a <s3_access_key> -s <s3_secret_key> <bucket_name>
```

> Tip: see all options of the `sysprint` utility with `sysprint -h`

## Inspect example traces
Sample trace files are mounted into `/usr/local/sysflow/tests` inside sysprint's environment.
```
./sysprint /usr/local/sysflow/tests/client-server/tcp-client-server.sf
```

> Tip: other samples can be found in the tests directory
