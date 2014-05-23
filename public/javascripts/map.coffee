class Map extends EventEmitter
  constructor: (eleId, mapboxId) ->
    @map = L.mapbox.map(eleId, mapboxId)
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
