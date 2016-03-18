var express = require('express');
var path = require('path');
var app = express();
var rootPath = path.normalize(__dirname + '/../');

var options = {
    index: "views/EventDetails.html"
};

app.use(express.static(rootPath + '/app', options));

//app.use(express.static(rootPath + '/app'));
//var server = app.listen(8000);

var server = app.listen(8010, function () {
    var host = server.address().address;
    var port = server.address().port;

    console.log("Listening at http://%s:%s", host, port);
});