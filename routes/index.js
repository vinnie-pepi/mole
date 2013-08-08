var dataSources = require('../lib/data_sources');

module.exports = function(app) {
  app.get('/', function(req, res, next) {
    // list of profiles
    res.render('index');
  });

  app.get('/profile/:id?', function(req, res, next) {
    // var profile = db.get(id);
    res.render('profile');
  });

  app.get('/profile/:id/edit', function(req, res, next) {
    //var profile = db.get(id);
    res.render('profile');
  });

  app.all('/searchEntity', function (req, res, next) {
    require('../lib/data_sources').getData(req.query, function (err, data) {
    res.json(data);
    });
  });

};
