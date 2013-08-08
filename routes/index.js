var dataSources = require('../lib/data_sources');

module.exports = function(app, db) {
  app.get('/', function(req, res, next) {
    // list of profiles
    db.getProfiles(function(err, docs) {
      res.render('index', { profiles: docs });
    });
  });

  app.post('/', function(req, res, next) {
    db.addProfile(req.body.id, req.body.traits.split("\r"), function() {
      res.redirect('/');
    })
  })

  app.get('/profile/:id?', function(req, res, next) {
    res.render('profile', { profile_id: req.params.id });
  });

  app.post('/profile/:id', function(req, res, next) {
    console.log(req.body);
    var userId  = req.params.id;
    var geoRefs = req.body;
  });

  app.all('/searchEntity', function (req, res, next) {
    require('../lib/data_sources').getData(req.body, function (err, data) {
      res.json(err ? [] : data);
    });
  });

};
