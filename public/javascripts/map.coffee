class Map extends EventEmitter
  constructor: (homeLatLng, events, @form) ->
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
    @emit('homeRefSet', latlng)

window.Map = Map

MapView = Backbone.View.extend
  el: '#map'
