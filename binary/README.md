# Binary packages

SysFlow can be deployed directly on the host using its binary packages (since SysFlow 0.4.0). 

We package SysFlow for debian- and rpm-based distros.

### Debian distributions

Download the SysFlow packages (replace `VERSION` with a Sysflow release >=0.4.0):

```bash
wget https://github.com/sysflow-telemetry/sf-collector/releases/download/<VERSION>/sfprocessor-<VERSION>-x86_64.deb \
     https://github.com/sysflow-telemetry/sf-processor/releases/download/<VERSION>/sfprocessor-<VERSION>-x86_64.deb
```

Install pre-requisites:

```
apt install -y gcc make libelf-dev libsnappy-dev libgoogle-glog-dev llvm dkms linux-headers-$(uname -r) 
```

Install the SysFlow packages:

```bash
dpkg -i sfcollector-<VERSION>-x86_64.deb sfprocessor-<VERSION>-x86_64.deb
```

### RPM distributions

Download the SysFlow packages (replace `VERSION` with a Sysflow release >=0.4.0):

```bash
wget https://github.com/sysflow-telemetry/sf-collector/releases/download/<VERSION>/sfprocessor-<VERSION>-x86_64.rpm \
     https://github.com/sysflow-telemetry/sf-processor/releases/download/<VERSION>/sfprocessor-<VERSION>-x86_64.rpm
```

Install pre-requisites (Instructions for Rhel8 below):

```bash
subscription-manager repos --enable="codeready-builder-for-rhel-8-$(/bin/arch)-rpms"
dnf -y update
dnf -y install \
    gcc \
    make \
    kernel-devel-$(uname -r) \
    elfutils-libelf-devel \
    snappy-devel \
    glog-devel \
    llvm-toolset
dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
dnf -y install dkms
dnf -y remove epel-release && dnf autoremove
```

Install the SysFlow packages:

```bash
rmp -i sfcollector-<VERSION>-x86_64.rpm sfprocessor-<VERSION>-x86_64.rpm
```

### Running

Start the SysFlow systemd service:

```bash
sysflow start
```

Check SysFlow service status:

```bash
sysflow status
```

Stop the SysFlow service:

```bash
sysflow stop
```

### Configuration

Configuration options can be changed in `/etc/sysflow`. The Processor configuration is located in `/etc/sysflow/pipelines/pipeline.local.json` and can be used to change the processor configuration from its default settings. The Collector and systemd service configurations are located in `/etc/sysflow/conf/sysflow.env`.
