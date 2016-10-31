Promise = require "bluebird"

###
Serializes the DOM into a standalone HTML file.
###
class Domnit

  ###
  Serialize an HTML tree into a string.
  @param [HTMLElement] el the element to serialize, including all it's children.
  @return [Promise<String>] the serialized DOM

  @example Serialize the entire document, using jQuery to select `<html>`.
    var domnit = new Domnit();
    domnit
      .serialize($("html")[0])
      .then(function(dom) {
        console.log(dom);
      });
  ###
  serialize: (el) ->


module.exports = Domnit
