window.ManualEntryView = Backbone.View.extend
  el: '#manualEntry'

  initialize: (options) ->
    @geoSelector = options.geoSelector
    @initHTML()
    @registerEvents()

  initHTML: () ->
    @$geoSelectBtn = @$el.find('span')
    @$manualInput  = @$el.find('input:first')

  registerEvents: () ->
    @$geoSelectBtn.click () =>
      @geoSelector.show(@$manualInput)

  getLocations: () ->
    latlng = @$manualInput.val().split(/\s?,\s?/)
    return [ { lat: latlng[0], lng: latlng[1] } ]

    

