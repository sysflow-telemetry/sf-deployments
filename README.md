## Sysflow Telemetry Stack
This repository contains utility scripts to deploy a local Sysflow telemetry stack.

## Deployment Instructions

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
#### Create docker secrets
If the node (host) isn't part of a docker swarm, initialize a local one (required for docker secrets):
```
sudo docker swarm init --advertise-addr <local interface (e.g., 10.x)>
```
Create the docker secrets used to connect to the object store:
```
./secrets
```
### Start telemetry stack 
```
./start rschportal 
```
#### Stop telemetry stack
```
./stop
```
