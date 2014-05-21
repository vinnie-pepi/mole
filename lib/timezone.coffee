http   = require('http')
qs     = require('querystring')
config = require('./config').geonames
{parseString} = require 'xml2js'

BASE_URL = 'http://api.geonames.org/timezone'

module.exports.getTZ = getTZ = (lat, lng, cb) ->
  query =
    lat: lat
    lng: lng
    username: config.username
  qUrl = [ BASE_URL, qs.stringify(query) ].join('?')
  req = http.get(qUrl, (res) ->
    chunks = []
    res.on 'data', (chunk) ->
      chunks.push(chunk)
    res.on 'end', () ->
      xmlStr = Buffer.concat(chunks).toString()
      jsXML = parseString xmlStr, (err, parsed) ->
        if err then return cb(err)
        cb(err, parsed.geonames.timezone[0])
  ).on('error', (err) ->
    cb(err)
  )
  

# USAGE 
# fixture =
#   lat: 43.074875
#   lng: -70.758692
#   username: config.username
# getTZ fixture.lat, fixture.lng, (err, data) ->
#   if err then return console.log(err)
#   console.log(data)

  
