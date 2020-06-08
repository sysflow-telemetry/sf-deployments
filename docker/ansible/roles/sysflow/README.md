# Ansible Role: sysflow

Role to install (_by default_) [sysflow](https://github.com/sysflow-telemetry/) stack or uninstall (_if passed as var_) on **Ubuntu**, **Debian** and **CentOS** systems.

Tested on Ubuntu 18.04 LTS, Ubuntu 16.04 LTS, Debian ..., and CentOS 7.

## Requirements

This role depends on the following community role:

```
darkwizard242.docker
```

To install it, run:

```
ansible-galaxy install darkwizard242.docker
```

## Role Variables

Available variables are listed below (located in `defaults/main.yml`):

### Variables List:

```yaml
sysflow_desired_state: present
sysflow_dependencies_desired_state: present
sysflow_install_docker: true
sysflow_tag: edge
sysflow_trace_rolling_interval: 30
sysflow_install_path: /var/lib/sysflow
s3_endpoint: 9.59.151.43
s3_port: 9000
s3_location: us-south
s3_bucket: sysflow-telemetry
s3_secure: false
s3_export_interval: 60
```

### Variables table:

Variable                                      | Value (default)                                                | Description
--------------------------------------------- | ---------------------------------------------------------------|-------------------------------------------------------------------------------------------------------
sysflow\_desired\_state                       | present                                                        | if set to `present`, it installs sysflow, if set to `absent`, it uninstalls sysflow
sysflow\_dependencies\_desired\_state         | present                                                        | if set to `present`, it installs dependencies, if set to `absent`, it uninstalls dependencies
sysflow\_install\_docker                      | true                                                           | if set to `true`, it installs docker, if set to `false`, it assumes docker is already installed
sysflow\_tag                                  | edge                                                           | sysflow image [tags](https://hub.docker.com/u/sysflowtelemetry)
sysflow\_trace\_rolling\_interval             | 30                                                             | trace files rolling interval in seconds (number of seconds to start a new trace file)
sysflow\_install\_path                        | /var/lib/sysflow                                               | path where sysflow resources are installed (owned by `root`, with `0700` access permissions)
s3\_endpoint                                  | e.g., 9.59.151.43                                              | S3 endpoint address
s3\_port                                      | 9000                                                           | S3 endpoint port
s3\_location                                  | us-south                                                       | S3 location
s3\_bucket                                    | sysflow-telemetry                                              | S3 bucket
s3\_secure                                    | false                                                          | S3 over TLS
s3\_export\_interval                          | 60                                                             | Number of seconds between data exports to S3

## Dependencies

The following dependencies are automatically installed:

```
docker-compose
python-docker/deb 
python-docker-py/el
```

## Example Playbook

For default behaviour of role (i.e. installation of **docker** package) in ansible playbooks.

```yaml
- hosts: servers
  roles:
    - darkwizard242.docker
```

For customizing behavior of role (i.e. utilizing an existing or creating a new user to be added to docker group - example shown below is using `darkwizard242` as a user) in ansible playbooks.

```yaml
- hosts: servers
  roles:
    - darkwizard242.docker
  vars:
    docker_user: darkwizard242
```

For customizing behavior of role (i.e. un-installation of **docker-ce, docker-ce-cli, containerd.io** packages) in ansible playbooks.

```yaml
- hosts: servers
  roles:
    - darkwizard242.docker
  vars:
    docker_apps_desired_state: absent
```

## License

[Apache2](LICENSE)

