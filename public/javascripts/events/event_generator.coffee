class EventGenerator
  constructor: (options) ->
    @timestamps = new Timestamps()

  offsetCoord: (coord, offset) ->
    neg = !!Math.round(Math.random()*1)
    randOffset = Math.random() * offset
    if neg then randOffset = -(randOffset)
    return coord + randOffset

  generateEvent: (stamp, offset, locations) ->
    poi = getRandomInArray(locations)
    lat = parseFloat(poi.lat)
    lng = parseFloat(poi.lng)
    if offset and offset > 0
      lat = @offsetCoord(lat, offset)
      lng = @offsetCoord(lng, offset)
    return [ stamp, lat, lng ]

  generateEvents: (q, locations) ->
    numEvents = q.numEvents || null
    stamps = @timestamps.generateStamps(q, numEvents)
    events = []

    for stamp in stamps
      events.push(@generateEvent(stamp, q.degreeOffset, locations))

    return events

window.EventGenerator = EventGenerator

