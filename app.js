
/**
 * Module dependencies.
 */
var coffee = require('coffee-script');

var express = require('express')
  , routes = require('./routes')
  , user = require('./routes/user')
  , http = require('http')
  , fs   = require('fs')
  , path = require('path');

var app = express();

// all environments
app.set('port', process.env.PORT || 3000);
app.set('views', __dirname + '/views');
app.set('view engine', 'jade');
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(app.router);
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
          res.send(coffee.compile(str));
        } catch (err) {
          console.error(err);
        }
        next();
      } else {
        next();
      }
    });
  } else {
    next();
  }
});
app.use(express.static(path.join(__dirname, 'public')));


// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}

app.get('/', routes.index);
app.get('/users', user.list);

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
