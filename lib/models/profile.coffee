ObjectID = require('mongodb').ObjectID
_ = require('lodash')
{EventEmitter} = require('events')

schema =
  id: String
  traits: String
  refs: Array  # timestamp, lat, lng
  homeRef: Array
  tzOffset: Number # float
  updatedAt: Date

addUpdatedStamp = (obj) ->
  obj['updatedAt'] = new Date()

sanitizeAttrs = (obj) ->
  for key in obj
    if !schema.hasOwnProperty(key)
      delete obj[key]
  delete obj['_id']
  addUpdatedStamp(obj)

module.exports = (db) ->

  coll = db.collection('profiles')

  class Profile extends EventEmitter
    constructor: (@doc) ->
      if @doc._id
        @id = new ObjectID("#{@doc._id}")
      else
        @id = null
        @isNewRecord = true

    saveNew: (cb) ->
      if @isNewRecord
        sanitizeAttrs(@doc)
        coll.insert @doc, (err, result) ->
          cb(err, result)
      else
        cb(err)

    updateAttr: (attr, val, cb) ->
      @props[attr] = val
      addUpdatedStamp(@props)
      coll.update({ _id: @id },  { $set: @props }, { upsert: true }, cb)

    pushRefs: (refs, cb) ->
      coll.update({ _id: @id }, { $addToSet: { refs: { $each: refs } } }, (err, result) =>
        return cb(err) if err
        cb(null, @attrs())
      )

    update: (attrs, cb) ->
      sanitizeAttrs(attrs)
      # if not attrs.tzOffset or _.isEqual(attrs.homeRef, @doc.homeRef)
      # set the timezone
      coll.update({ _id: @id },  { $set: attrs }, { upsert: true }, cb)

    sendResponse: (cb) ->
      Profiles.findById(@id, (err, doc) ->
        cb(err, doc)
      )

    attrs: () ->
      @doc


  class Profiles
    @all: (cb) ->
      coll.find({})
        .toArray (err, docs) ->
          cb(err, docs)

    @findById: (id, cb) ->
      console.log(id)
      id = new ObjectID("#{id}")
      coll.findOne({ _id: id }, (err, doc) ->
        if err then return cb(err)
        cb(null, new Profile(doc))
      )

    @new: (params, cb) ->
      profile = new Profile(params)
      profile.saveNew(cb)

    constructor: (opts) ->
      return new Profile(opts)
  
  return Profiles
