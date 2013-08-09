var dataSources = require('../lib/data_sources');
var Events = require('../lib/events');

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

  app.get('/profile/:id/export', function (req, res) {
    db.getProfile(req.params.id, function(err, docs) {
      if(docs && docs.refs) {
        res.json(docs.refs.map(function (r) {
          return {
            userId: r.userId,
            timestamp: r.timestamp,
            latitude: r.latitude,
            longitude: r.longitude
          };
        }));
      } else {
        res.json([]);
      }
    })
  });

  app.post('/profile/:id/createEvents', function (req, res) {
    var userId = req.params.id;
    var targets = req.body.targets;
    Events.getNoises(targets, function (err, noises) {
      if (err) noises = [];
      var options = {
        userId: userId,
        daysBefore: parseInt(req.body.daysBefore || 30),
        durationDays: parseInt(req.body.durationDays || 28),
        timezoneOffset: (req.body.timezoneOffset ? parseInt(req.body.timezoneOffset) : null),
        pois: {
          targets: {
            entities: targets,
            percentage: (req.body.targetsPercentage ? parseFloat(req.body.targetsPercentage) : null)
          },
          noises: {
            entities: noises,
            percentage: (req.body.noisesPercentage ? parseFloat(req.body.noisesPercentage) : null)
          },
          home: (req.body.home ? JSON.parse(req.body.home) : null),
          work: (req.body.work ? JSON.parse(req.body.work) : null)
        }
      }
      var events = Events.createEvents(options);
      db.saveGeoRefs(userId, events, function() {
        res.json(events);
        //res.redirect('/profile/' + userId);
      })
    });
  });

};
