/**
 * Module dependencies.
 */
var coffee = require('coffee-script');
coffee.register();

var express = require('express')
  , routes = require('./routes')
  , http = require('http')
  , fs   = require('fs')
  , path = require('path')
  , config = require('./lib/config.json')
  , parseless = require('./lib/helpers/parseless');

var app = express();

// all environments
app.set('port', process.env.PORT || 3000);
app.set('views', __dirname + '/views');
app.set('view engine', 'jade');
app.locals.pretty = true;
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.bodyParser());
app.use(express.methodOverride());

app.use(function(req, res, next) {
  res.locals.config = config;
  next();
});

parseless.setup(app);
app.use(function(req, res, next) {
  if (path.extname(req.path) === '.js') {
    var publicPath = path.join(__dirname, 'public', req.path).replace(/.js$/, '.coffee');
    fs.exists(publicPath, function(exists) {
      if (exists) {
        var str = fs.readFileSync(publicPath).toString();
        var compiled;
        try {
          compiled = coffee.compile(str);
          res.set('Content-Type', 'application/javascript');
          res.end(coffee.compile(str));
        } catch (err) {
          console.error(err);
        }
      } else {
        next();
      }
    });
  } else {
    next();
  }
});
app.use(app.router);
app.use(express.static(path.join(__dirname, 'public')));
app.use('/components', express.static(path.join(__dirname, 'bower_components')));

var Db = require('./lib/connection');
var db = new Db();
db.on('connected', function(mongo){
  routes(app, db, mongo);
});
db.connect();

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}

app.listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
