/*
Gad Domnit v0.0.0
Copyright 2016 Redwood EDA.  See https://github.com/rweda/gaddomnit#readme for LICENSE.
*/
var Domnit = (function (bluebird) {
'use strict';

bluebird = 'default' in bluebird ? bluebird['default'] : bluebird;

/*
A base class for serializing elements.  Intended to be extendable.
 */
var ElementSerializer$1;
var bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

ElementSerializer$1 = (function() {

  /*
  @param [Element] el the element that will be serialized.
  @param [Array<String>] children the serialized children
  @param [Object] opt options to configure the action of gaddomnit.
   */
  function ElementSerializer(el, children, opt) {
    this.el = el;
    this.children = children;
    this.opt = opt;
    this.saveStyle = bind(this.saveStyle, this);
    this.originalElement = this.el;
    this.el = this.el.cloneNode(false);
  }


  /*
  Saves the `style` attribute under the name defined by `opt.originalStyle`.
   */

  ElementSerializer.prototype.saveStyle = function() {
    if (!this.el.hasAttribute("style")) {
      return;
    }
    return this.el.setAttribute(this.opt.originalStyle, this.el.getAttribute("style"));
  };


  /*
  Sets the `style` to the full computed value.
   */

  ElementSerializer.prototype.serializeStyle = function() {
    var j, len, prop, results, style;
    if (this.el.currentStyle) {
      return this.el.setAttribute("style", this.el.currentStyle);
    } else {
      style = getComputedStyle(this.el);
      results = [];
      for (j = 0, len = style.length; j < len; j++) {
        prop = style[j];
        results.push(this.el.style[prop] = style[prop]);
      }
      return results;
    }
  };


  /*
  Modifies `@el` with common modifications.  Intended to be extended by other classes.
   */

  ElementSerializer.prototype.update = function() {
    this.saveStyle();
    return this.serializeStyle();
  };


  /*
  Interweave stringified children with `textContent` of the current element.
  @return [Array<String>] all contents, both stringified children and text
   */

  ElementSerializer.prototype.interweaveText = function() {
    var child, fullText, i, interwoven, j, lastPos, len, next, pos, ref, ref1;
    fullText = this.originalElement.textContent;
    if (!fullText) {
      return this.children;
    }
    ref = [[], 0], interwoven = ref[0], lastPos = ref[1];
    ref1 = this.originalElement.children;
    for (i = j = 0, len = ref1.length; j < len; i = ++j) {
      child = ref1[i];
      next = child.textContent;
      if (!next) {
        continue;
      }
      pos = fullText.indexOf(next, lastPos);
      if (pos > 0) {
        interwoven.push(fullText.substring(lastPos, pos));
        lastPos = pos;
      }
      interwoven.push(this.children[i]);
      lastPos += next.length;
    }
    interwoven.push(fullText.substring(lastPos));
    return interwoven;
  };


  /*
  Serializes this element.
  @return {String} the serialized element
   */

  ElementSerializer.prototype.toString = function() {
    var attrs, name;
    this.update();
    name = this.el.tagName;
    attrs = [name];
    this.el.innerHTML = this.interweaveText().join("");
    return this.el.outerHTML;
  };

  return ElementSerializer;

})();

var ElementSerializer_1 = ElementSerializer$1;

var Domnit;
var ElementSerializer;
var Promise;

Promise = bluebird;

ElementSerializer = ElementSerializer_1;


/*
Serializes the DOM into a standalone HTML file.
 */

Domnit = (function() {

  /*
  @param [Object] opt options for customizing Domnit's behavior.
   */
  function Domnit(opt) {
    this.opt = opt;
  }

  Domnit.prototype.elementSerializer = ElementSerializer;


  /*
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
   */

  Domnit.prototype.serialize = function(el) {
    var Serializer, child, children, customSerialize, i, len, ref, ref1;
    customSerialize = el.tagName + "Serializer";
    Serializer = (ref = this[customSerialize]) != null ? ref : this.elementSerializer;
    children = [];
    ref1 = el.children;
    for (i = 0, len = ref1.length; i < len; i++) {
      child = ref1[i];
      children.push(this.serialize(child));
    }
    return Promise.all(children).then((function(_this) {
      return function(children) {
        var element;
        element = new Serializer(el, children, _this.opt);
        return element.toString();
      };
    })(this));
  };

  return Domnit;

})();

var Domnit_1 = Domnit;

return Domnit_1;

}(P));
