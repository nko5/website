mongoose = require 'mongoose'

RegCodeSchema = module.exports = new mongoose.Schema
  code:
    type: String
    required: true
  limit:
    type: Number
    required: true

RegCodeSchema.plugin require('../lib/use-timestamps')
RegCodeSchema.index code: -1

# class methods

RegCodeSchema.static 'findByCode', (code, rest...) ->
  RegCode.findOne { code: code }, rest...

RegCodeSchema.static 'canRegister', (code, next) ->
  return next null, false, 0 unless code
  return next null, false, 0 if mongoose.app.disabled('registration')  
  
  RegCode.findByCode code, (err, regCode) =>
    return next err if err
    return next null, false unless regCode
    
    mongoose.model("Team").count {regCode: code}, (err, count) ->
      return next err if err
      
      newLimit = regCode.limit + 1
      next null, count < newLimit, newLimit - count

RegCodeSchema.static 'current', (code, next) ->
  
  RegCode.findByCode code, (err, regCode) ->
    return next err if err
    
    limit = regCode.limit
    mongoose.model("Team").count {regCode: code}, (err, count) ->
      return next err if err
      next null, limit - count


RegCode = mongoose.model 'RegCode', RegCodeSchema
