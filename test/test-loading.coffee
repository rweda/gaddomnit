chai = require "chai"
should = chai.should()

###
Test that Domnit can be loaded via RequireJS and CommonJS.
###

describe "Domnit Loading", ->

  for format in ["-universal", "-browser"]
    do (format) ->
      describe "RequireJS loading domnit#{format}.js", ->
        requirejs = require "requirejs"
        Domnit = null

        it "should load", ->
          Domnit = requirejs "#{__dirname}/../public/domnit#{format}.js"

        it "should have Domnit#serialize", ->
          domnit = new Domnit()
          domnit.serialize.should.be.a "function"

        it "should have default options", ->
          domnit = new Domnit()
          should.exist domnit.opt
          domnit.opt.should.be.a "object"
          should.exist domnit.opt.originalStyle
          domnit.opt.originalStyle.should.equal "data-originalStyle"

  for format in ["-universal", "-node"]
    do (format) ->
      describe "Node loading domnit#{format}.js", ->
        Domnit = null

        it "should load", ->
          Domnit = require "#{__dirname}/../public/domnit#{format}.js"

        it "should have Domnit#serialize", ->
          domnit = new Domnit()
          domnit.serialize.should.be.a "function"

        it "should have default options", ->
          domnit = new Domnit()
          should.exist domnit.opt
          domnit.opt.should.be.a "object"
          should.exist domnit.opt.originalStyle
          domnit.opt.originalStyle.should.equal "data-originalStyle"
