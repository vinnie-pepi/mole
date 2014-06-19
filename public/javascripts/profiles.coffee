window.Profile = Backbone.Model.extend
  urlRoot: '/profiles'
  idAttribute: '_id'
  toGeoJSON: () ->

window.Profiles = Backbone.Collection.extend
  url: '/profiles'
  model: Profile
