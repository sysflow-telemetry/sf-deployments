# Docker

## Introduction
This repository contains utility scripts to deploy a docker telemetry stack.

### Deployment
A _local collection_ (Option 1), a _full stack with s3 object storage_ (Option 2) and _full stack with rsyslog_ (Option 3) deployment models are described below. The local deployment stores collected traces on the local filesystem and the full stack deployment exports the collected traces to a S3-compatible object storage server or remote syslog server. 

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
### One line command deployment with local collection
This deployment will install the Sysflow collection probe and stores collected traces on the local filesystem. There are 2 parameters for local collection deployment.
- --exptype : the export type (default: local-avro)
- --tag : the tag of docker image for collector
#### Start local collection
```
curl -s https://raw.githubusercontent.com/sysflow-telemetry/sf-deployments/master/docker/install-docker | bash -s - (--exptype local-avro) up
```
#### Stop local collection
```
curl -s https://raw.githubusercontent.com/sysflow-telemetry/sf-deployments/master/docker/install-docker | bash -s - (--exptype local-avro) down
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
If exporting to a remote object store, modify the exporter settings in `docker-compose.yml`, then run:
```
docker-compose -f docker-compose.yml up
```
### Stop telemetry stack (external object store)
```
docker-compose -f docker-compose.yml down
```
### One line command deployment with s3 object storage
This deployment will install the full stack including collector and exporter and exports the collected traces to a S3-compatible object storage server locally or remotely.
There are some parameters for full stack deployment with s3 object storage
- --exptype : the export type 
- --ip : the ip address of remote s3 object storage server
- --port : the port number of remote s3 object storage server (default: 9000)
- --s3tag : the tag of docker image for minio (s3 object storage deployed locally)
- --s3tls : Enable/Disable secure connection to remote s3 object storage (default: disable)
- --acckey : Specify the access key for s3 object storage
- --seckey : Specify the secret key for s3 object storage

#### Start full stack with s3 object storage
```
curl -s https://raw.githubusercontent.com/sysflow-telemetry/sf-deployments/master/docker/install-docker | bash -s - --exptype s3-avro --acckey [your s3 access key] --seckey [your s3 secret key] up
```
or you could export collected traces to remote s3 object storage server
```
curl -s https://raw.githubusercontent.com/sysflow-telemetry/sf-deployments/master/docker/install-docker | bash -s - --exptype s3-avro --ip 1.2.3.4 --acckey [your s3 access key] --seckey [your s3 secret key] up
```
#### Stop full stack with s3 object storage
```
curl -s https://raw.githubusercontent.com/sysflow-telemetry/sf-deployments/master/docker/install-docker | bash -s - --exptype s3-avro down
```

## Option 3: Full stack with rsyslog : One line command deployment with remote syslog server
This deployment will install the Sysflow collection probe and exporter, exports the data to remote syslog server as well.  You could specify 3 parameters for deployment:
- --exptype : the export type
- --ip : ip address of remote syslog server
- --port : port number of remote syslog server (Default: 514)
- --tag : the tag of docker images for collector and exporter (Default: latest)

See below for the deploytment of the local full telemetry stack.

### Start local telemetry stack

List 2 scenarios for local full telemetry stack deployment

##### Specify remote syslog server
You have to specify your remote syslog server ip address (port is 514 and tag is latest by default)
```
curl -s https://raw.githubusercontent.com/sysflow-telemetry/sf-deployments/master/docker/install-docker | bash -s - --exptype syslog --ip 1.2.3.4 up
```

##### Install images with specific tag (optional)
You have to specify the tag value
```
curl -s https://raw.githubusercontent.com/sysflow-telemetry/sf-deployments/master/docker/install-docker | bash -s - --exptype syslog --ip 1.2.3.4 --tag 0.1-rc3 up
```

### Stop local telemetry stack
```
curl -s https://raw.githubusercontent.com/sysflow-telemetry/sf-deployments/master/docker/install-docker | bash -s - --exptype syslog down
```

## Sysflow trace inspection
Run `sysprint` and point it to a trace file. In the examples below, `sysprint` is an alias for:
```
docker run --rm -v /mnt/data:/mnt/data sysflowtelemetry/sysprint
```
### Tabular output
```
sysprint /mnt/data/<trace name>
```

### JSON output
```
sysprint -o json /mnt/data/<trace name>
```

### CSV output
```
sysprint -o csv /mnt/data/<trace name>
```

### Inspect traces exported to an object store:
```
sysprint -i s3 -c <s3_endpoint> -a <s3_access_key> -s <s3_secret_key> <bucket_name>
```

> Tip: see all options of the `sysprint` utility with `-h` option.

## Inspect example traces
Sample trace files are provided in `tests`. Copy them into `/mnt/data` to inspect inside sysprint's environment.
```
sysprint /mnt/data/tests/client-server/tcp-client-server.sf
```

> Tip: other samples can be found in the tests directory

