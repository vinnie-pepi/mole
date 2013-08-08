var dataSources = require('../lib/data_sources');

module.exports = function(app, db) {
  app.get('/', function(req, res, next) {
    // list of profiles
    db.getProfiles(function(err, docs) {
      console.log(docs);
      res.render('index', { profiles: docs });
    });
  });

  app.post('/', function(req, res, next) {
    console.log(req.body, req.query);
    db.addProfile(req.body.id, req.body.traits.split("\n"), function() {
      res.redirect('/');
    })
  })

  app.get('/profile/:id?', function(req, res, next) {
    // var profile = db.get(id);
    res.render('profile');
  });

  app.get('/profile/:id/edit', function(req, res, next) {
    //var profile = db.get(id);
    res.render('profile');
  });

  app.all('/searchEntity', function (req, res, next) {
    require('../lib/data_sources').getData(req.body, function (err, data) {
      res.json(err ? {} : data);
    });
  });

};
