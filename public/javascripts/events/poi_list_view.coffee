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

