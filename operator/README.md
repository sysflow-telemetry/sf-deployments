[![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/sysflowtelemetry/oc-operator)](https://hub.docker.com/r/sysflowtelemetry/oc-operator/builds)
[![Docker Pulls](https://img.shields.io/docker/pulls/sysflowtelemetry/oc-operator)](https://hub.docker.com/r/sysflowtelemetry/oc-operator)
![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/sysflow-telemetry/sf-deployments)
[![Documentation Status](https://readthedocs.org/projects/sysflow/badge/?version=latest)](https://sysflow.readthedocs.io/en/latest/?badge=latest)
[![GitHub](https://img.shields.io/github/license/sysflow-telemetry/sf-deployments)](https://github.com/sysflow-telemetry/sf-deployments/blob/master/LICENSE.md)

# Supported tags and respective `Dockerfile` links

-	[`latest`](https://github.com/sysflow-telemetry/sf-deployments/blob/master/operator/build/Dockerfile), [`edge`](https://github.com/sysflow-telemetry/sf-deployments/blob/dev/operator/build/Dockerfile)

# Quick reference

-	**Documentation**:  
	[the SysFlow Documentation](https://sysflow.readthedocs.io)
  
-	**Where to get help**:  
	[the SysFlow Community Slack](https://join.slack.com/t/sysflow-telemetry/shared_invite/enQtODA5OTA3NjE0MTAzLTlkMGJlZDQzYTc3MzhjMzUwNDExNmYyNWY0NWIwODNjYmRhYWEwNGU0ZmFkNGQ2NzVmYjYxMWFjYTM1MzA5YWQ)

-	**Where to file issues**:  
	[the github issue tracker](https://github.com/sysflow-telemetry/sf-docs/issues) (include the `sf-deployments` tag)

-	**Source of this description**:  
	[repo's readme](https://github.com/sysflow-telemetry/sf-deployments/edit/master/operator/README.md) ([history](https://github.com/sysflow-telemetry/sf-deployments/commits/master/operator))

# What is SysFlow?

The SysFlow Telemetry Pipeline is a framework for monitoring cloud workloads and for creating performance and security analytics. The goal of this project is to build all the plumbing required for system telemetry so that users can focus on writing and sharing analytics on a scalable, common open-source platform. The backbone of the telemetry pipeline is a new data format called SysFlow, which lifts raw system event information into an abstraction that describes process behaviors, and their relationships with containers, files, and network. This object-relational format is highly compact, yet it provides broad visibility into container clouds. We have also built several APIs that allow users to process SysFlow with their favorite toolkits. Learn more about SysFlow in the [SysFlow specification document](https://sysflow.readthedocs.io/en/latest/spec.html).

# About This Image

This image is the Red Hat OpenShift (OC) Operator for deploying both the SysFlow exporter and collector as pods on openshift platforms.  

# How to use this image

Please see the detailed documentation on deploying the operator [here](https://github.com/sysflow-telemetry/sf-deployments/tree/master/operator/OVERVIEW.md)

# License

View [license information](https://github.com/sysflow-telemetry/sf-deployments/tree/master/operator/LICENSE.md) for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
