conf = require('./config.json').mongo
MongoClient = require('mongodb').MongoClient
dbPath = [ conf.host, conf.port ].join(':') + '/' + conf.database

{EventEmitter} = require('events')

module.exports = class Db extends EventEmitter
  constructor: ->
    @profiles
    @georefs

  connect:  ->
    MongoClient.connect(dbPath, (err, db) =>
      @profiles   = db.collection('profiles')
      @emit('connected')
    )

  addProfile: (id, traits, cb) ->
    console.log('adding', id, traits)
    @profiles.update({ id: id },  { $set: { traits: traits } }, { upsert: true }, cb)

  getProfile: (id, cb) ->
    @profiles.findOne({ id: id }, cb)

  getProfiles: (cb) ->
    collection = @profiles
      .find({})
      .toArray (err, docs) ->
        cb(err, docs)
    
  saveGeoRefs: (id, refs, cb)  ->
    @profiles.update({ id: id }, { $set: { refs: refs } }, { upsert: true }, cb)


