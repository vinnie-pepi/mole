TR = require './timeRobot'
DAY = 86400000
dataSource = require './data_sources'


module.exports.getNoises = (targets, cb) ->
  locality = targets[0].locality
  dataSource.getNoises locality, (err, pois) =>
    return cb err, pois



module.exports.createEvents = (options) ->
  tr = new TR(options)
  d = new Date()
  daysBefore = options.daysBefore || 30
  durationDays = options.durationsDays || 28

  start = d.getTime() - DAY*daysBefore - (options.timezoneOffset || d.getTimezoneOffset()) * 60000
  end = start + DAY * durationDays

  events = tr.simEvents start, end
  
  return events.filter (e) =>
    return e[1].latitude && e[1].longitude
  .map (e) =>
    p = e[1]
    return {
      userId: options.userId
      timestamp: e[0]
      latitude: p.latitude
      longitude: p.longitude
      name: p.name
      address: p.address
      isTarget: p.isTarget
      isNoise: p.isNoise
    }
