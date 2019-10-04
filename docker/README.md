## Docker Telemetry Stack
This repository contains utility scripts to deploy a local Sysflow telemetry stack.

#### Deployment
A _local_ and a _full stack_ deployment models are described below. The local deployment stores collected traces on the local filesystem and the full stack deployment exports the collected traces to a S3-compatible object storage server. 

#### Prerequisites
To guarantee a smooth deployment, the kernel headers must be installed in the host operating system.

This can usually be done on Debian-like distributions with:
```
apt-get -y install linux-headers-$(uname -r)
```
Or, on RHEL-like distributions:
```
yum -y install kernel-devel-$(uname -r)
```
#### Add private registry certificate to docker client
This step enables docker to pull the required images from the private registry in IRIS:
```
sudo mkdir -p /etc/docker/certs.d/floripa.sl.cloud9.ibm.com
sudo cp ca.crt /etc/docker/certs.d/floripa.sl.cloud9.ibm.com/ca.crt
```

### Local telemetry deployment (collection probe only)

#### Start telemetry probe 
```
./start_probe 
```
> Tip: add container.type!=host to FILTER string located inside this script to filter out host (non-containerized) events.
#### Stop telemetry  probe
```
./stop_probe
```

#### RSyslog exporter
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
### Full telemetry stack deployment (collector probe and S3 exporter)
> Note: skip this if deploying locally.

#### Create docker secrets
If the node (host) isn't part of a docker swarm, initialize a local one (required for docker secrets):
```
sudo docker swarm init --advertise-addr <local interface (e.g., 10.x)>
```
Create the docker secrets used to connect to the object store:
```
printf "<cos access key>" | sudo docker secret create cos_access_key -
printf "<cos secret key>" | sudo docker secret create cos_secret_key -
```
#### Start telemetry stack
```
./start <exporter_name> 
```
#### Stop telemetry stack
```
./stop
```

### Interactive testing environment for trace inspection

#### Start and enter testing environment
Execute the script below from the root directory of this repository.
```
./test
```

To inspect locally collected traces:
```
sysprint /mnt/data/<trace name>
```

To inspect sample traces (this particular sample is a slice of our Think 2019 node.js express attack demo; other samples can be found in the tests directory):
```
sysprint tests/attacks/2018-07-16/mon.1531776712.sf

To inspect traces exported to an object store:
```
sysprint -i cos -c <cos_endpoint> -a <cos_access_key> -s <cos_secret_key> <bucket_name>
```

For more usage and formatting options:
```
sysprint -h
```


