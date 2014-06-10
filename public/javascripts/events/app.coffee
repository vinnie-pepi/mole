class EventApp
  constructor: (options) ->
    eventGenerator = new EventGenerator()
    poiController = new PoiController(options)
    timeSelector  = new TimeSelector
      poiController: poiController,
      eventGenerator: eventGenerator,
      userId: options._id

window.EventApp = EventApp
