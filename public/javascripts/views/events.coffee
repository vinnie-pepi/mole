window.QueryView = Backbone.View.extend
  el: '#poiQuery'
  events:
    'click button': 'performQuery'
  performQuery: (e) ->
    e.preventDefault()
    q = @$el.serializeObject()
    q.locus = q.locus.replace(' ', '').split(',')

    $.get '/factual', q, (results) ->
      console.log(results)

  render: () ->
