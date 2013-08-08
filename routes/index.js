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
    db.getProfile(req.params.id, function(err, docs) {
      console.log(docs);
      var opts = {
        profile_id: req.params.id
      };
      if(docs && docs.refs) opts.refs = docs.refs;
      res.render('profile', opts);
    })
  });

  app.post('/profile/:id', function(req, res, next) {
    console.log(req.body);
    var userId  = req.params.id;
    var geoRefs = req.body.refs;
    db.saveGeoRefs(userId, geoRefs, function() {
      res.redirect('/profile/' + userId);
    })
  });

  app.all('/searchEntity', function (req, res, next) {
    require('../lib/data_sources').getData(req.body, function (err, data) {
      res.json(err ? [] : data);
    });
  });

};
