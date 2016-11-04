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
  @option opt [Boolean] useBrowserStyle if `true`, filters out `style` attributes that are the default for the element.
    Produces a much smaller output, but takes longer to lookup each style, and the output will slightly differ if
    rendered on different browsers.
    Defaults to `true`.
  @option opt [Object] style Control if tags are skipped for styling.  Set `{"tagname": false}` to skip evaluating the
    tag to include a `style` attribute.  By default, `head`, `title`, `link`, `meta`, `style`, and `script` tags are
    ignored.  Set the entire object to `false` to disable all checking.
  @option opt [Function] filter Called with each element.  Return `true` to include the element in the output, otherwise
    it and all decendents are excluded from the output.
  @option opt [Boolean] filterHidden if `true`, filters out elements that have `visibility: hidden;`, along with their
    children.  Defaults to `false`.
  @option opt [Boolean] filterDisplayNone if `true`, filters out elements that have `display: none;`, along with their
    children.  Defaults to `false`.
  ###
  constructor: (@opt={}) ->
    defaultsDeep @opt,
      originalStyle: "data-originalStyle"
      originalSrc: "data-originalSrc"
      linkHref: "data-originalHref"
      useBrowserStyle: yes
      style:
        head: no
        title: no
        link: no
        meta: no
        style: no
        script: no
      filter: null
      filterHidden: no
      filterDisplayNone: no

  @ElementSerializer = ElementSerializer

  elementSerializer: ElementSerializer

  scriptSerializer: ScriptSerializer

  linkSerializer: LinkSerializer

  styleSerializer: StyleSerializer

  ###
  Determines if the element matches the filter, and should be included in the document
  @param [Element] the element to test
  @return {Boolean} `true` if the element passes the filter
  ###
  passFilter: (el) ->
    not @opt.filter or @opt.filter(el)

  ###
  Determines if the element doesn't match a filter against elements with `visibility: hidden;` and should be included in
  the document.
  @param [Element] the element to test
  @return {Boolean} `true` if the element passes the filter
  ###
  passFilterHidden: (el) ->
    not @opt.filterHidden or getComputedStyle(el).visibility isnt "hidden"

  ###
  Determines if the element doesn't match a filter against elements with `display: none;` and should be included in the
  document.
  @param [Element] the element to test
  @return {Boolean} `true` if the element passes the filter
  ###
  passDisplayNone: (el) ->
    not @opt.filterDisplayNone or getComputedStyle(el).display isnt "none"

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
    return "" unless @passFilter(el) and @passFilterHidden(el) and @passDisplayNone(el)
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
