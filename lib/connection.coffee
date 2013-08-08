conf = require('./config.json').mongo
MongoClient = require('mongodb').MongoClient
dbPath = [ conf.host, conf.port ].join(':') + '/' + conf.database

{EventEmitter} = require('events')

module.exports = class Db extends EventEmitter
  constructor: ->
    @users
    @georefs

  connect:  ->
    MongoClient.connect(dbPath, (err, db) =>
      @users   = db.collection('users')
      @georefs = db.collection('georefs')
      @emit('connected')
    )

  addProfile: (id, traits, cb) ->
    console.log('adding', id, traits)
    @users.update({ id: id },  { $set: { traits: traits } }, { upsert: true }, cb)

  getProfile: (id, cb) ->
    @users.findOne({ id: id }, cb)

  getProfiles: (id) ->
    collection = @users
      .find({})
      .limit(10)
      .toArray (err, docs) ->
        console.dir(docs)
    
  
