window.TimeSelector = Backbone.View.extend
  weekdays: [ 'monday', 'tuesday', 'wednesday', 'thursday', 'friday' ]
  weekends: [ 'saturday', 'sunday' ]
  confirmTmplStr: """
    #confirm.modal
      .modal-dialog.modal-lg
        .modal-content
          .modal-header
            h4 Generated Results
          .modal-body
            table.table.table-striped.table-bordered
              thead
                tr
                  th \#
                  th Timestamp
                  th Latitude
                  th Longitude
              tbody
          .modal-footer
            button#cancelSubmit.btn.btn-default Cancel
            button#submitEvents.btn.btn-primary Submit Events
  """
  confirmTrStr: """
    tr
      td= lineNum
      td= timestamp
      td= lat
      td= lng
  """
  sliderTmplStr: """
    div.slider-group
      label= day
      .slider-input
        input.slider(type="text", name=day, value="8,16")
  """

  el: '#timeSelector'

  events:
    'submit form': 'generateEvents'
    'change select[name="weekRange"]': 'renderSliders'

  initialize: (options) ->
    @poiController  = options.poiController
    @eventGenerator = options.eventGenerator
    @userId         = options.userId
    @initHTML()
    @registerEvents()
    @renderSliders()

  initHTML: () ->
    dateTimeOpts =
      todayHighlight: true

    @$dateStart = $('.datetime-start')
    @$dateEnd   = $('.datetime-end')

    @$dateStart.datepicker(dateTimeOpts)
    @$dateEnd.datepicker(dateTimeOpts)
      .datepicker('update', dateNow)

    dateNow = moment().format('MM/DD/YYYY')

    @$weekRangeSelect = @$el.find('select[name="weekRange"]')
    @$sliderContainer = @$el.find('.slider-container')

    $('body').append(jade.compile(@confirmTmplStr)())
    @$confirm = $('#confirm')
    @$confirm.modal({show: false})
    @$previewTable = @$confirm.find('tbody')

    @$generateBtn     = @$el.find('.btn-generate')
    # @$generateBtn.prop('disabled', true)

  registerEvents: () ->
    @$confirm.find('#submitEvents').click () =>
      @submit()
    @$confirm.find('#cancelSubmit').click () =>
      @hidePreview()

  template: (str, locals) ->
    jade.compile(str)(locals)

  renderSliders: () ->
    weekRange = @$weekRangeSelect.val()
    htmls = []
    tStr = @sliderTmplStr
    if weekRange == 'weekdays'
      htmls.push(@template(tStr, { day: day })) for day in @weekdays
    else if weekRange == 'weekends'
      htmls.push(@template(tStr, { day: day })) for day in @weekends
    else
      htmls.push(@template(tStr, { day: weekRange }))
    html = htmls.join('')
    @$sliderContainer.html(html)
    @$sliderContainer.find('.slider').slider
      min: 0
      max: 24
      value: [ 8, 16 ]

  submit: () ->
    console.log(@events)
    $.ajax
      type: "PUT"
      url: "/profile/#{@userId}/events"
      data:
        refs: @events
      success: (ret, status, jqXHR) ->
        document.location.href = "/profiles/#{ret._id}"

  showPreview: (events) ->
    @events = events
    @$previewTable.html('')
    for event, i in events
      html = @template @confirmTrStr,
        lineNum: i + 1
        timestamp: event[0]
        lat: event[1]
        lng: event[2]
      @$previewTable.append(html)
    @$confirm.modal('show')

  hidePreview: () ->
    @$confirm.modal('hide')

  validateFields: () ->
    datestart = moment(@$dateStart.val()).isValid()
    dateend = moment(@$dateEnd.val()).isValid()
    if !datestart
      @$dateStart.parent().addClass('has-error')
    if !dateend
      @$dateEnd.parent().addClass('has-error')
    if datestart and dateend
      return true
    else
      return false

  generateEvents: (e) ->
    e.preventDefault()
    q = @$el.find('form:first').serializeObject()
    locations = @poiController.getLocations()
    unless locations.length > 0
      return alert('need to select a location')
    return unless @validateFields()
    events = @eventGenerator.generateEvents(q, locations)
    @showPreview(events)

