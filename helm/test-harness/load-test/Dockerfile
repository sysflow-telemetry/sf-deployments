#
# Copyright (C) 2019 IBM Corporation.
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

FROM ubuntu:18.04

RUN apt-get update -yqq && \
    apt-get upgrade -yqq && \
    apt-get install -yqq \
    nodejs \
    npm \
    apache2-utils \
    python3-pip && \
    apt-get clean -yqq && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/lib/apt/archive/*

COPY modules/attack /build/
COPY modules/loadtest /build/
COPY modules/loadconfig.cfg /build/
RUN  cd /build && npm install
WORKDIR /build/

CMD ["/build/test-harness.py", "--config", "/build/loadconfig.cfg"]
