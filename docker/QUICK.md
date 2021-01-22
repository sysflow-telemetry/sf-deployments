# Quick Start

We encourage you to check the documentation first, but here are a few tips for a quick start.

### Starting the collection probe

The easiest way to run the SysFlow collector is from a Docker container, with host mount for the output trace files. The following command shows how to run sf-collector with trace files exported to `/mnt/data` on the host.

```bash
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

### Deployment options

The SysFlow agent can be deployed in S3 (batch) or rsyslog (edge processing) export configurations. In the batch configuration, SysFlow exports the collected telemetry as trace files (batches of SysFlow records) to any S3-compliant object storage service.

<center>
    <img src="https://sysflow.readthedocs.io/en/latest/_static/SF_Collector_Exporter.png" width="45%" height="45%" />
    <figcaption>SysFlow agent deployed with telemetry data exported to S3-compliant object storage.</figcaption>
    <br>
</center>

In edge processing configuration, SysFlow exports the collected telemetry as events streamed to a rsyslog collector. This deployment enables the creation of customized edge pipelines, and offers a built-in policy engine to filter, enrich, and alert on SysFlow records.

<center>
    <img src="https://sysflow.readthedocs.io/en/latest/_static/SF_Collector_Processor.png" width="45%" height="45%" />
    <figcaption>SysFlow agent deployed with telemetry data exported to a rsyslog collector.</figcaption>
    <br>
</center>

Instructions for `Docker Compose`, `Helm`, and `OpenShift` deployments of complete SysFlow stacks are available [here](https://sysflow.readthedocs.io/en/latest/deploy.html).

### Inspecting collected traces

A [command line utilitiy](https://hub.docker.com/r/sysflowtelemetry/sysprint) is provided for inspecting collected traces or convert traces from SysFlow's compact binary format into human-readable JSON or CSV formats.

```bash
docker run --rm -v /mnt/data:/mnt/data sysflowtelemetry/sysprint /mnt/data/<trace> 
```

where `trace` is the the name of the trace file inside `/mnt/data`. If empty, all files in `/mnt/data` are processed. By default, the traces are printed to the standard output with a default set of SysFlow attributes. For a complete list of options, run:

```bash
docker run --rm -v /mnt/data:/mnt/data sysflowtelemetry/sysprint  -h
```

### Analyzing collected traces

A [Jupyter environment](https://hub.docker.com/r/sysflowtelemetry/sfnb) is also available for inspecting and implementing analytic notebooks on collected SysFlow data. It includes APIs for data manipulation using Pandas dataframes and a native query language (`sfql`) with macro support. To start it locally with example notebooks, run:

```bash
git clone https://github.com/sysflow-telemetry/sf-apis.git && cd sf-apis
docker run --rm -d --name sfnb --user $(id -u):$(id -g) --group-add users -v $(pwd)/pynb:/home/jovyan/work -p 8888:8888 sysflowtelemetry/sfnb
```

Then, open a web browser and point it to `http://localhost:8888` (alternatively, the remote server name or IP where the notebook is hosted). To obtain the notebook authentication token, run `docker logs sfnb`.
