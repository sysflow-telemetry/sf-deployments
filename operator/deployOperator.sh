#!/bin/bash
#kubectl create -f deploy/service_account_app.yaml
kubectl create -f deploy/sysflow_scc.yaml
kubectl create -f deploy/service_account.yaml
#kubectl create -f deploy/role.yaml
kubectl create -f deploy/role_binding.yaml
kubectl create -f deploy/operator.yaml
oc adm policy add-scc-to-user sysflow-scc -z sysflow-serviceaccount
