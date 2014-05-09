ProfilesList = Backbone.View.extend
  el: '#profileList'
  profileList: """
                 - each p in profiles
                     li.list-group-item
                       a(href='/profiles/'+ p.get('_id'))
                         h4.list-group-item-heading= p.get('id')
                         p.list-group-item-text= p.get('traits')
               """
  render: (profiles) ->
    profiles = new Profiles()
    tmpl = jade.compile(@profileList)
    profiles.fetch({
      success: (profiles) =>
        html = tmpl({
          profiles: profiles.models
        })
        @$el.html(html)
    })

ProfileForm = Backbone.View.extend
  el: '#profileForm'
  events:
    'click .uuid-gen': 'createUUID'
    'submit': 'createProfile'
  createUUID: () ->

  createProfile: (e) ->
    e.preventDefault()
    properties = @$el.serializeObject()
    profile = new Profile()
    profile.save(properties, {
      success: (profile) ->
        profilesListView.render()
      error: (err) ->
        alert(err)
    })
      
  
ProfilesRouter = Backbone.Router.extend

  routes:
    '': 'profiles'
    'new': 'createProfile'

  profiles: () ->
    profilesListView.render()

  createProfile: () ->
        

profilesListView = new ProfilesList()
profileFormView = new ProfileForm()
profilesRouter  = new ProfilesRouter()
Backbone.history.start()
