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

  render: () ->

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

window.PoiList = Backbone.View.extend
  tmplStr: """
             li.poi-item.list-group-item
               .selected-status
                 span.glyphicon.glyphicon-ok-sign
               .list-group-item-heading= jname
               p
                 = [ address, address_extended, locality, region ].join(', ')
               input.poi-location(type="hidden", data-lat=latitude, data-lng=longitude)
           """
  el: '#poi-list'

  events:
    'click button.back': 'showForm'
    'click .poi-item': 'toggleSelected'

  template: (locals) ->
    jade.compile(@tmplStr)(locals)

  toggleSelected: (e) ->
    $target = $(e.currentTarget)
    k = 'poi-selected'
    if $target.hasClass(k)
      $target.removeClass(k)
    else
      $target.addClass(k)
    selected = @getSelected()
    if selected.length > 0
      @trigger('poi:selected', selected)
    else
      @trigger('poi:deselected')

  showForm: () ->

  getSelected: () ->
    ret = []
    @$el.find('.poi-selected').each(() ->
      ret.push($(this).find('.poi-location').data())
    )
    return ret

  render: (results) ->
    @$el.html()
    if results.data.length > 0
      results.data.forEach (result) =>
        if @hasCoordinates(result)
          result['jname'] = result.name
          html = @template(result)
          @$el.append(html)
    else
      @renderNotFound()
    
  hasCoordinates: (data) ->
    !isNaN(parseFloat(data.latitude) + parseFloat(data.latitude))

  renderNotFound: () ->
    @$el.html('<li>NO RESULTS FOUND</li>')

