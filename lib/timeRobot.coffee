MINUTE = 60
HOUR = 3600
DAY = 86400

PERCENTAGES =
  targets: 10
  noises: 60


class TimeRobot
  constructor: (options) ->
    {@targets, @home, @work, @noises} = options.pois
    @tSize = @targets.entities.length
    @nSize = if @noises then @noises.entities.length else 0


  simEvents: (start, end) ->
    events = []
    t = new Date(start)
    hours = t.getHours()
    day = t.getDay()
    h = start

    while h < end
      e = @getEvent(hours, day)
      events.push [h, e] if e
      h += HOUR
      hours = @getNextHour hours
      day = @getDay day, hours
    return events

   getEvent: (h, d) ->
     if @isHomeTime(h, d)
       return @home if @home
       return null
     else if @isWorkTime(h, d)
       return @work if @work
       return null
     else
       return @generateEvent(h)

   getNextHour: (h) ->
     h += 1
     return h if h < 24
     return 0

   getDay: (d, h) ->
     d += 1 if h == 0
     return d if d < 8
     return 1

   isHomeTime: (h, d) ->
     return if (h >= 0 and h <= 6) then true else false

   isWorkTime: (h, d) ->
     if d < 6
       return if ((h >= 8 and h <= 12) or (h >= 13 and h <= 17)) then true else false
     else
       return false

   generateEvent: (h) ->
     r = Math.random() * 100
     tp = @targets.percentage || PERCENTAGES.targets
     if r <= tp
       return @targets.entities[Math.round(Math.random() * @tSize)]
     else if @nSize > 0
       np = @noises.percentage || PERCENTAGES.noises
       return @noises.entities[Math.round(Math.random() * @nSize)]
     return null

module.exports = TimeRobot
