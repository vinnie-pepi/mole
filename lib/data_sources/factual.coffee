FactualApi = require 'factual-api'
config = require('../config.json').factual
factual = new FactualApi config.key, config.secret

class Factual
  constructor: ->
    
  getData: (query, cb)->
    factual.get '/t/places',
      "q": query.q
      "include_count": "true"
    , (error, res) =>
      return cb(error) if error
      return cb(null, res.data)


module.exports = new Factual()
