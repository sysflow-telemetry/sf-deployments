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

