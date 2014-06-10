class PoiController
  constructor: (options) ->
    @$root = $('.poi-section')
    @initHTML()
    @registerEvents()

    @poiList   = new PoiList()
    queryView = new QueryView({ poiList: @poiList })

    geoSelector = new GeoSelector({ mapBoxId: options.mapBoxId })
    @manualEntryView = new ManualEntryView({ geoSelector: geoSelector })

  initHTML: () ->
    @$poisRoot   = @$root.find('#poiSearchTab')
    @$manualRoot = @$root.find('#manualEntryTab')
    @$tabs = @$root.find('a[data-toggle="pill"]')

    @$tabs.filter('a[href="#poiSearchTab"]').tab('show')
    @activeTab = '#poiSearchTab'

  registerEvents: () ->
    @$tabs.on 'shown.bs.tab', (e) =>
      @activeTab = e.target.hash

  getLocations: () ->
    if @activeTab == '#poiSearchTab'
      return @poiList.getSelected()
    else if @activeTab == '#manualEntryTab'
      return @manualEntryView.getLocations()

window.PoiController = PoiController
