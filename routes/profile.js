// routes for profile

module.exports = function(app, model) {
  var Profile = model;

  app.get('/profile/:id?', function(req, res, next) {
    Profile.findById(req.params.id, function(err, profile) {
      res.render('profile2', { profileData: profile.attrs()});
    });
  });

  app.post('/profile/:id', function(req, res, next) {
  });

}
