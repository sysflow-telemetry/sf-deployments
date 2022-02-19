#
# Copyright (C) 2021 IBM Corporation.
#
# Authors:
# Andreas Schade <san@zurich.ibm.com>
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

run:
	cd docker-elk && docker-compose up -d
	@./wait_for_es.sh
	@curl -s -k -ssl -u elastic:changeme -XPUT https://localhost:9200/sysflow-alerts -H 'Content-Type: application/json' -d @ecs_mapping.json > /dev/null && echo "Created index 'sysflow-alerts'"
	@curl -s -k -ssl -u elastic:changeme -XPUT https://localhost:9200/sysflow-alerts/_settings -H 'Content-Type: application/json' -d '{ "index" : { "number_of_replicas" : 0}}' > /dev/null
	@curl -s -k -ssl -u elastic:changeme -XPUT https://localhost:9200/sysflow-events -H 'Content-Type: application/json' -d @ecs_mapping.json > /dev/null && echo "Created index 'sysflow-events'"
	@curl -s -k -ssl -u elastic:changeme -XPUT https://localhost:9200/sysflow-events/_settings -H 'Content-Type: application/json' -d '{ "index" : { "number_of_replicas" : 0}}' > /dev/null

stop:
	cd docker-elk && docker-compose down

build:
	-git clone https://github.com/deviantony/docker-elk.git
	cd docker-elk && git checkout tls
	cd docker-elk && mv elasticsearch/config/elasticsearch.yml elasticsearch/config/elasticsearch.yml.orig && cp -p ../elasticsearch.yml elasticsearch/config/elasticsearch.yml
	cd docker-elk && mv kibana/config/kibana.yml kibana/config/kibana.yml.orig && cp -p ../kibana.yml kibana/config/kibana.yml
	cd docker-elk && mv docker-compose.yml docker-compose.yml.orig && cp -p ../docker-compose.yml docker-compose.yml
	cd docker-elk && mv .env .env.orig && cp -p ../.env .env

clean:
	docker rmi -f docker-elk_kibana:latest
	docker rmi -f docker-elk_elasticsearch:latest
