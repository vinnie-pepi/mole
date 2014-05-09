ObjectID = require('mongodb').ObjectID
{EventEmitter} = require('events')

schema =
  id: String
  traits: String
  refs: Array  # lat, lng, timestamp
  homeRef: Array
  updatedAt: Date

addUpdatedStamp = (obj) ->
  obj['updatedAt'] = new Date()

module.exports = (db) ->

  coll = db.collection('profiles')

  class Profile extends EventEmitter
    constructor: (@doc) ->
      @id = new ObjectID("#{@doc._id}")

    update: (attr, val, cb) ->
      @props[attr] = val
      addUpdatedStamp(@props)
      coll.update({ _id: @id },  { $set: @props }, { upsert: true }, cb)

    pushRefs: (refs, cb) ->
      coll.update({ _id: @id }, { $addToSet: { refs: { $each: refs } } }, (err, result) =>
        return cb(err) if err
        @sendResponse(cb)
      )

    sendResponse: (cb) ->
      Profiles.findById(@id, (err, doc) ->
        cb(err, doc)
      )

    homeRef: (coords) ->
      if coords
        @update('homeRef', coords, (err, result) ->
        )
      else
        return @doc.homeRef

    attrs: () ->
      @doc

    refs: () ->
      @doc.refs


  class Profiles
    @all: (cb) ->
      coll.find({})
        .toArray (err, docs) ->
          cb(err, docs)

    @findById: (id, cb) ->
      id = new ObjectID("#{id}")
      coll.findOne({ _id: id }, (err, doc) ->
        if err then return cb(err)
        cb(null, new Profile(doc))
      )

    @new: (params, cb) ->
      for key in params
        if !schema.hasOwnProperty(key)
          delete params[key]
      addUpdatedStamp(params)
      id = params['id']
      delete params['id']
      coll.update({ id: id },  { $set: params }, { upsert: true }, cb)

    constructor: (opts) ->
      return new Profile(opts)
  
  return Profiles




