Profile = Backbone.Model.extend
  urlRoot: '/profiles'

Profiles = Backbone.Collection.extend
  url: '/profiles'

profileList = """
                - each p in profiles
                    li.list-group-item
                      a(href='/profile/'+ p.get('_id'))
                        h4.list-group-item-heading= p.get('id')
                        p.list-group-item-text= p.get('traits')
              """
ProfilesRouter = Backbone.Router.extend
  routes:
    '': 'profiles'
    'new': 'createProfile'

  profiles: () ->
    profiles = new Profiles()
    tmpl = jade.compile(profileList)
    profiles.fetch({
      success: (profiles) ->
        html = tmpl({
          profiles: profiles.models
        })
        $('ul.list-group').append(html)
    })

  createProfile: () ->
        

profilesRouter = new ProfilesRouter()
Backbone.history.start()


# $(document).ready ->

    


