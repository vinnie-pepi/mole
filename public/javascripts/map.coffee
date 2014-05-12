class Map extends EventEmitter
  constructor: (eleId) ->
    @map = L.mapbox.map(eleId, 'examples.map-9ijuk24y')
    @registerEvents()

  registerEvents: () ->
    @map.on 'contextmenu', (e) =>
      @emit('homeRefSet', [ e.latlng.lat, e.latlng.lng ])
      @addHomeMarker(e.latlng)

  addEventMarkers: (events) ->
    @map.removeLayer(@eventsLayer) if @eventsLayer
    @eventsLayer = L.mapbox.featureLayer().addTo(@map)
    for event in events
      L.marker(event).addTo(@eventsLayer)

  addHomeMarker: (latlng) ->
    @map.removeLayer(@homeMarker) if @homeMarker
    @homeMarker = L.marker(latlng)
    @map.addLayer(@homeMarker)

window.Map = Map

MapView = Backbone.View.extend
  el: '#map'
