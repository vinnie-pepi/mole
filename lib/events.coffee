TR = require './timeRobot'
DAY = 86400


module.exports.createEvents = (options) ->
  tr = new TR(options)
  d = new Date()
  daysBefore = options.daysBefore || 30
  durationDays = options.durationsDays || 28

  start = d.getTime - DAY*daysBefore - (options.timezoneOffset || d.getTimezoneOffset()) * 60
  end = start + DAY * durationDays

  events = tr.simEvents start, end
  
  return events.map (e) =>
    return {
      userId: options.userId
      timestamp: e[0]
      latitude: e[1].latitude
      longitude: e[1].longitude
    }
