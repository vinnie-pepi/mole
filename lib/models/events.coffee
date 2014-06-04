FactualApi = require 'factual-api'
config = require('../config.json').factual.prod
factual = new FactualApi config.key, config.secret
factual.setBaseURI(config.baseUrl) if config.baseUrl

module.exports = (conn) ->
  TABLE = '/t/places'
  class Events
    @query: (q, cb) ->
      query =
        geo:
          "$circle":
            "$center": q.locus
            "$meters": q.distance

      if q.categories
        query['filters'] =
          "category_labels":
            "$search":
              q.categories

      else if q.search
        query['q'] = q.search

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


