#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Required arguments missing!"
    echo "Usage : ./installSysflowAgent <rsyslog_ip> <rsyslog_port> <tcp|tls>"
    exit 1
fi

NAMESPACE=sysflow
RSYSLOG_IP=$1
RSYSLOG_PORT=$2
RSYSLOG_PROTO=$3

# Don't run if any of the prerequisites are not installed.
PREQ=( "kubectl" "helm" )
for i in "${PREQ[@]}"
do
  IS_EXIST=$(command -v $i)
  if [ -z "$IS_EXIST" ]
  then
    echo "$i not installed. Please install the required pre-requisites first (kubectl, helm)"
    exit 1
  fi
done

NS_CREATE=$(kubectl create namespace $NAMESPACE 2>&1)
if [[ "$NS_CREATE" =~ "already exists" ]]; then
    echo "Warning: Namespace '$NAMESPACE' already exists. Proceeding with existing namespace."
else
    echo "Namespace '$NAMESPACE' created successfully"
fi

# sf-deployments/helm/scripts/
REALPATH=$(dirname $(realpath $0))

cd $REALPATH/..

helm install sysflowagent -f sysflowagent/values.yaml --namespace $NAMESPACE --set sfprocessor.export=syslog --set sfprocessor.syslogHost=$RSYSLOG_IP --set sfprocessor.syslogPort=$RSYSLOG_PORT --set sfprocessor.syslogProto=$RSYSLOG_PROTO --debug ./sysflowagent
