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
    res.render('index');
  });

  // PROFILES REST
  app.get('/profiles', function(req, res, next) {
    Profile.all(function(err, docs) {
      if (err) return next(err);
      res.json(docs);
    });
  });

  app.post('/profiles', function(req, res, next) {
    Profile.new(req.body, function(err, doc) {
      if (err) return next(err);
      res.json(doc);
    });
  });

  app.get('/profiles/:id', function(req, res, next) {
    Profile.findById(req.params.id, function(err, profile) {
      if (err) return next(err);
      if (req.xhr) {
        res.json(profile.attrs());
      } else {
        res.render('profile2', { profileData: profile.attrs()});
      }
    });
  });

  app.post('/baseline_upload', function(req, res, next) {
    var id      = req.body.profileId;
    var homeRef = req.body.homeRef;
    csv().from.path(req.files.baselineData.path, { delimiter: '\t' })
      .to.array(function(data) {
        var cleaned = data.map(function(row) {
          if (row[2] && row[3]) {
            var lat = parseFloat(row[2])
              , lng = parseFloat(row[3]);
            if (!isNaN(lat+lng))
              return [ row[1], lat, lng ];
          }
        }).filter(function(row) {
          return row;
        });
        Profile.findById(id, function(err, profile) {
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
