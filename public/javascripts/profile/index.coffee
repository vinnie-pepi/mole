class Profile
  constructor: (profileData) ->
    homeLatLng = [ 37.775, -122.419 ]
    events = profileData.refs || []
    map    = new Map(homeLatLng, events, form)
    events = new Profile.Events(events)
    


class Profile.Events
  rowTemplate = """
                  tr
                    td= lat
                    td= long
                """

  constructor: (@events) ->
    @initHTML()
    @renderTable()

  initHTML: () ->
    @$eventTable = $('#eventTable')

  renderTable: ->
    jadeRowTemplate = jade.compile(rowTemplate)
    for row in @events
      html = jadeRowTemplate(
        lat: row[0]
        long: row[1]
      )
      @$eventTable.append(html)


window.ProfilePage = Profile
