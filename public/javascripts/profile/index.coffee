class Profile
  constructor: (profileData) ->
    homeLatLng = [ 37.775, -122.419 ]
    events = profileData.refs || []
    form   = new Profile.Upload()
    map    = new Profile.Map(homeLatLng, events, form)
    events = new Profile.Events(events)
    
class Profile.Map
  constructor: (homeLatLng, events, @form) ->
    @map = L.mapbox.map('map', 'examples.map-9ijuk24y')
    @homeMarker
    @addHomeMarker(homeLatLng) if homeLatLng 
    @map.setView(homeLatLng, 12)
    @registerEvents()

  registerEvents: () ->
    @map.on 'contextmenu', (e) =>
      @addHomeMarker(e.latlng)
    @form.on 'baselineLoaded', (events) =>
      console.log(events)
      # @addEventMarkers(events)

  addEventMarkers: (events) ->
    console.log events
    @map.removeLayer(@eventsLayer) if @eventsLayer
    @eventsLayer = L.mapbox.featureLayer().addTo(@map)
    for event in events
      L.marker(event).addTo(@eventsLayer)

  addHomeMarker: (latlng) ->
    @map.removeLayer(@homeMarker) if @homeMarker
    @homeMarker = L.marker(latlng)
    @map.addLayer(@homeMarker)

class Profile.Upload extends EventEmitter
  constructor: () ->
    @$importForm = $('#importForm')
    @$importButton   = @$importForm.find('#importButton')
    @$importAction   = @$importForm.find('#importAction')
    @$importProgress = @$importForm.find('#importProgress')
    @initForm()

  initForm: () ->
    @$importForm.ajaxForm
      url: "/baseline_upload"
      beforeSend: () =>
        @$importProgress.show()
      uploadProgress: (e, position, total, percent) =>
        @updateProgress(percent)
      success: () =>
        @updateProgress(100)
      complete: (xhr) =>
        # events = ([parseFloat(d[2]), parseFloat(d[3])] for d in xhr.responseJSON when (d[2].length && d[3].length))
        @emit('baselineLoaded', xhr.responseJSON)

    @$importAction.change () =>
      @$importForm.submit()

    @$importButton.click (e) =>
      e.preventDefault()
      @$importAction.click()

  updateProgress: (percent) ->
    @$importProgress.find('.progress-bar').width(percent)

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


window.Profile = Profile