### Create docker secrets
If the node isn't part of a docker swarm, initialize one (required for secrets):
> sudo docker swarm init --advertise-addr <local interface (e.g., 10.x)>

Create the docker secrets used to connect to the object store:
> ./secrets

### Start telemetry stack 
> ./start researchportal 

### Stop telemetry stack
> ./stop
