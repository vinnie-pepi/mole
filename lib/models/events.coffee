FactualApi = require 'factual-api'
config = require('../config.json').factual
factual = new FactualApi config.key, config.secret
factual.setBaseURI(config.baseUrl) if config.baseUrl

module.exports = (conn) ->
  TABLE = '/t/places'
  class Events
    @generate: (locus, distance, categories, cb) ->
      query =
        filters:
          "category_labels":
            "$search":
              categories
        geo:
          "$circle":
            "$center": locus
            "$meters": distance

      console.log(TABLE, query)
        
      factual.get(TABLE, query, cb)

    constructor: () ->

  class Event
    constructor: () ->
      schema =
        latlng: []
        keywords: []
        timestamp: new Date()

  return Events


