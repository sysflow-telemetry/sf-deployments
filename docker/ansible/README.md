# SysFlow Ansible Playbook

This playbook requires Ansible 2.4+.

The SysFlow stack can be deployed to a single node or multiple nodes. The inventory file
'hosts' defines the nodes in which the stacks should be configured.

        [endpoints]
        sampa        

Here SysFlow would be configured on a server called `sampa`. 
The stack can be deployed using the following
command:

        ansible-playbook -i hosts main.yml

## S3 Secrets

The Ansible SysFlow role expects that the S3 access and secret keys are stored in separate files 
under a top-level `secrets` directory. The files must be named `s3\_access\_key` and `s3\_secret\_key`.

```
.\
    group_vars\
    roles\
    secrets\
        s3_access_key
        s3_secret_key
    main.yml
    ...
```

## Configuration

Variables can be customized under `group\_vars`. Defaults are provided. 
