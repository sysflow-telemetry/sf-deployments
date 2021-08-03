#
# Copyright (C) 2021 IBM Corporation.
#
# Authors:
# Andreas Schade <san@zurich.ibm.com>

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
