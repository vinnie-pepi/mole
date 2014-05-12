

window.Profile = Backbone.Model.extend
  urlRoot: '/profiles'
  idAttribute: '_id'
  toGeoJSON: () ->
    refs = @get('refs')
    featuresGroup = []

window.Profiles = Backbone.Collection.extend
  url: '/profiles'
