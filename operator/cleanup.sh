#!/bin/bash
oc delete -f deploy/crds/charts.helm.k8s.io_v1alpha1_sfexporterchart_cr.yaml
oc delete -f deploy/operator.yaml
oc delete -f deploy/role_binding.yaml
#kubectl delete -f deploy/role.yaml
oc delete -f deploy/service_account.yaml
#kubectl delete -f deploy/service_account_app.yaml
oc delete -f deploy/sysflow_scc.yaml
#kubectl delete -f deploy/crds/charts.helm.k8s.io_sfexportercharts_crd.yaml 
