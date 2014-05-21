class Map extends EventEmitter
  constructor: (eleId) ->
    @map = L.mapbox.map(eleId, 'examples.map-i86nkdio')
    @registerEvents()

  registerEvents: () ->
    @map.on 'contextmenu', (e) =>
      @emit('homeRefSet', [ e.latlng.lat, e.latlng.lng ])
      @addHomeMarker(e.latlng)

  addEventMarkers: (events) ->
    @map.removeLayer(@eventsLayer) if @eventsLayer
    @eventsLayer = L.mapbox.featureLayer().addTo(@map)
    for event in events
      L.circleMarker(event, {radius: 5}).addTo(@eventsLayer)

  addHomeMarker: (latlng) ->
    @map.removeLayer(@homeMarker) if @homeMarker
    @homeMarker = L.marker(latlng)
    @map.addLayer(@homeMarker)

  center: () ->
    @map.fitBounds(@eventsLayer.getBounds())

window.Map = Map

MapView = Backbone.View.extend
  el: '#map'
