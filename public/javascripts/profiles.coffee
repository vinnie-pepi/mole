window.Profile = Backbone.Model.extend
  urlRoot: '/profiles'
  idAttribute: '_id'

window.Profiles = Backbone.Collection.extend
  url: '/profiles'


