FactualApi = require 'factual-api'
config = require('./config.json').factual
factual = new FactualApi config.KEY, config.SECRET

class Factual
  constructor: ->
    
  getData: ->
    factual.get '/t/places'
      q: "starbucks"
      "include_count": "true"
    , (error, res) =>
        console.log res.data


module.exports = new Factual()
