mongoConf = 
  host: 'mongodb://127.0.0.1',
  port: 27017,
  database: 'mole'

# config = require('./config.json').mongo
MongoClient = require('mongodb').MongoClient
dbPath = [ mongoConf.host, mongoConf.port ].join(':') + '/' + mongoConf.database
console.log dbPath
MongoClient.connect(dbPath, (err, db) ->
  console.log(err, db)
)

module.exports = 'hello'

