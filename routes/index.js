module.exports = function(app) {
  app.get('/', function(req, res, next) {
    // list of profiles
    res.render('index');
  });

  app.get('/profile/:id?', function(req, res, next) {
    // var profile = db.get(id);
    res.render('profile');
  });

};
