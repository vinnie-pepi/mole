
module.exports = function(app, model) {
  app.get('/profile/:id/events/new', function(req, res, next) {
    res.render('events/new');
  });

  app.post('/profile/:id/events/create', function(req, res, next) {
  });

  app.get('/events/generate', function(req, res, next) {
    homeLatLng = [ 37.775, -122.419 ]
    model.generate(homeLatLng, 1000, 'coffee', function(err, results) {
      if err 
        return res.json(err);
      res.json(results);
    });

  });
}
