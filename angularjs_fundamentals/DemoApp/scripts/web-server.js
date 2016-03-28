var express = require("express");
var path = require("path");
var bodyParser = require("body-parser");
var events = require("./eventsController");
var app = express();

var rootPath = path.normalize(__dirname + '/../');

//var options = {
//    index: "views/index.html"
//};


app.use(bodyParser.urlencoded({extended: true}));
app.use(bodyParser.json());
//app.use(express.static(rootPath + '/app', options));
app.use(express.static(rootPath + "/app"));

//app.use(express.static(rootPath + '/app'));
//var server = app.listen(8000);


app.get("/data/event", events.getAll);
app.get("/data/event/:id", events.get);
app.post("/data/event/:id", events.save);

//needed for routing in html5 mode
app.get('*', function (req, res) { res.sendFile(rootPath + '/app/index.html'); });



var server = app.listen(8010, function () {
    var host = server.address().address;
    var port = server.address().port;

    console.log("Listening at http://%s:%s", host, port);
});