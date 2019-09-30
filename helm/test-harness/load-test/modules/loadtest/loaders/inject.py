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

import threading
import logging
import subprocess
import random
import time
import signal
from multiprocessing import Process

class InjectProc(Process): #threading.Thread):
    def __init__(self, group=None, target=None, name=None,
                 args=(), kwargs=None):
        super(InjectProc,self).__init__(group=group, target=target, 
                          name=name)
        self.config = args
        self.procName = name
        signal.signal(signal.SIGTERM, self.signalSigTerm)
        self.kill = False
        self.waitEvt = threading.Event()
        return

    def signalSigTerm(self, signum, frame):
        self.kill = True
        self.waitEvt.set()
    def run(self):
        #print('Thread running..' +  self.thrName)
        logging.info('Process running..')
        i = 0
        while not self.kill:
            epID = random.randrange(self.config['lowIndex'], self.config['highIndex']) if self.config['lowIndex'] < self.config['highIndex'] else self.config['lowIndex']
            domain = self.config['srvname'] + '-' + str(epID) + '.' + self.config['srvname']
            atCmds = self.config['attackCmd']
            cmds = [c.format(domain) for c in atCmds]
            cmdProc = subprocess.Popen(cmds, 
               stdout=subprocess.PIPE, 
               stderr=subprocess.STDOUT)
            stdout,stderr = cmdProc.communicate()
            logging.info(stdout)
            logging.info(stderr)
            i+=1
            logging.info('Injection on Domain: ' + domain + ' Iteration: ' + str(i))
            self.waitEvt.wait(self.config['attInterval'])
        logging.info('Injector exiting..')
        return

