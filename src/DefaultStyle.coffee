Promise = require "bluebird"

###
Determines the default browser style for elements.
See [CSSStyleDeclaration](https://developer.mozilla.org/en-US/docs/Web/API/CSSStyleDeclaration) for the return type.
###
class DefaultStyle

  ###
  @property [Object<String, Promise<CSSStyleDeclaration>>] Keep a copy of each element's style to produce a faster
  lookup.
  ###
  @stored = {}

  ###
  Fetch the default browser style for the given element, using a cache to speed up multiple requests.
  @param [String] tagName the tagName of an element to lookup
  @return [Promise<CSStyleDeclaration>] resolves to the default styles for the element selected
  ###
  @get = (tagName) ->
    return @stored[tagName] if @stored[tagName]
    @stored = @getNoCache tagName

  ###
  Fetch the default browser style for the given element, without any cache
  @param [String] tagName the tagName of an element to lookup
  @return [Promise<CSStyleDeclaration>] resolves to the default styles for the element selected
  ###
  @getNoCache = (tagName) ->
    iframe = document.createElement "iframe"
    document.body.appendChild iframe
    frameDocument = iframe.contentDocument || iframe.contentWindow.document
    element = frameDocument.createElement tagName
    frameDocument.body.appendChild element
    style = null
    Promise
      .delay 0
      .then ->
        style = {}
        computed = element.ownerDocument.defaultView.getComputedStyle element
        for prop, i in computed
          style[i] = prop
          style[prop] = computed[prop]
        style.cssText = computed.cssText
        Promise.delay 0
      .then ->
        document.body.removeChild iframe
        style

module.exports = DefaultStyle
