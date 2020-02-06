#!/bin/bash
kubectl delete -f deploy/crds/charts.helm.k8s.io_v1alpha1_sfexporterchart_cr.yaml
kubectl delete -f deploy/operator.yaml
kubectl delete -f deploy/role_binding.yaml
#kubectl delete -f deploy/role.yaml
kubectl delete -f deploy/service_account.yaml
#kubectl delete -f deploy/service_account_app.yaml
kubectl delete -f deploy/sysflow_scc.yaml
#kubectl delete -f deploy/crds/charts.helm.k8s.io_sfexportercharts_crd.yaml 
