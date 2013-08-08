conf = require('./config.json').mongo
MongoClient = require('mongodb').MongoClient
dbPath = [ conf.host, conf.port ].join(':') + '/' + conf.database

EventEmitter = require('events').EventEmitter

module.exports = class Db extends EventEmitter
  constructor: ->
    MongoClient.connect(dbPath, (err, db) ->
      users   = db.collection('users')
      georefs = db.collection('georefs')
      @emit('connected', db, users, georefs)
    )
  
