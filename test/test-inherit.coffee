chai = require "chai"
should = chai.should()

Promise = require "bluebird"
fs = require "fs"
jsdom = Promise.promisifyAll require "jsdom"
virtualConsole = jsdom.createVirtualConsole().sendTo(console)

html = """
<body>
  <style>
    body {
      font-size: 10px;
      font-family: sans-serif;
    }
  </style>
  <div></div>
</body>
"""

init = (opts) ->
  dom = jsdom
    .envAsync html, ["#{__dirname}/../public/domnit.js"],
      virtualConsole: virtualConsole
      features:
        FetchExternalResources: no
    .then (window) ->
      new window.Domnit(opts).serialize window.document.body

describe "Serialization without Inheritance", ->
  dom = init {inheritStyle: no}

  it "should defines each property for the body", ->
    dom.then (s) ->
      body = s.match(/body style="([^\"]+)"/)[1]
      body.should.equal "font-size: 10px; font-family: sans-serif;"

  ###
  jsdom doesn't support CSS inheritance?
  ###
  it.skip "should define each property for the div", ->
    dom.then (s) ->
      div = s.match(/div style="([^\"]+)"/)[1]
      div.should.equal "font-size: 10px; font-family: sans-serif;"
