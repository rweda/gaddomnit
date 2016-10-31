_ = require "underscore"
Promise = require "bluebird"
{exec} = require "child-process-promise"

rollup = require "rollup"
commonjs = require "rollup-plugin-commonjs"
coffee = require "rollup-plugin-coffee-script"
nodeResolve = require "rollup-plugin-node-resolve"
uglify = require "rollup-plugin-uglify"

option '', '--no-browser', 'Disable targeting the browser (and AMD)'
option '', '--no-node', "Disable targeting Node.js (and CommonJS)"
option '', '--no-bare', "Disable targeting bare JS (iife)"
option '', '--no-universal', "Disable a universal target (UMD)"
option '', '--no-min', "Disable minification"
option '', '--no-partial', "Disable 'partial' builds, which don't include major libraries"

task 'build', "Build Domnit", (opts) ->
  build opts

_rolled = {}
roller = (opts={}) ->
  _.defaults opts, {minify: yes, file: 'src/Domnit.coffee', skip: [], paths: {}}
  opts.skip.push mod for path, mod of opts.paths
  return rolled if rolled = _rolled[JSON.stringify opts]
  plugins = [
    coffee()
    nodeResolve
      main: yes
      skip: opts.skip
      extensions: ['.js', '.coffee']
    commonjs
      extensions: ['.js', '.coffee']
      namedExports: opts.paths
  ]
  plugins.push uglify() if opts.minify
  _rolled[JSON.stringify opts] = rollup.rollup
    entry: opts.file
    plugins: plugins

banner = """
  /*
  Gad Domnit v#{require("./package.json").version}
  Copyright 2016 Redwood EDA.  See #{require("./package.json").homepage} for LICENSE.
  */
"""

# Defines common libraries that should be skipped for partial builds
skip = ["bluebird"]

# For UMD/IIFE bundles, defines packages global variables come from.
globals =
  bluebird: "P"

###
Define specific JavaScript files to include for modules.
For instance, `{"node_modules/lodash/dist/lodash.fp.js": "lodash"}` would ensure that `lodash.fp.js` is the file chosen
for the `lodash` module.
###
browserPaths = {}

###
Runs a build format.
@param [Object] opts the Cake options specified
@param [String] format the output format.  One of `amd`, `cjs`, `iife`, `umd`
@param [String] ext the file extension to add to the output file, such as `-browser`.
@param [String] moduleName the global variable to export {Domnit} as
###
buildFormat = (opts, format, ext, paths, moduleName=null) ->
  tasks = []
  tasks.push roller({paths, minify: no}).then (bundle) ->
    bundle.write {moduleName, globals, banner, format, dest: "public/domnit#{ext}.js"}
  unless opts["no-partial"]
    tasks.push roller({paths, minify: no, skip}).then (bundle) ->
      bundle.write {moduleName, globals, banner, format, dest: "public/domnit#{ext}.nolib.js"}
  return Promise.all tasks if opts["no-min"]
  tasks.push roller({paths}).then (bundle) ->
    bundle.write {moduleName, globals, banner, format, dest: "public/domnit#{ext}.min.js"}
  unless opts["no-partial"]
    tasks.push roller({paths, skip}).then (bundle) ->
      bundle.write {moduleName, globals, banner, format, dest: "public/domnit#{ext}.nolib.min.js"}

build = (opts) ->
  tasks = []
  unless opts["no-browser"]
    tasks.push buildFormat opts, 'amd', '-browser', browserPaths
  unless opts["no-node"]
    tasks.push buildFormat opts, 'cjs', '-node'
  unless opts["no-bare"]
    tasks.push buildFormat opts, 'iife', '', null, 'Domnit'
  unless opts["no-universal"]
    tasks.push buildFormat opts, 'umd', '-universal', browserPaths, 'Domnit'
  Promise
    .all tasks
    .then ->
      console.log "Compiled successfully."
    .catch (err) ->
      console.log "Error while compiling: #{err}"
