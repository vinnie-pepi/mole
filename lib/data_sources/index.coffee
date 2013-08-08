factual = require './factual'

class DataSource
  constructor: ->


  getData: (query, cb) ->
    factual.getData(query, cb)

module.exports = new DataSource()
