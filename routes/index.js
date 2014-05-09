var dataSources = require('../lib/data_sources');
var EventsGenerator = require('../lib/events_generator');
var fs = require('fs');
var csv = require('csv');

module.exports = function(app, db, mongo) {
  var Profile = require('../lib/models/profile')(mongo);
  var Events  = require('../lib/models/events')(mongo);

  // require('./events')(app, Events);
  // require('./profiles')(app, Profile);

  app.get('/', function(req, res, next) {
    // list of profiles
    Profile.all(function(err, docs) {
      res.render('index', { profiles: docs });
    });
  });

  // PROFILES REST
  app.get('/profiles', function(req, res, next) {
    Profile.all(function(err, docs) {
      if (err) return next(err);
      res.json(docs);
    });
  });
  app.post('/profiles', function(req, res, next) {
    Profile.new(req.body.id, req.body.traits, function(err, doc) {
      if (err) return next(err);
      console.log(doc);
      res.json(doc);
    });
  });
  app.get('/profiles/:id', function(req, res, next) {
    res.end(new Error('not yet implemented'));
  });

  app.post('/', function(req, res, next) {
    db.addProfile(req.body.id, req.body.traits || '', function() {
      res.redirect('/profile/' + req.body.id);
    })
  });

  app.post('/baseline_upload', function(req, res, next) {
    var id      = req.body.profileId;
    var homeRef = req.body.homeRef;
    csv().from.path(req.files.baselineData.path, { delimiter: '\t' })
      .to.array(function(data) {
        var cleaned = [];
        data.forEach(function(row) {
          if (row[2].length && row[3].length) {
            cleaned.push([ parseFloat(row[2]), parseFloat(row[3]) ]);
          }
        });
        Profile.findById(id, function(err, profile) {
          // need to determine how you want to store refs
          profile.pushRefs(cleaned, function(err, doc) {
            res.json(doc);
          });
        });
    });  
  });

  app.get('/profile/:id?', function(req, res, next) {
    Profile.findById(req.params.id, function(err, profile) {
      res.render('profile2', { profileData: profile.attrs()});
    });
  });

  app.get('/profile_old/:id?', function(req, res, next) {
    db.getProfile(req.params.id, function(err, docs) {
      var opts = {
        profile_id: req.params.id
      };
      if(docs && docs.refs) {
        var schedule = docs.refs.filter(function(doc) {
          if (doc.isTarget || !doc.isNoise)
            return true;
        });
        opts.refs = docs.refs;
        opts.schedule = schedule;
      }
      // render new profile page
      res.render('profile2', opts);
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

  app.get('/profile.:format?/:id/export', function (req, res) {
    db.getProfile(req.params.id, function(err, docs) {
      if(docs && docs.refs) {
        if (req.params.format === "tab") {
          var filler = "none";
          var tabRow;
          var tabArray = docs.refs.map(function (r) {
            tabRow = [
             r.userId,
             r.timestamp,
             r.latitude,
             r.longitude,
             filler
            ].join("\t");
            return tabRow;
          });
          res.setHeader('Content-Type', 'text/plain');
          res.end(tabArray.join("\n"));
        } else {
          res.json(docs.refs.map(function (r) {
            return {
              userId: r.userId,
              timestamp: r.timestamp,
              latitude: r.latitude,
              longitude: r.longitude
            };
          }));
        }
      } else {
        res.send("no results found");
      }
    })
  });

  app.post('/profile/:id/createEventsGenerator', function (req, res) {
    var userId = req.params.id;
    var targets = req.body.targets;
    EventsGenerator.getNoises(targets, function (err, noises) {
      if (err) noises = [];
      var options = EventsGenerator.getOptions(userId, targets, noises, req.body);
      var events = EventsGenerator.createEventsGenerator(options);
      db.saveGeoRefs(userId, events, function() {
        res.json(events);
      })
    });
  });

  app.get('/profile/:id/events/new', function (req, res, next) {
  });
  app.post('/profile/:id/events/create', function (req, res, next) {
  });

};
