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
  @option opt [Boolean, Array<String>] inheritStyle determines if styles should be inherited, instead of explicitly
    listed in every node.  `yes` (the default) will use `[property]: inherit;` whenever a property is the same as it's
    parent.  `no` will include every option in full.  Provide an array of properties (lower-case) that can be inherited.
    All other properties will be listed in full.
  @option opt [Array<String>] inheritSilent Optionally list CSS properties that can be inherited by default, and will be
    excluded from the listed styles, instead of using `[property]: inherit;`.  If `inheritStyle` is disabled,
    `inheritSilent` takes no effect.
    Defaults to a potentially safe list.  See [StackOverflow](http://stackoverflow.com/a/5612360/666727) for al
    attributes are considered inherited by the W3C (not guarenteed to be the behavior of every browser).
    Default: `font-family`, `font-size`, `font-style`, `font-variant`, `font-weight`, `line-height`, `letter-spacing`,
    `visibility`.
  @option opt [Integer] concurrency Define how many serializations can occur concurrently.  Defaults to `Infinity`.
  @option opt [Boolean] nonBlocking If `true`, adds a 0ms delay to serialization, to allow other actions on the stack to
    occur.  If `false`, Domnit might not give up control until it's finished.  Defaults to `true`.
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
      inheritStyle: yes
      inheritSilent: ["font-family", "font-size", "font-style", "font-variant", "font-weight", "line-height",
        "letter-spacing", "visibility"]
      concurrency: Infinity
      nonBlocking: yes

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
  @param [Boolean] root `true` if the element being serialized is the root element in the document.

  @example Serialize the entire document, using jQuery to select `<html>`.
    var domnit = new Domnit();
    domnit
      .serialize($("html")[0])
      .then(function(dom) {
        console.log(dom);
      });
  ###
  serialize: (el, root=yes) ->
    return "" unless @passFilter(el) and @passFilterHidden(el) and @passDisplayNone(el)
    customSerialize = "#{el.tagName.toLowerCase()}Serializer"
    Serializer = @[customSerialize] ? @elementSerializer
    Promise
      .all []
      .then =>
        Promise.delay(0) if @opt.nonBlocking
      .then =>
        Promise.map el.children, ((child) => @serialize child, no), {concurrency: @opt.concurrency}
      .then (children) =>
        element = new Serializer el, children, @opt, root
        element.toString()


module.exports = Domnit
