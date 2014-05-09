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
  el: '#map'
  render: () ->

window.listView = new ListView()

