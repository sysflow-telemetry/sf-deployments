#!/bin/bash
#
# Copyright (C) 2021 IBM Corporation.
#
# Authors:
# Andreas Schade <san@zurich.ibm.com>

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

