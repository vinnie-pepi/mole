class ProfileController
  constructor: (@Profile) ->
  index: (req, res, next) =>
    @Profile.all (err, docs) ->
      if (err) then return next(err)
      res.json(docs)
  new: (req, res, next) =>
  create: (req, res, next) =>
    @Profile.new req.body, (err, doc) ->
      if (err) then return next(err)
      res.json(doc)
  show: (req, res, next) =>
    @Profile.findById req.params.id, (err, profile) ->
      if (err) then return next(err)
      if (req.xhr)
        res.json(profile.attrs())
      else
        res.render('profile', { profileData: profile.attrs()})
  edit: (req, res, next) =>
  update: (req, res, next) =>
    @Profile.findById req.params.id, (err, profile) ->
      profile.update req.body, (err) ->
        if (err) then return next(err)
        res.status(200).end()
  destroy: (req, res, next) =>
    @Profile.findById req.params.id, (err, profile) ->
      profile.destroy (err, result) ->
        if (err) then return next(err)
        res.status(200).end()

module.exports = ProfileController
