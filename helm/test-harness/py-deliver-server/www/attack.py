#!/usr/bin/python

with open('/etc/passwd') as f:
    for line in f:
        print(line)
