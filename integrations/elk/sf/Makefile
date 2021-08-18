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
	docker-compose up -d

stop:
	docker-compose down

build:
#	-git clone https://github.com/sysflow-telemetry/sf-processor.git
#	cd sf-processor && git checkout master && make docker-build

clean:
	docker rmi -f sysflowtelemetry/sf-collector:edge
	docker rmi -f sysflowtelemetry/sf-processor:edge
