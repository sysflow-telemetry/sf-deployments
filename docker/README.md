# Sysflow Docker Telemetry Stack

## Introduction
This repository contains utility scripts to deploy a local Sysflow telemetry stack.

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
git clone git@github.ibm.com:sysflow/sf-deployments.git
cd sf-deployments/docker
```

### Add private registry certificate to docker client
This step enables docker to pull the required images from the private registry in IRIS:
```
sudo mkdir -p /etc/docker/certs.d/floripa.sl.cloud9.ibm.com
sudo cp ca.crt /etc/docker/certs.d/floripa.sl.cloud9.ibm.com/ca.crt
```

## Option 1: Local telemetry deployment: Sysflow collection probe only

This deployment will install the Sysflow collection probe only, i.e., without an exporter to a data store (e.g., COS).  See below for the deploytment of the full telemetry stack.

## Start telemetry probe 
Start the telemetry probe, which will be ran in a container.

> Tip: add container.type!=host to FILTER string located inside this script to filter out host (non-containerized) events.

```
./start_probe 
```

### Stop telemetry probe
```
./stop_probe
```

### RSyslog exporter (optional)
If exporting to rsyslog (e.g., QRadar), specify the IP and port of the remote syslog server:
```
sudo docker run --name sf-exporter \
    -e SYSLOG_HOST=<RSYSLOG IP> \
    -e SYSLOG_PORT=<RSYSLOG PORT> \
    -e NODE_IP=<EXPORTER HOST IP> \
    -e INTERVAL=15 \
    -e DIR=/mnt/data \
    --mount type=bind,source=/mnt/data,destination=/mnt/data \
    floripa.sl.cloud9.ibm.com/sf-exporter:latest
```

## Option 2: Full telemetry stack deployment: Sysflow collector probe and S3 exporter
> Note: skip this if deploying locally.

### Create docker secrets
If the node (host) isn't part of a docker swarm, initialize a local one (required for docker secrets):
```
sudo docker swarm init --advertise-addr <local interface (e.g., 10.x)>
```
Create the docker secrets used to connect to the object store:
```
printf "<cos access key>" | sudo docker secret create cos_access_key -
printf "<cos secret key>" | sudo docker secret create cos_secret_key -
```
### Start telemetry stack
```
./start <exporter_name> 
```
### Stop telemetry stack
```
./stop
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
./sysprint -i cos -c <cos_endpoint> -a <cos_access_key> -s <cos_secret_key> <bucket_name>
```

> Tip: see all options of the `sysprint` utility with `sysprint -h`

## Inspect example traces
Sample trace files are mounted into `/usr/local/sysflow/tests` inside sysprint's environment.
```
./sysprint /usr/local/sysflow/tests/client-server/tcp-client-server.sf
```

> Tip: other samples can be found in the tests directory

## Interactive test environment

### Start and enter testing environment
Execute the script below from the root directory of this repository.
```
./test
```


