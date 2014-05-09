ListView = Backbone.View.extend
  el: '#refsTable'

  tmplStr: """
             tr
               td= timestamp
               td= lat
               td= lng
           """

  template: () ->
    jade.compile(@tmplStr)

  render: () ->
    refs = profile.attributes.refs || []
    @$el.html()
    for ref in refs
      html = @template
        timestamp: ref[0]
        lat: ref[1]
        lng: ref[2]
      @$el.append(html)

MapView = Backbone.View.extend
  initialize: () ->
    @map = new Map('map')
    @map.on('homeRefSet', (latlng) ->
      profile.set('homeRef', latlng)
    )

  homeLatLng: [ 37.775, -122.419 ]

  el: '#map'

  render: () ->
    refs = profile.get('refs') || []
    home = profile.get('homeRef') || @homeLatLng
    @map.addHomeMarker(refs)
    @map.addEventMarkers(refs)

window.listView = new ListView()
window.mapView = new MapView()

