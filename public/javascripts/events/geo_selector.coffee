window.GeoSelector = Backbone.View.extend
  mapModalStr: """
    .modal
      .modal-dialog.modal-lg
        .modal-content
          #map
  """

  template: (str, locals) ->
    fn = jade.compile(str)
    fn(locals)
    
  initialize: (options) ->
    @mapBoxId = options.mapBoxId
    @$modalContainer = $('#mapBoxModal')
    @currentLayer
    @initModal()
    @map = L.mapbox.map('map', @mapBoxId)

  initModal: () ->
    @$modal = $(@template(@mapModalStr))
    @$modal.appendTo(@$modalContainer)
    @$modal.modal
      show: false
    @$modal.on 'hide.bs.modal', () =>
      if @map.hasLayer(@currentLayer)
        @map.removeLayer(@currentLayer)


  getLatLng: () ->
    return @latLng

  show: (input) ->
    @currentLayer = L.mapbox.featureLayer().addTo(@map)
    latlng = input.val().split(/\s?,\s?/)
    latlngObj = new L.LatLng(latlng[0], latlng[1])
    marker = L.marker latlngObj,
      draggable: true

    marker.addTo(@currentLayer)
    
    marker.on 'dragend', =>
      l = marker.getLatLng()
      @latLng = [ l.lat, l.lng ]
      # this shouldn't go here
      input.val(@latLng.join(', '))
      @trigger('geoSelection', [[ l.lat, l.lng ]])

    @$modal.modal('show')
    @map.invalidateSize()
    @map.setView(latlngObj)
