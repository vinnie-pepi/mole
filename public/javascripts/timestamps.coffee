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

  getRandTime: (date, start, end) ->
    newDate  = moment(date)
    diff     = end - start
    randMil  = Math.round(Math.random() * diff)
    return newDate.add(start + randMil, 'ms').toISOString()

  generateStamp: (date, options) ->
    dayName = date.format('dddd').toLowerCase()
    if options[dayName]
      timeRange = options[dayName].split(',')
      startMil = parseInt(timeRange[0]) * @HOUR
      endMil   = parseInt(timeRange[1]) * @HOUR
      return @getRandTime(date, startMil, endMil)

  generateStamps: (options, numEvents) ->
    range = @generateDateSet(options)
    stamps = []
    if numEvents
      for i in [1..numEvents]
        date = getRandomInArray(range)
        stamps.push(@generateStamp(date, options))
    else
      for date in range
        stamps.push(@generateStamp(date, options))

    return stamps


window.Timestamps =  Timestamps
