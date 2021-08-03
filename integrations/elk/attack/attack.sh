#/bin/sh
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

echo "Waiting..." >&2
sleep 20

echo "Step 1" >&2
uname -a
echo
sleep 3

echo "Step 2 ">&2
df
echo
sleep 1

echo "Step 3" >&2
ps -ef
echo
sleep 2

echo "Step 4" >&2
ls /home
echo
sleep 3

echo "Step 5" >&2
cat /etc/passwd
echo
sleep 1

echo "Step 6" >&2
wget -c -P /tmp https://sysflow.readthedocs.io/en/latest/quick.html 2>&1
echo
