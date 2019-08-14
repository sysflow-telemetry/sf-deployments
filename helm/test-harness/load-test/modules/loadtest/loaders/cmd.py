import threading
import logging
import subprocess
import signal
from multiprocessing import Process

class CMDProc(Process): #threading.Thread):
    def __init__(self, group=None, target=None, name=None,
                 args=(), kwargs=None):
        super(CMDProc,self).__init__(group=group, target=target, 
                          name=name)
        self.config = args[0]
        self.id = args[1]
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
        domain = self.config['srvname'] + '-' + str(self.id) + '.' + self.config['srvname']
        cmds = self.config['loadCmd']
        cmds = [c.format(domain) for c in cmds]
        logging.debug('Process running..')
        repeat = self.config['repeat']
        i = 0
        while ((i <= repeat) or (repeat == -1)) and not self.kill:
            cmdProc = subprocess.Popen(cmds, 
                stdout=subprocess.PIPE, 
                stderr=subprocess.STDOUT)
            stdout, stderr = cmdProc.communicate()
            logging.info(stdout)
            logging.info(stderr)
            logging.debug('loadtest ran, DOMAIN: ' + domain + ' Iteration: ' + str(i))
            self.waitEvt.wait(5.0)
            i += 1
        logging.debug('Load tester ' + str(self.id) + ' exiting..')
        return

