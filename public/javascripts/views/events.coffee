window.QueryView = Backbone.View.extend
  initialize: (options) ->
    @poiList = options.poiList
  el: '#poiQuery'
  events:
    'click button': 'performQuery'
  performQuery: (e) ->
    e.preventDefault()
    q = @$el.serializeObject()
    q.locus = q.locus.replace(' ', '').split(',')

    $.get '/factual', q, (results) =>
      @poiList.render(results)

  render: () ->

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

window.TimeSelector = Backbone.View.extend
  initialize: (options) ->
    @poiList = options.poiList
    @userId  = options.userId
    @timestamps = new Timestamps()
    @initHTML()
    @renderSliders()
    @registerEvents()

  sliderTmplStr: """
                   div.slider-group
                     label= day
                     .slider-input
                       input.slider(type="text", name=day, value="8,16")
                 """

  el: '#timeSelector'

  weekdays: [ 'monday', 'tuesday', 'wednesday', 'thursday', 'friday' ]
  weekends: [ 'saturday', 'sunday' ]

  sliderTmpl: (locals) ->
    jade.compile(@sliderTmplStr)(locals)

  events:
    'submit form': 'generateEvents'
    'change select[name="weekRange"]': 'renderSliders'

  initHTML: () ->
    @$weekRangeSelect = $('select[name="weekRange"]')
    @$sliderContainer = $('.slider-container')
    @$generateBtn     = $('.btn-generate')
    # @$generateBtn.prop('disabled', true)

  registerEvents: () ->
    @poiList.on 'poi:selected', (selected) =>
      @$generateBtn.prop('disabled', false)
      @pois = selected
    @poiList.on 'poi:deselected', () =>
      @$generateBtn.prop('disabled', true)

  render: () ->

  renderSliders: () ->
    weekRange = @$weekRangeSelect.val()
    htmls = []
    if weekRange == 'weekdays'
      htmls.push(@sliderTmpl({ day: day })) for day in @weekdays
    else if weekRange == 'weekends'
      htmls.push(@sliderTmpl({ day: day })) for day in @weekends
    else
      htmls.push(@sliderTmpl({ day: weekRange }))
    html = htmls.join('')
    @$sliderContainer.html(html)
    @$sliderContainer.find('.slider').slider
      min: 0
      max: 24
      value: [ 8, 16 ]

  offsetCoord: (coord, offset) ->
    neg = !!Math.round(Math.random()*1)
    randOffset = Math.random() * offset
    if neg then randOffset = -(randOffset)
    return coord + randOffset

  generateEvent: (stamp, offset) ->
    poi = getRandomInArray(@pois)
    newCoords =
      lat: poi.lat
      lng: poi.lng
    if offset and offset > 0
      newCoords.lat = @offsetCoord(newCoords.lat, offset)
      newCoords.lng = @offsetCoord(newCoords.lng, offset)
    return [ stamp, newCoords.lat, newCoords.lng ]

  generateEvents: (e) ->
    e.preventDefault()
    q = @$el.find('form:first').serializeObject()
    stamps = @timestamps.generateStamps(q)
    events = []
    for stamp in stamps
      events.push(@generateEvent(stamp, q.degreeOffset))
    $.ajax
      type: "PUT"
      url: "/profile/#{@userId}/events"
      data:
        refs: events
      success: (ret, status, jqXHR) ->
        # window.location = "/profile/#{docs._id}"
        console.log(ret)
      

