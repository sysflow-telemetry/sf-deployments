# Quick Start
We encourage you to check the documentation first, but here are a few tips for a quick start.

### Starting the collection probe
The easiest way to run the SysFlow collector is from a Docker container, with host mount for the output trace files. The following command shows how to run sf-collector with trace files exported to `/mnt/data` on the host.

```
docker run -d --privileged --name sf-collector \
	     -v /var/run/docker.sock:/host/var/run/docker.sock \
	     -v /dev:/host/dev -v /proc:/host/proc:ro \
	     -v /boot:/host/boot:ro -v /lib/modules:/host/lib/modules:ro \
             -v /usr:/host/usr:ro -v /mnt/data:/mnt/data \
             -e INTERVAL=60 \
             -e EXPORTER_ID=${HOSTNAME} \
             -e OUTPUT=/mnt/data/    \
             -e FILTER="container.name!=sf-collector and container.name!=sf-exporter" \
             --rm sysflowtelemetry/sf-collector
```
where INTERVAL denotes the time in seconds before a new trace file is generated, EXPORTER\_ID sets the exporter name, OUTPUT is the directory in which trace files are written, and FILTER is the filter expression used to filter collected events. Note: append `container.type!=host` to FILTER expression to filter host events. 

Instructions for `docker compose` and `helm` deployments are available in [here](https://sysflow.readthedocs.io/en/latest/deploy.html).

### Inspecting collected traces
A [command line utilitiy](https://sysflow.readthedocs.io/en/latest/api-utils.html) is provided for inspecting collected traces or convert traces from SysFlow's compact binary format into human-readable JSON or CSV formats. 

```
docker run --rm -v /mnt/data:/mnt/data sysflowtelemetry/sysprint /mnt/data/<trace> 
```
where `trace` is the the name of the trace file inside `/mnt/data`. If empty, all files in `/mnt/data` are processed. By default, the traces are printed to 
standard output with a default set of SysFlow attributes. For a complete list of options, run:
```
docker run --rm -v /mnt/data:/mnt/data sysflowtelemetry/sysprint  -h
```
