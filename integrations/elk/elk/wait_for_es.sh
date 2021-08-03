#!/bin/bash
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

ready() {
    eval "curl -k -ssl -u elastic:changeme -XGET https://localhost:9200/_status" > /dev/null 2> /dev/null
}

echo -n "Waiting for ElasticSearch "
i=0
while ! ready; do
    i=$(expr $i + 1)
    echo -n "."
    sleep 3
done

echo 

