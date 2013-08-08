FactualApi = require 'factual-api'
config = require('../config.json').factual
factual = new FactualApi config.key, config.secret
factual.setBaseURI(config.baseUrl) if config.baseUrl

class Factual
  constructor: ->
    @api = factual
    
  getData: (query, cb)->
    factual.get '/t/places',
      q: query.q
      filters: {
        "$or": [
          {
            "address": {"$search": query.location}
          },
          {
            "locality": {"$search": query.location}
          }
        ]
      }
    , (error, res) =>
      if error
        console.log error
        return cb(error)
      return cb(null, res.data)

module.exports = new Factual()
