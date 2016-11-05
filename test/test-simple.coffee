chai = require "chai"
should = chai.should()

Promise = require "bluebird"
fs = require "fs"
jsdom = Promise.promisifyAll require "jsdom"
virtualConsole = jsdom.createVirtualConsole().sendTo(console)

simple = """
<html>
  <head>
    <title>Gad Domnit!</title>
  </head>
  <body>
    <h1>Hello World</h1>
  </body>
</html>
"""

inline = """
<html>
  <head>
    <title>Gad Domnit!</title>
    <style type="text/css">
      div {
        font-size: 12px !important;
        color: red;
        height: 1em;
      }
      .specific {
        height: 2em;
      }
    </style>
  </head>
  <body>
    <div class="specific" style="font-size: 10px;">Hello World</div>
  </body>
</html>
"""

domnit = (window) ->
  opts =
    originalStyle: 'data-originalStyle'
    useBrowserStyle: no
    inheritStyle: no
  new window.Domnit(opts).serialize window.document.body

describe "Basic HTML Serialization", ->

  it "includes body and h1 elements", ->
    jsdom
      .envAsync simple, ["#{__dirname}/../public/domnit.js"], {virtualConsole}
      .then domnit
      .then (serialized) ->
        serialized.should.match /<body style="[^"]+">/
        serialized.should.match /<h1 style="[^"]+">Hello World<\/h1>/

describe "Style Serialization", ->
  dom = jsdom
    .envAsync inline, ["#{__dirname}/../public/domnit.js"], {virtualConsole}
    .then domnit

  it "applies CSS attributes", ->
    dom.then (serialized) ->
      css = serialized.match(/<div class="specific" style="([^"]+)"/)[1]
      css.should.match /color: red;/
      ###
      TODO: JSDOM doesn't support !important?
      # css.should.match /font-size: 12px;/
      ###
      css.should.match /display: block;/

  it "saves old styles", ->
    dom.then (serialized) ->
      serialized.should.include "data-originalstyle=\"font-size: 10px;\""

  it "uses CSS hierarchy", ->
    dom.then (serialized) ->
      css = serialized.match(/<div class="specific" style="([^"]+)"/)[1]
      css.should.match /height: 2em;/
