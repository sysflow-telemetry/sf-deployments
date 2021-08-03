#!/bin/bash
#
# Copyright (C) 2021 IBM Corporation.
#
# Authors:
# Frederico Araujo <frederico.araujo@ibm.com>
# Teryl Taylor <terylt@ibm.com>
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

oc delete -f deploy/crds/charts.helm.k8s.io_v1alpha1_sfexporterchart_cr.yaml
oc delete -f deploy/operator.yaml
oc delete -f deploy/role_binding.yaml
#kubectl delete -f deploy/role.yaml
oc delete -f deploy/service_account.yaml
#kubectl delete -f deploy/service_account_app.yaml
oc delete -f deploy/sysflow_scc.yaml
#kubectl delete -f deploy/crds/charts.helm.k8s.io_sfexportercharts_crd.yaml 
