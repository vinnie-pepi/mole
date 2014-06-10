window.QueryView = Backbone.View.extend
  initialize: (options) ->
    @poiList = options.poiList
    @initSearchType()

  el: '#poiQuery'

  events:
    'click #performSearch': 'performQuery'

  performQuery: (e) ->
    e.preventDefault()
    q = @$el.serializeObject()
    q.locus = q.locus.replace(' ', '').split(',')

    $.get '/factual', q, (results) =>
      @poiList.render(results)

  initSearchType: () ->
    $root = @$el.find('#searchType')
    $input = $root.find('input:first')
    $button = $root.find('button:first')
    $selector = $root.find('.dropdown-menu a:first')
    options = [ 'search', 'categories' ]
    selectedIdx = 0

    toggleSelection = () ->
      nextIdx = nextIdxLooped(options, selectedIdx)
      $button.html(options[selectedIdx])
      $selector.html(options[nextIdx])
      $input.attr('name', options[selectedIdx])
      selectedIdx = nextIdx
    
    $button.click (e) ->
      e.preventDefault()
    $selector.click (e) ->
      e.preventDefault()
      toggleSelection()

    toggleSelection()

