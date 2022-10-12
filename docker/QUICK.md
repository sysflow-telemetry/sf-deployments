# Quick Start

We encourage you to check the documentation first, but here are a few tips for a quick start.

### Deployment options

The SysFlow agent can be deployed in batch or edge processing export configurations. In the batch configuration, SysFlow exports the collected telemetry as trace files (batches of SysFlow records) to any S3-compliant object storage service.

<center>
    <img src="https://sysflow.readthedocs.io/en/latest/_static/SF_Collector_Exporter.png" width="45%" height="45%" />
</center>

In edge processing configuration, SysFlow exports the collected telemetry as events streamed to a rsyslog collector or Elasticsearch. This deployment enables the creation of customized edge pipelines, and offers a built-in policy engine to filter, enrich, and alert on SysFlow records.

<center>
    <img src="https://sysflow.readthedocs.io/en/latest/_static/SF_Collector_Processor.png" width="45%" height="45%" />
</center>

Instructions for `Docker Compose`, `Helm`, and `binary package` deployments of complete SysFlow stacks are available [here](https://sysflow.readthedocs.io/en/latest/deploy.html).

### Inspecting collected traces

A [command line utilitiy](https://hub.docker.com/r/sysflowtelemetry/sysprint) is provided for inspecting collected traces or convert traces from SysFlow's compact binary format into human-readable JSON or CSV formats.

```bash
docker run --rm -v /mnt/data:/mnt/data sysflowtelemetry/sysprint /mnt/data/<trace>
```

where `trace` is the the name of the trace file inside `/mnt/data`. If empty, all files in `/mnt/data` are processed. By default, the traces are printed to the standard output with a default set of SysFlow attributes. For a complete list of options, run:

```bash
docker run --rm -v /mnt/data:/mnt/data sysflowtelemetry/sysprint  -h
```

This command line tool can also be installed directly on the host using pip.

```bash
python3 -m pip install sysflow-tools
```

### Analyzing collected traces

A [Jupyter environment](https://hub.docker.com/r/sysflowtelemetry/sfnb) is available for inspecting and implementing analytic notebooks on collected SysFlow data. It includes APIs for data manipulation using Pandas dataframes and a native query language (`sfql`) with macro support. To start it locally with example notebooks, run:

```bash
git clone https://github.com/sysflow-telemetry/sf-apis.git && cd sf-apis
docker run --rm -d --name sfnb -v $(pwd)/pynb:/home/jovyan/work -p 8888:8888 sysflowtelemetry/sfnb
```

Then, open a web browser and point it to `http://localhost:8888` (alternatively, the remote server name or IP where the notebook is hosted). To obtain the notebook authentication token, run `docker logs sfnb`.
