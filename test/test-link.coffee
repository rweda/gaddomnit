chai = require "chai"
should = chai.should()

Promise = require "bluebird"
fs = require "fs"
jsdom = Promise.promisifyAll require "jsdom"
virtualConsole = jsdom.createVirtualConsole().sendTo(console)

link = """
<body>
  <link id="url" type="text/css" href="http://rweda.com/" />
</body>
"""

domnit = (window) ->
  new window.Domnit({originalStyle: 'data-originalStyle'}).serialize window.document.body

describe "<link> Serialization", ->
  dom = jsdom
    .envAsync link, ["#{__dirname}/../public/domnit.js"],
      virtualConsole: virtualConsole
      features:
        FetchExternalResources: no #["link"]
    .then domnit

  it "should move href attribute", ->
    dom.then (serialized) ->
      serialized.should.not.include " href="
      serialized.should.include "data-originalhref=\"http://rweda.com/\""
