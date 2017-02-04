var express = require('express');
var bodyParser = require('body-parser');
var mongoose = require('mongoose');
var morgan = require('morgan');

var router = require('./router');

mongoose.connect('mongodb://localhost:27017/todos')
var app = express();

app.use(morgan('combined'));


app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
  extended: true
}));

app.use('/todo', router);

var port = process.env.PORT || 3001;
var host = process.env.HOST || '192.168.1.3';

console.log("Listening on", host, port);

app.get('/test', function (req, res) {
  res.send('Hello World!')
})

app.listen(port,host);
