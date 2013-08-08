module.exports = function(app) {
  app.get('/', function(req, res, next) {
    // list of profiles
    res.render('index', { title: 'Express' });
  });

  app.get('/profile/:id?', function(req, res, next) {
    var profile = db.get(id);
    res.render('profile', { data: profile });
  });

  app.get('/placefinder', function(req, res, next) {
    res.render('placefinder', { title: 'Express' });
  });
};
