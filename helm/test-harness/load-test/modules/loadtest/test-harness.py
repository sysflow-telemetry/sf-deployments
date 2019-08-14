#!/usr/bin/python3

import threading
import time
import json
import argparse
from loaders.cmd import CMDProc
from loaders.inject import InjectProc
import logging

logging.basicConfig(level=logging.DEBUG,
                    format='(%(processName)-9s) %(message)s',)



if __name__ == "__main__":
    inject = None
    parser = argparse.ArgumentParser(description='Load Test and attack script.')
    parser.add_argument('--config', metavar='filename', type=str, 
                    help='The configuration file for the load tester')
    args = parser.parse_args()
    procs = []
    print("Opening file " + args.config)
    with open(args.config) as f:
         #r = csv.reader(csvFile, delimiter=',')
         #r = csv.DictReader(filter(lambda row: row[0]!='#', csvFile))
         for row in f:
             #if len(row) > 0 and len(row[0]) > 0 and row[0][0] != '#':
             cf = json.loads(row)
             logging.debug("Low Index: " + str(cf['lowIndex']) + " High Index: " + str(cf['highIndex']))
             for i in range(cf['lowIndex'], cf['highIndex']+1):
                  #print('Creating thread ' + str(i))
                  proc = CMDProc(args=(cf, i), name=cf['srvname'] + '-' + str(i))
                  proc.start()
                  time.sleep(0.9)
                  procs.append(proc)
         if cf['attack']:
            inject = InjectProc(args=cf, name=cf['srvname'] + '-inject')
            inject.start()

    for p in procs:
        p.join()
    if inject is not None:
        inject.terminate()
    while True:
        time.sleep(5)
