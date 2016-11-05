DefaultStyle = require "./DefaultStyle"
Promise = require "bluebird"

###
A base class for serializing elements.  Intended to be extendable.
###
class ElementSerializer

  ###
  @param [Element] el the element that will be serialized.
  @param [Array<String>] children the serialized children
  @param [Object] opt options to configure the action of gaddomnit.
  @param [Boolean] isRoot `true` if this is the root element in the document.
  ###
  constructor: (@el, @children, @opt, @isRoot) ->
    @originalElement = @el
    @el = @el.cloneNode false

  ###
  Saves the `style` attribute under the name defined by `opt.originalStyle`.
  ###
  saveStyle: =>
    return unless @el.hasAttribute "style"
    @el.setAttribute @opt.originalStyle, @el.getAttribute("style")

  ###
  Create a function that determines if the element's attribute is the same as the default attribute.
  @return {Promise<Function>} `Boolean fn(CSSStyleDeclaration style, String prop)` `false` if the element shouldn't
    inherit the default style.  `true` if the property can be omitted.
  ###
  defaultStyleFilter: ->
    return Promise.resolve(-> no) unless @opt.useBrowserStyle
    DefaultStyle
      .get @el.tagName
      .then (def) =>
        Promise.resolve (style, prop) -> style[prop] is def[prop]

  ###
  Create a function that determines if the element's attribute should be inherited from it's parent.
  @return {Function} `Boolean,String fn(CSSStyleDeclaration style, String prop)` `false` if the element shouldn't
    inherit it's parent's style.  `true` if the style should be inherited explicitly.  `"silent"` if the attribute
    should inherit it's parent without any style.
  ###
  inheritFilter: ->
    return (-> no) unless @opt.inheritStyle and not @isRoot
    parent = getComputedStyle @originalElement.parentElement
    (style, prop) =>
      return no unless @opt.inheritStyle is yes or prop in @opt.inheritStyle
      return no unless style[prop] is parent[prop]
      return "silent" if @opt.inheritSilent and prop in @opt.inheritSilent
      yes

  ###
  Sets the `style` to the full computed value.
  ###
  serializeStyle: ->
    if @opt.style?[@el.tagName.toLowerCase()] is no
      @el.removeAttribute "style"
      return Promise.resolve()
    if @el.currentStyle
      @el.setAttribute "style", @originalElement.currentStyle
    else if @opt.useBrowserStyle or @opt.inheritStyle
      style = getComputedStyle @originalElement
      inherit = @inheritFilter()
      @defaultStyleFilter()
        .then (def) =>
          for prop in style
            i = inherit style, prop
            if def(style, prop) or i is "silent"
              continue
            @el.style[prop] = if i then "inherit" else style[prop]
    else
      @el.style.cssText = getComputedStyle(@originalElement).cssText

  ###
  Modifies `@el` with common modifications.  Intended to be extended by other classes.
  @return {Promise} resolves when done updating
  ###
  update: ->
    @saveStyle()
    @serializeStyle()

  ###
  Interweave stringified children with `textContent` of the current element.
  @return [Array<String>] all contents, both stringified children and text
  ###
  interweaveText: ->
    fullText = @originalElement.textContent
    return @children unless fullText
    [interwoven, lastPos] = [[], 0]
    for child, i in @originalElement.children
      next = child.textContent
      unless next
        interwoven.push @children[i]
        continue
      pos = fullText.indexOf next, lastPos
      if pos > 0
        interwoven.push fullText.substring lastPos, pos
        lastPos = pos
      interwoven.push @children[i]
      lastPos += next.length
    interwoven.push fullText.substring lastPos
    interwoven

  ###
  Serializes this element.
  @return {String} the serialized element
  ###
  toString: ->
    Promise
      .resolve @update()
      .then =>
        name = @el.tagName
        attrs = [name]
        @el.innerHTML = @interweaveText().join("")
        @el.outerHTML

module.exports = ElementSerializer
