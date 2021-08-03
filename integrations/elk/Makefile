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
