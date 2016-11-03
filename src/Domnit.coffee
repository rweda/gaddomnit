defaultsDeep = require "lodash.defaultsdeep"
Promise = require "bluebird"
ElementSerializer = require "./ElementSerializer"
ScriptSerializer = require "./ScriptSerializer"
LinkSerializer = require "./LinkSerializer"
StyleSerializer = require "./StyleSerializer"

###
Serializes the DOM into a standalone HTML file.
###
class Domnit

  ###
  @param [Object] opt options for customizing Domnit's behavior.
  @option opt [String] originalStyle an attribute to move `style` property to for all elements.
    Defaults to `data-originalStyle`.
  @option opt [String] originalSrc an attribute to move the `src` attribute for `script` elements.
    Defaults to `data-originalSrc`.
  @option opt [String] linkHref an attribute to move the `href` attribute for `link` elements.
    Defaults to `data-originalHref`.
  ###
  constructor: (@opt={}) ->
    defaultsDeep @opt,
      originalStyle: "data-originalStyle"
      originalSrc: "data-originalSrc"
      linkHref: "data-originalHref"

  @ElementSerializer = ElementSerializer

  elementSerializer: ElementSerializer

  scriptSerializer: ScriptSerializer

  linkSerializer: LinkSerializer

  styleSerializer: StyleSerializer

  ###
  Serialize an HTML tree into a string.
  @param [Element] el the element to serialize, including all it's children.
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
    customSerialize = "#{el.tagName.toLowerCase()}Serializer"
    Serializer = @[customSerialize] ? @elementSerializer
    children = []
    for child in el.children
      children.push @serialize child
    Promise
      .all children
      .then (children) =>
        element = new Serializer el, children, @opt
        element.toString()


module.exports = Domnit
