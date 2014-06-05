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
    @layers = []
    @currentLayer
    @initModal()
    @map = L.mapbox.map('map', @mapBoxId)

  start: () ->
    @layers.forEach (layer) =>
      layer.target.click () =>
        @show(layer.input)

  initModal: () ->
    @$modal = $(@template(@mapModalStr))
    @$modal.appendTo(@$modalContainer)
    @$modal.modal
      show: false
    @$modal.on 'hide.bs.modal', () =>
      if @map.hasLayer(@currentLayer)
        @map.removeLayer(@currentLayer)

  registerLayer: (name, target, input) ->
    @layers.push
      name: name
      target: target
      input: input

  show: (input) ->
    @currentLayer = L.mapbox.featureLayer().addTo(@map)
    latlng = input.val().split(/\s?,\s?/)
    marker = L.marker new L.LatLng(latlng[0], latlng[1]),
      draggable: true
    marker.addTo(@currentLayer)
    @$modal.modal('show')
    # @map.setView()
