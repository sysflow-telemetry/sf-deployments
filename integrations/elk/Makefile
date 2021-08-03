#
# Copyright (C) 2021 IBM Corporation.
#
# Authors:
# Andreas Schade <san@zurich.ibm.com>

run:
	$(MAKE) -C elk run
	$(MAKE) -C sf run
	$(MAKE) -C attack run

halt:
	$(MAKE) -C attack stop
	$(MAKE) -C sf stop

stop: halt
	$(MAKE) -C elk stop

build:
	$(MAKE) -C elk build
	$(MAKE) -C sf build
	$(MAKE) -C attack build

clean:
	$(MAKE) -C attack clean
	$(MAKE) -C sf clean
	$(MAKE) -C elk clean
