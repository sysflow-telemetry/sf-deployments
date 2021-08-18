# SysFlow ELK Integration

This integration shows how to use [SysFlow](https://sysflow.readthedocs.io/en/latest/index.html)
to monitor on-premise and cloud workloads, and collect security analytics 
data using its ElasticSearch connector. SysFlow detects potentially
malicious activity in container environments, such as Docker, Kubernetes, and
RedHat OpenShift, by collecting evidence data and extracting indicators of
compromise. 

In this example deployment, we will:

- collect telemetry events exposed by running containers,
- apply polices on the raw events and generate alerts,
- translate both alerts and raw events to Elastic Common Schema (ECS), and 
- store the results in ELK for flexible querying with ElasticSearch and
  visualization using Kibana.

Speaking in terms of [MITRE ATT&CK&reg;](https://attack.mitre.org)
[tactics](https://attack.mitre.org/tactics/enterprise/), we skip the Initial
Access phase and focus mainly on [Discovery](https://attack.mitre.org/tactics/TA0007/)
and [Command and Control](https://attack.mitre.org/tactics/TA0011/) techniques
in this use case. We assume a point in time at which an attacker
has already established a foothold on the system and can execute commands.
The attacker will then try to perform reconnaissance over the environment 
or to install additional tools required for the attack. The telemetry stack
makes these steps visible by generating alerts for characteristic commands
(e.g., displaying the contents of `/etc/passwd` or downloading files), or
providing access to the full telemetry data for event correlation.

We start with a tutorial on how to install and run this telemetry stack, and 
analyze the collected data using ELK. This is followed by more technical 
discussion that provides the details of our setup and explaination of 
the individual processing steps.


## Prerequisites 

Ubuntu 20.04 system with docker 20.10.2 and docker-compose version 1.25.0 pre-installed on the machine.

## Setup

First, clone this git repository and enter the working directory for the ELK integration.

```shell
git clone https://github.com/sysflow-telemetry/sf-deployments.git
cd sf-deployments/integrations/elk
```

Directories and file paths shown below are relative to this working directory.

## Build

Our setup consists of 

- [Anthony Lapenna's](https://github.com/deviantony)
  [ELK Stack on Docker](https://github.com/deviantony/docker-elk/tree/tls).
  We will use the `tls` branch, which provides a TLS-enabled instance of
  ElasticSearch. We will run only two containers from this package,
  ElasticSearch and Kibana. Both components use the
  [ELK stack's default credentials](https://github.com/deviantony/docker-elk/tree/tls#setting-up-user-authentication).
  Logstash has been disabled for the purpose of this setup. The scripts
  for running the ELK stack is in the directory `elk`.
- The [SysFlow telemetry pipeline](https://sysflow.readthedocs.io/en/latest/)
  consisting of the [SysFlow Collector](https://github.com/sysflow-telemetry/sf-collector)
  and the [SysFlow Processor](https://github.com/sysflow-telemetry/sf-processor).
  Both components will run as docker containers. The scripts for running the
  SysFlow pipeline is in the directory `sf`.
- A custom-made attack container, which plays the part of an attacker
  running discovery commands. The code for running the attacker is in the
  directory `attack`.

We use `make` to control building, running, stopping and cleaning up the
repository. The main `Makefile` resides in root of the working directory. 
There are dedicated Makefiles in all sub-directories. Every Makefile 
supports five targets:

- `build` for compiling code and fetching and building docker images,
- `run` for running the demonstrator,
- `stop` for stopping the containers, and
- `clean` for deleting the containers and removing the docker images.

You can control each component separately by using `make` in the
corresponding sub-directory.

If you want to use the built-in ELK stack, you can install all components
by running a single command:

```shell
make build
```

We also support ingestion into an existing external Elastic cluster. For
more information please refer to the section on
[using an external Elastic cluster](#using-an-external-elastic-cluster).


## Deployment

This example deploys a SysFlow pipeline that collects telemetry data and
produces a stream of alerts and another stream of raw SysFlow events. The
pipeline translates the data from both streams to ECS, and writes the result to
two separate ElasticSearch indices, which can be viewed using Kibana. To start
the example scenario, run:

```shell
make run
```

This command starts all necessary docker containers and you should see
an output like this:

```
$ make run
make -C elk run
make[1]: Entering directory '.../SysFlow-ELK-Demonstrator/elk'
cd docker-elk && docker-compose up -d
Creating network "docker-elk_elk" with driver "bridge"
Creating docker-elk_elasticsearch_1 ... done
Creating docker-elk_kibana_1        ... done
Waiting for ElasticSearch .........
Created index 'sysflow-alerts'
Created index 'sysflow-events'
make[1]: Leaving directory '.../SysFlow-ELK-Demonstrator/elk'
make -C sf run
make[1]: Entering directory '.../SysFlow-ELK-Demonstrator/sf'
docker-compose up -d
Creating sf-processor ... done
Creating sf-collector ... done
make[1]: Leaving directory '.../SysFlow-ELK-Demonstrator/sf'
make -C attack run
make[1]: Entering directory '.../SysFlow-ELK-Demonstrator/attack'
docker rm attack 2>/dev/null || true
docker run --name attack attack > result.txt
Waiting...
Step 1
Step 2
Step 3
Step 4
Step 5
Step 6
make[1]: Leaving directory '.../SysFlow-ELK-Demonstrator/attack'
```

## Data Analysis

There are two types of results, alerts and raw events, which can be viewed using Kibana.

### Alerts

The telemetry stack generates alerts enriched with MITRE ATT&CK&reg; technique tags
and alert reasons. By default, the example telemetry stack writes these alerts into an
ElasticSearch index `sysflow-alerts`. To view the alert in this index, direct
your browser to Kibana at `http://localhost:5601`. Log in using the ELK
default credentials. 

Kibana requires an index pattern to view data from ElasticSearch
indices. If there's no index pattern yet, you are requested to
create one. You can either click on the __Create index pattern__ button and
step through the wizard, or use the following command to create an index
pattern tailored to the SysFlow ECS data.

```shell
curl -u "<ELK username>:<ELK password>" -XPOST http://localhost:5601/api/saved_objects/index-pattern -H 'Content-Type: application/json' -H 'kbn-version: 7.13.2' -d '{"attributes":{"title":"sysflow-alerts","timeFieldName":"event.start", "fieldFormatMap":"{\"event.start\":{\"id\":\"date_nanos\"}}"}}'
```

Once you have created the index pattern, proceed to the __Discover__ pane by
clicking on the menu in the upper left corner. On the __Discover__ pane,
select the `sysflow-alerts` index pattern in the __Change Index Pattern__
field in the upper left. In the upper right corner next to the __Refresh__
button set the time range appropriately, e.g., to `Last 15 minutes`. In the
__Available fields__ box on the left select the alert fields you want to see.
To get started, inspect `event.reason`, `tags`, and
`process.command_line`. You should see SysFlow alerts as shown in the
picture below.

![Kibana visualization of the alerts index](images/alerts.png?raw=true "Kibana visualization of the alerts index")

### Raw Events

Concurrent to alert generation, the telemetry stack also translates raw
SysFlow events to ECS records and stores them in an index `sysflow-events`.
You also need an index pattern to render data from this index. We suggest to
follow the procedure described in the [Alerts section](#alerts)
to create a separate index pattern `sysflow-events`. Once created, this index
pattern appears in the select box on Kibona's __Discover__ pane.

The ECS records in the `sysflow-events` index contain many different
attributes. The set of available attributes depends on the type of the event
(`event.sf_type`). For more details on SysFlow events and their types see the
[SysFlow Specification](https://sysflow.readthedocs.io/en/latest/spec.html#sysflow-specification)
In the __Available fields__ box on the left you can select any suitable
combination of attributes to display. A sample picture of the events index
is shown below.

![Kibana visualization of the events index](images/events.png?raw=true "Kibana visualization of the events index")


## Stop

After running the example scenario, don't forget to stop it. You can stop the 
entire stack by running:

```shell
make stop
```

This command produces an output like this:

```
$ make stop
make -C attack stop
make[1]: Entering directory '.../SysFlow-ELK-Demonstrator/attack'
docker rm attack 2>/dev/null || true
attack
make[1]: Leaving directory '.../SysFlow-ELK-Demonstrator/attack'
make -C sf stop
make[1]: Entering directory '.../SysFlow-ELK-Demonstrator/sf'
docker-compose --env-file .env.alerts down
Stopping sf-collector ... done
Stopping sf-processor ... done
Removing sf-collector ... done
Removing sf-processor ... done
Network docker-elk_elk is external, skipping
make[1]: Leaving directory '.../SysFlow-ELK-Demonstrator/sf'
make -C elk stop
make[1]: Entering directory '.../SysFlow-ELK-Demonstrator/elk'
cd docker-elk && docker-compose down
Stopping docker-elk_kibana_1        ... done
Stopping docker-elk_elasticsearch_1 ... done
Removing docker-elk_kibana_1        ... done
Removing docker-elk_elasticsearch_1 ... done
Removing network docker-elk_elk
make[1]: Leaving directory '.../SysFlow-ELK-Demonstrator/elk'
```

If you want to keep using some components, you can stop the components
individually. If, for example, you want to leave the ELK stack operational
simply run

```shell
make -C attack stop
make -C sf stop
```

Note that that the top-level Makefile also offers a convenience target `halt`
for this particular sequence of commands.

```shell
make halt
```

## Architecture

In total, we have 5 containers that participate in this ecosystem. If you run `docker ps`
during the execution of the attack, you'll see a list similar to this:

```
docker ps
CONTAINER ID   IMAGE                                  COMMAND                  CREATED          STATUS          PORTS                                            NAMES
afa4d59b91d9   attack                                 "/bin/sh ./attack.sh"    15 seconds ago   Up 14 seconds                                                    attack
99359e4319dc   sysflowtelemetry/sf-collector:edge     "/usr/local/sysflow/…"   16 seconds ago   Up 15 seconds                                                    sf-collector
18e63478b422   sysflowtelemetry/sf-processor:edge     "/bin/sh -c '/usr/lo…"   17 seconds ago   Up 16 seconds                                                    sf-processor
c2cbe4ed7457   docker-elk_kibana                      "/bin/tini -- /usr/l…"   2 hours ago      Up 2 hours      0.0.0.0:5601->5601/tcp                           docker-elk_kibana_1
663704cdbf59   docker-elk_elasticsearch               "/bin/tini -- /usr/l…"   2 hours ago      Up 2 hours      0.0.0.0:9200->9200/tcp, 0.0.0.0:9300->9300/tcp   docker-elk_elasticsearch_1
```

The docker-elk containers originate from the ELK stack. They were started
by docker-compose. The sf containers originate from the SysFlow stack.
They were also started by docker-compose. These four containers are
attached to one docker network `docker-elk` that was created by the ELK
stack installation procedure. Thus, the SysFlow processor can "see" the
ElasticSearch endpoint under its container name in docker and we didn't
have to provide an external address. 

These containers collaborate as illustrated in the picture below.

![Architecture of the demonstrator](images/pipeline.png?raw=true "Architecture of the demonstrator")

Each container has its dedicated purpose:

1) [attack](attack) simply runs the attack by performing some discovery
   commands with some time delay in between. These commands are specified in
   the shell script `attack/attack.sh` which acts as the container's entry
   point. The result of the attack \(stdout of this script\) is written to the
   file `attack/result.txt`.
2) [sf-collector](https://sysflow.readthedocs.io/en/latest/collector.html)
   monitors and collects system call and event information from containers and
   exports them in the SysFlow format using Apache Avro object serialization.
   In our case, the collector applies a first-stage filtering specified via 
   its `FILTER` environment varibale in [sf/docker-compose.yml](sf/docker-compose.yml). The
   condition is read from the environment definitions in [sf/.env](sf/.env).
   This filter suppresses all events pertaining to the docker host, the
   SysFlow containers or the ELK containers. The collector forwards the
   detected events to the processor using a UNIX domain socket that is
   mounted to both containers using a shared volume.
3) [sf-processor](https://sysflow.readthedocs.io/en/latest/processor.html) is a
   lightweight edge analytics pipeline that can process and enrich SysFlow data.
   The processor's behavior is defined in a pipeline specification consisting
   of a set of built-in and custom plugins and drivers. Our pipeline performs
   rule-base alert generation and enrichment with MITRE tags. Its endpoint
   encodes the data in ECS and ingests them into ElasticSearch. We'll describe
   this pipeline in detail below.
4) [docker-elk\_elasticsearch\_1](https://github.com/deviantony/docker-elk/tree/tls#how-to-configure-elasticsearch)
   is a single-node instance of ElasticSearch provided by the ELK Stack on docker.
5) [docker-elk\_kibana\_1](https://github.com/deviantony/docker-elk/tree/tls#how-to-configure-kibana)
   is the Kibana front-end provided by the ELK stack on docker.


## The processor pipeline

At the core of this integration is the SysFlow processor. The SysFlow processor
is a highly configurable edge processing engine that reads data provided by 
the collector and sends them through a pipeline to the final destination. The behavior is
controlled by a pipeline specification.

The pipeline specification is a JSON document that consists of several plugins
and describes how these plugins are connected to each other by channels to form
a pipeline. In our case this document describes a processing tree rather than a
pipeline. This is because each plugin can feed more than one output channel. In
this deployment, this fan-out is performed by the SysFlow reader which feeds two
policy engines which in turn serve two exporters.

The definition of the processor pipeline for this example deployment is given below.
The pipeline file is specified in the `CONFIG_PATH` environment variable of the
`sf-processor` service in [sf/docker-compose.yml](sf/docker-compose.yml)
The definition can be found in [sf/resources/pipelines/pipeline.tee.elk.json](sf/resources/pipelines/pipeline.tee.elk.json).

```json
{
    "pipeline":[
      {
       "processor": "sysflowreader",
       "handler": "flattener",
       "in": "sysflow sysflowchan",
       "out": ["flat flattenerchan", "flatraw flattenerchan"]
      },
      {
       "processor": "policyengine",
       "in": "flat flattenerchan",
       "out": "evt eventchan",
       "mode": "alert",
       "policies": "/usr/local/sysflow/resources/elk/policies/ttps.yaml"
      },
      {
       "processor": "policyengine",
       "in": "flatraw flattenerchan",
       "out": "evtraw eventchan",
       "mode": "bypass"
      },
      {
       "processor": "exporter",
       "in": "evt eventchan",
       "export": "es",
       "format": "ecs",
       "es.addresses": "https://docker-elk_elasticsearch_1:9200",
       "es.index": "sysflow-alerts",
       "es.username": "elastic",
       "es.password": "changeme",
       "es.bulk.numWorkers": "1",
       "buffer": "50"
      },
      {
       "processor": "exporter",
       "in": "evtraw eventchan",
       "export": "es",
       "format": "ecs",
       "es.addresses": "https://docker-elk_elasticsearch_1:9200",
       "es.index": "sysflow-events",
       "es.username": "elastic",
       "es.password": "changeme",
       "es.bulk.numWorkers": "1",
       "buffer": "1000"
      }
    ]
}
```

Our pipeline consists of five plugins that form the tree mentioned above:

- `sysflowreader` is a generic reader plugin that ingests SysFlow from the
  driver, caches entities, and presents SysFlow objects to a handler object
  \(i.e., an object that implements the handler interface\) for processing.
  Our reader feeds two policy engines, one for generating alerts and a
  another one for passing on raw events.
- Each `policyengine` is a policy engine, which takes flattened \(row-oriented\)
  SysFlow records as input and output records. The first policy engine
  applies run-time rules from the [TTPS policy file](sf/resoources/policies/ttps.yaml)
  These rules are specified in Falco syntax. If they match,
  the engine creates alerts based on the SysFlow source events. The TTPS policies
  detect indicators of MITRE attack techniques. They enrich the alert with a
  reason string and attach the corresponding MITRE technique code. The second
  policy works in bypass mode just passing on output records without any
  intermediate processing.
- Each `exporter` reads records from its policy engine, encodes and exports them.
  Various export targets can be specified. In our case, both exporters convert
  to [Elastic Common Schema (ECS)](https://www.elastic.co/guide/en/ecs/1.7/ecs-field-reference.html)
  \(`"format": "ecs"`\) and export to the same ElasticSearch server
  (`"export": "es"`). The exporters write to different indices. Alerts are
  written to `sysflow-alerts`, raw events to `sysflow-events`. Note the
  address of the ElasticSearch endpoint: The processor can directly resolve
  the name of the container since it runs in the same docker network.
  Writing to ElasticSearch is done via bulk ingestion, and each exporter uses
  a specific bulk size. Please refer to the SysFlow processor documentation
  for further information on the `es.bulk` parameters. 

## Policy-based alert generation

The entry point of the [attack](attack) container in our setup is a
shell script that runs a couple of discovery commands similar to what a real
attacker would do after hacking into the system.

```shell
...
echo "Step 1" >&2
uname -a
echo
sleep 3

echo "Step 2 ">&2
df
echo
sleep 1

echo "Step 3" >&2
ps -ef
echo
sleep 2

echo "Step 4" >&2
ls /home
echo
sleep 3

echo "Step 5" >&2
cat /etc/passwd
echo
sleep 1

echo "Step 6" >&2
wget -c -P /tmp https://sysflow.readthedocs.io/en/latest/quick.html 2>&1
echo
```

It executes five discovery commands with some time delay in between and
downloads the [SysFlow quick start guide](https://sysflow.readthedocs.io/en/latest/quick.html) at the end. In the
fifth step, the `/etc/password` file is printed  to stdout which is a common
technique to discover other accounts on the system that could be targeted
in further attacks. SysFlow detects the start of the `cat` command and
generates a process event (PE). The PE record is quite rich of attributes
which provide additional information such as the exact point in time of the
event, the container in which the process was started, the full command
line and the pid of both the actual and the parent process, and the user
which executed the process.

All SysFlow event attributes are visible to the policy engine inside the
sf-processor container. The full list of
[SysFlow event attributes](https://sysflow.readthedocs.io/en/latest/processor.html#writing-runtime-policies)
can be found in the processor documentation. The policy engine evaluates
a set of policies whose conditions are predicate expressions over SysFlow
event attributes. One of the rules specified in the [TTPS policy file](sf/resoources/policies/ttps.yaml)
used in this deployment matches the PE event corresponding to the start
of the `cat` process:

```yaml
- list: discovery_cmds
  items: [cat, strings, nl, head, tail]

- list: sys_password_files
  items: [/etc/shadow, /etc/passwd]

- rule: Account Discovery: Local Account
  desc: attempt to get a listing of local system accounts
  condition: sf.opflags = EXEC and
             sf.proc.name in (discovery_cmds) and sf.proc.args in (sys_password_files)
  action: [tag]
  priority: high
  tags: [mitre:T1087.001]
  prefilter: [PE]
```

A PE event indicating the start of a process contains an `EXEC` value in its
opflags attribute. This is matched by the prefilter and the first part of the
condition. The rest of the rule condition covers some variants of printing
account information on the terminal. Our attack step `cat /etc/passwd`
is one of them.

If the condition matches the current event, the rule above generates an alert
with high priority which contains the original event attributes and some
enrichments such as the MITRE technique tag and the corresponding alert reason.
In our example the alert reason is the name of the MITRE technique specified as
the rule name. The exporter plugin of the processor converts this alert to ECS
before ingesting it into ElasticSearch. Here is the ECS record that gets
ingested as the result of the last attack step in our example.

```json
{
  "@timestamp" : "2021-07-01T09:36:22.467324952Z",
  "agent" : {
    "type" : "SysFlow",
    "version" : "4"
  },
  "ecs" : {
    "version" : "1.7.0"
  },
  "event" : {
    "action" : "process-start",
    "category" : "process",
    "duration" : 0,
    "end" : "2021-07-01T09:36:22.467324952Z",
    "kind" : "event",
    "reason" : "Account Discovery: Local Account",
    "severity" : 2,
    "sf_ret" : 0,
    "sf_type" : "PE",
    "start" : "2021-07-01T09:36:22.467324952Z",
    "type" : "start"
  },
  "container" : {
    "id" : "76841703e7e9",
    "image" :  {
      "id" : "6f8945d73bc8aee23e841db33688de19d2de3a63c775e634503661926cf441ac",
      "name" : "attack:latest"
    },
    "name" : "attack",
    "runtime" : "DOCKER",
    "sf_privileged" : false
  },
  "process" : {
    "args" : "/etc/passwd",
    "command_line" : "/bin/cat /etc/passwd",
    "executable" : "/bin/cat",
    "name" : "cat",
    "parent" :  {
      "args" : "./attack.sh",
      "command_line" : "/bin/busybox ./attack.sh",
      "executable" : "/bin/busybox",
      "name" : "busybox",
      "pid" : 2980085,
      "start" : "2021-07-01T09:35:58.046937931Z"
    },
    "pid" : 2981780,
    "start" : "2021-07-01T09:36:22.467324952Z",
    "thread" :  {
      "id" : 2981780
    }
  },
  "user" : {
    "group" :  {
      "id" : 0,
      "name" : "root"
    },
    "id" : 0,
    "name" : "root"
  },
  "tags" : ["mitre:T1087.001"]
}
```


## Inspecting detailed process events

In addition to generating alerts, the telemetry stack also writes all raw events
to ElasticSearch. While this part of the pipeline generates significanlty more data, it
provides very detailed insights into the behavior of particular attack steps.
Let's have a look at the `wget` command that was executed as the last step of
the attack.

The `sysflow-alerts` index contains a `Downloader detected` alert indicating
the detection of a `wget` process that downloaded data from
`sysflow.readthedocs.io`. To view the event trace of this particular process,
use the `sysflow-events` index. Go to the __Discover__ pane in Kibana and
select the `sysflow-events` index pattern in the select box on the upper left
of the browser window.

The `sysflow-events` index contains the raw events of `attack` container.
This is due to the filter condition used by the SysFlow collector that
suppresses all host, collector, processor and ELK events to reduce the
amount of raw events in the index. If more containers were added to docker,
their SysFlow trace would also be visible in the `sysflow-events` index.

To view the event trace of the attacker's `wget`, add a filter condition in
Kibana by clicking on the __+ Add filter__ link in the upper left corner. In
the __Edit filter__ window click on the __Field__ select box, select the ECS
attribute `process.name`. Select `is` in the __Operator__ select box right
next to the field box. Finally, click on the __Value__ select box below,
select `wget` from the list of process names and click __Save__.

Back on the __Dicsover__ pane click on the __Time__ column header to display
the events of the `wget` process in chronological (ascending) order. In the
__Available fields__ box on the left, select `event.action`, `file.path`, 
`source.ip`, `source.port`, `destination.ip` and `destination.port`. The
`event.action` attribute shows the type of the event. Since there are common
ECS attributes that are populated for all types (such as time and
`event.action`), and type-specific attributes (all other in our example),
some cells will have blank values (`-`). 

![The wget event trace](images/wget.png?raw=true "The wget event trace")

In the above screen shot you see the fist part if the `wget` events. You can
clearly distinguish three types of events

1) Process events: The first event is the start of the `wget` process. If you
   scroll down to the bottom of the list, you can also see the termination 
   of `wget` the last event (`process-exit`). You could also select
   `process.cmd_line` to show the full command `wget -c -P /tmp https://sysflow.readthedocs.io/en/latest/quick.html`.
2) File flows: They can be classified as either `file-access-write` if data
   were only read, `file-access-write` if data were written, or just
   `file-access` (no transfer). The example shows that some files were read.
   There are addtional attributes (`sf_file_acion.*`) that contain details
   about the data transfer from or to the file. If you scroll down towards
   the end of the list, there is also a `file-access-write` event indicating
   that data was written to `/tmp/quick.html`
3) Network flows: For the `network-connection-traffic` events, we only display
   the connection endpoints. We can see network traffic for DNS resolution
   and to the destination `104.17.33.82` which was the IP address of
   `sysflow.readthedocs.io` at the time we created our SysFlow trace. More
   detail on the traffic can be revealed using the ECS attributes
   `source.bytes`, `destination.bytes` and `network.bytes` that contain the
   number of bytes flown in each direction and in total.


## Using an external Elastic cluster

It is also possible to use an existing Elastic cluster rather than the ELK
stack provided in this package. For an external cluster, adapt the
[processor pipeline](#the-processor-pipeline) and specify the
ElasticSearch endpoints and credentials in `es.addresses` and
`es.username/es.passsword`, respectively. We provide a set of alternative
Makefiles \(`Makefile.no_elk` in `SysFlow-ELK-Demonstrator` and in
`SysFlow-ELK-Demonstrator/sf`\) for this use case. You can run and stop the
telemetry stack targeting an external Elastic cluster with the commands

```shell
make -f Makefile.no_elk run
make -f Makefile.no_elk stop
```

## Licensing

The code in repository as well as all SysFlow images are licensed
under [Apache License 2.0](../../LICENSE.md). This deployment also uses
[Anthony Lapenna's](https://github.com/deviantony) [ELK Stack on Docker](https://github.com/deviantony/docker-elk/tree/tls)
which is licensed under [MIT license](https://github.com/deviantony/docker-elk/blob/tls/LICENSE).

