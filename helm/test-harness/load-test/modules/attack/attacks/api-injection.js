global.app.get('/malicious', function(rq,re) {
    re.send("This is an injected malicious API endpoint talking to you!");
})
console.log('API injected!');