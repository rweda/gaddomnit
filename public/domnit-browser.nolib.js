/*
Gad Domnit v0.0.0
Copyright 2016 Redwood EDA.  See https://github.com/rweda/gaddomnit#readme for LICENSE.
*/
define(['bluebird'], function (bluebird) { 'use strict';

bluebird = 'default' in bluebird ? bluebird['default'] : bluebird;

var Domnit;
var Promise;

Promise = bluebird;


/*
Serializes the DOM into a standalone HTML file.
 */

Domnit = (function() {
  function Domnit() {}


  /*
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
   */

  Domnit.prototype.serialize = function(el) {};

  return Domnit;

})();

var Domnit_1 = Domnit;

return Domnit_1;

});
