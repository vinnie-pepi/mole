var dataSources = require('../lib/data_sources');
var EventsGenerator = require('../lib/events_generator');
var fs = require('fs');
var csv = require('csv');

module.exports = function(app, mongo, controllers) {

  var Profile = require('../lib/models/profile')(mongo);
  var Events  = require('../lib/models/events')(mongo);

  app.get('/', function(req, res, next) {
    res.render('index');
  });

  // <<<< PROFILES REST
  app.get('/profiles', controllers.profile.index);
  app.post('/profiles', controllers.profile.create);
  app.get('/profiles/:id.:format?', controllers.profile.show);
  app.put('/profiles/:id', controllers.profile.update);
  app.delete('/profiles/:id', controllers.profile.destroy);
  
  // >>>> END PROFILES REST

  app.get('/timezone', function(req, res, next) {
  });

  app.post('/baseline_upload', function(req, res, next) {
    var id = req.body.profileId;
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
        res.json(profile.attrs());
      });
    });
  });

  app.get('/factual', function(req, res, next) {
    Events.query(req.query, function(err, results) {
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
  app.get('/test', function(req, res, next) {
    res.render('test');
  });

};
