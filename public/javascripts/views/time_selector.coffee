window.TimeSelector = Backbone.View.extend
  initialize: (options) ->
    @poiList = options.poiList
    @geoSelector = options.geoSelector
    @userId  = options.userId
    @timestamps = new Timestamps()
    @initHTML()
    @renderSliders()
    @registerEvents()


  confirmTmplStr: """
    #confirm.modal
      .modal-dialog.modal-md
        .modal-content
          .alert.alert-info
  """
              
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

    $('body').append(jade.compile(@confirmTmplStr)())
    @$confirm = $('#confirm')
    @$confirm.modal({show: false})
    @$generateBtn.prop('disabled', true)

  registerEvents: () ->
    @poiList.on 'poi:selected', (selected) =>
      @$generateBtn.prop('disabled', false)
      @pois = selected
    @poiList.on 'poi:deselected', () =>
      @$generateBtn.prop('disabled', true)
    @geoSelector.on 'geoSelection', (selected) =>
      @pois = selected

    $('a[data-toggle="pill"]').on 'shown.bs.tab', (e) =>
      h = e.target.hash
      if h == '#poiSearchTab'
        @pois = @poiList.getSelected()
      else if h == '#manualEntryTab'
        @pois = @geoSelector.getLatLng()

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
      

