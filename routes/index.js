var dataSources = require('../lib/data_sources');
var EventsGenerator = require('../lib/events_generator');
var fs = require('fs');
var csv = require('csv');

module.exports = function(app, db, mongo) {
  var Profile = require('../lib/models/profile')(mongo);
  var Events  = require('../lib/models/events')(mongo);

  app.get('/', function(req, res, next) {
    res.render('index');
  });

  // <<<< PROFILES REST
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

  app.put('/profiles/:id', function(req, res, next) {
    Profile.findById(req.params.id, function(err, profile) {
      profile.update(req.body, function(err) {
        if (err) return next(err);
        res.status(200).end();
      })
    });
  });
  // >>>> END PROFILES REST

  app.post('/baseline_upload', function(req, res, next) {
    var id      = req.body.profileId;
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
          profile.pushRefs(cleaned, function(err) {
            if (err) next(err);
            res.json({ status: 200 });
          });
        });
    });  
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
    Profile.findById(req.params.id, function(err, profile) {
      res.render('events/new', { profileData: profile.attrs()});
    });
  });

  app.put('/profile/:id/events', function (req, res, next) {
    Profile.findById(req.params.id, function(err, profile) {
      if(err) return res.next(err);
      profile.pushRefs(req.body.refs, function(err, docs) {
        if(err) return res.next(err);
        res.json(docs);
      });
    });
  });

  app.get('/factual', function(req, res, next) {
    Events.query(req.query.locus, req.query.distance, req.query.categories, function(err, results) {
      if (err) return next(err);
      res.json(results);
    });
  });

  app.get('/export/:id', function(req, res, next) {
    Profile.findById(req.params.id, function(err, profile) {
      var attrs = profile.attrs();
      if (attrs.refs) {
        attrs.refs.forEach(function(ref) {
          ref.unshift(attrs.id);
        });
        csv().from.array(attrs.refs, { delimiter: "\t" }).to(res);
      }
    });
  });

};
