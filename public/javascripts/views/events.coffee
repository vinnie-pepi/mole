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
  initialize: () ->
    @$weekRangeSelect = $('select[name="week-range"')
    @$sliderContainer = $('.slider-container')
    @renderSliders()

  sliderTmplStr: """
                   div.slider-group
                     label= day
                     .slider-input
                       input.slider(type="text", name=day, value="8,16")
                 """

  el: '#timeSelector'

  weekdays: [ 'mondays', 'tuesdays', 'wednesdays', 'thursdays', 'fridays' ]
  weekends: [ 'saturdays', 'sundays' ]

  sliderTmpl: (locals) ->
    jade.compile(@sliderTmplStr)(locals)

  events:
    'submit form': 'generateEvents'
    'change select[name="week-range"]': 'renderSliders'

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

  generateEvents: (e) ->
    e.preventDefault()
    q = @$el.find('form:first').serializeObject()
    console.log(q)

