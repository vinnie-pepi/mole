ListView = Backbone.View.extend
  el: '#refsTable'

  tmplStr: """
             tr
               td= timestamp
               td= lat
               td= lng
           """

  template: (locals) ->
    jade.compile(@tmplStr)(locals)

  render: () ->
    refs = profile.attributes.refs || []
    @$el.html()
    for ref in refs
      locals =
        timestamp: ref[0]
        lat: ref[1]
        lng: ref[2]
      html = @template(locals)
      @$el.append(html)

MapView = Backbone.View.extend
  initialize: () ->
    @map = new Map('map')
    @map.on('homeRefSet', (latlng) ->
      profile.set('homeRef', latlng)
      profile.save()
    )

  el: '#map'

  render: () ->
    refs = profile.get('refs') || []
    if refs and refs.length > 0
      refs = refs.map (ref) ->
        return [ ref[1], ref[2] ]
      @map.addEventMarkers(refs)

    home = profile.get('homeRef')
    if home
      @map.addHomeMarker(home)

  center: (homeRef) ->
    if homeRef and homeRef[0] and homeRef[1]
      if @map.eventsLayer
        @map.center()
      else
        @map.map.setView(new L.latLng(homeRef), 10)

window.listView = new ListView()
window.mapView = new MapView()

