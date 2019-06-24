## Sysflow Telemetry Stack
This repository contains utility scripts to deploy a local Sysflow telemetry stack.

## Deployment Instructions

#### Create docker secrets
If the node (host) isn't part of a docker swarm, initialize a local one (required for docker secrets):
> sudo docker swarm init --advertise-addr <local interface (e.g., 10.x)>

Create the docker secrets used to connect to the object store:
> ./secrets

#### Start telemetry stack 
> ./start 

#### Stop telemetry stack
> ./stop
