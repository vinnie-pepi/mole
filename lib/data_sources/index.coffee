factual = require './factual'

class DataSource
  constructor: ->


  getData: (query, cb) ->
    factual.getData(query, cb)

  getNoises: (locality, cb) ->
    factual.getNoises locality, cb

module.exports = new DataSource()
