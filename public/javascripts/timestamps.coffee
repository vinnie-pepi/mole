class Timestamps
  CONST:
    weekdays: [1..5]
    weekends: [0,6]
    daymap:
      monday: 1
      tuesday: 2
      wednesday: 3
      thursday: 4
      friday: 5

  constructor: () ->
    @SEC = 1000
    @MIN = 60*@SEC
    @HOUR = 60*@MIN
    @DAY = 24*@HOUR

  generateDateSet: (options) ->
    # TODO: localize based on timezone
    start = moment(options.dateStart, "MM/DD/YYYY")
    end   = moment(options.dateEnd, "MM/DD/YYYY")
    dateSet = []
    while start <= end
      if options.weekRange == 'weekdays' and start.day() in @CONST.weekdays
        dateSet.push(moment(start))
      else if options.weekRange == 'weekends' and start.day() in @CONST.weekends
        dateSet.push(moment(start))
      else if options.weekRange in Object.keys(@CONST.daymap)
        if start.day() == @CONST.daymap[options.weekRange]
          dateSet.push(moment(start))
      start.add(1, 'day')
    return dateSet

  generateStamps: (options) ->
    range = @generateDateSet(options)
    stamps = []
    # TODO: get numEvents random dates in range
    for date in range
      dayName = date.format('dddd').toLowerCase()
      if options[dayName]
        timeRange = options[dayName].split(',')
        startMil = parseInt(timeRange[0]) * @HOUR
        endMil   = parseInt(timeRange[1]) * @HOUR
        diff     = endMil - startMil
        randMil  = Math.round(Math.random() * diff)
      stamps.push(date.add(startMil + randMil, 'ms').toISOString())
    return stamps


window.Timestamps =  Timestamps
