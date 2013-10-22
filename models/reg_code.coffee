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
  code ||= ""
  RegCode.findOne { code: code.toLowerCase() }, rest...


RegCode = mongoose.model 'RegCode', RegCodeSchema
