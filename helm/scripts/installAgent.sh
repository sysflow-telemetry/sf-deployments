#!/bin/bash
#
# Copyright (C) 2020 IBM Corporation.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
