var dataSources = require('../lib/data_sources');
var Events = require('../lib/events');
var fs = require('fs');
var csv = require('csv');

module.exports = function(app, db) {
  app.get('/', function(req, res, next) {
    // list of profiles
    db.getProfiles(function(err, docs) {
      res.render('index', { profiles: docs });
    });
  });

  app.post('/', function(req, res, next) {
    db.addProfile(req.body.id, req.body.traits || '', function() {
      res.redirect('/profile/' + req.body.id);
    })
  });

  app.get('/profile2', function(req, res, next) {
    res.render('profile2');
  });

  app.post('/baseline_upload', function(req, res, next) {
    csv().from.path(req.files.baselineData.path, { delimiter: '\t' })
      .to.array(function(data) {
        res.json(data);
      });
  });

  app.get('/profile/:id?', function(req, res, next) {
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

  app.post('/profile/:id/createEvents', function (req, res) {
    var userId = req.params.id;
    var targets = req.body.targets;
    Events.getNoises(targets, function (err, noises) {
      if (err) noises = [];
      var options = Events.getOptions(userId, targets, noises, req.body);
      var events = Events.createEvents(options);
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
