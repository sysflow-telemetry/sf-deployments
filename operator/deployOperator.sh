#!/bin/bash
#kubectl create -f deploy/service_account_app.yaml
oc create -f deploy/sysflow_scc.yaml
oc create -f deploy/service_account.yaml
#kubectl create -f deploy/role.yaml
oc create -f deploy/role_binding.yaml
oc create -f deploy/operator.yaml
oc adm policy add-scc-to-user sysflow-scc -z sysflow-serviceaccount
