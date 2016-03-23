var express = require("express");
var path = require("path");
var bodyParser = require("body-parser");
var events = require("./eventsController");
var app = express();

var rootPath = path.normalize(__dirname + '/../');

var options = {
    index: "views/EventDetails.html"
};


app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());
app.use(express.static(rootPath + '/app', options));

//app.use(express.static(rootPath + '/app'));
//var server = app.listen(8000);


app.get("/data/event/:id", events.get);
app.post("/data/event/:id", events.save);



var server = app.listen(8010, function () {
    var host = server.address().address;
    var port = server.address().port;

    console.log("Listening at http://%s:%s", host, port);
});