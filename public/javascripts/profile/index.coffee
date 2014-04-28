class Profile
  constructor: () ->
    homeLatLng = [ 37.775, -122.419 ]
    events = []
    map = new Profile.Map(homeLatLng, events)
    form = new Profile.Upload(map)
    
class Profile.Map
  constructor: (homeLatLng, events) ->
    @map = L.mapbox.map('map', 'examples.map-9ijuk24y')
    @homeMarker
    @addHomeMarker(homeLatLng) if homeLatLng 
    @map.setView(homeLatLng, 12)
    @registerEvents()

  registerEvents: () ->
    @map.on 'contextmenu', (e) =>
      @addHomeMarker(e.latlng)

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

class Profile.Upload
  constructor: (@map) ->
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
        events = ([parseFloat(d[2]), parseFloat(d[3])] for d in xhr.responseJSON when (d[2].length && d[3].length))
        @map.addEventMarkers(events)

    @$importAction.change () =>
      @$importForm.submit()

    @$importButton.click (e) =>
      e.preventDefault()
      @$importAction.click()

  updateProgress: (percent) ->
    @$importProgress.find('.progress-bar').width(percent)

class Profile.Events
  constructor: () ->
    # contains all events attached to this profile


window.Profile = Profile
