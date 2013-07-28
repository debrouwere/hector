context = require 'espy'
tilt = require 'tilt'
weaponize = require 'weaponize'
_ = require 'underscore'
fs = require 'fs'
fs.path = require 'path'
yaml = require 'js-yaml'
colors = require 'colors'
async = require 'async'
express = require 'express'
routing = exports.routing = require './routing'


exports._build = (paths..., routes, callback=->) ->
    unless routes.length then routes = 'routes.yml'

    switch paths.length
        when 2
            [source, destination] = paths
        when 1
            source = paths[0]
            destination = 'public'
        when 0
            source = ''
            destination = 'public'
        else
            throw new Error 'Wrong arguments'

    cwd = process.cwd()
    source = fs.path.join cwd, source
    destination = fs.path.join cwd, destination
    routesPath = fs.path.join source, routes

    routes = require routesPath
    routes.settings ?= {}
    router = new routing.Router routes, source
    
    load = (done) -> router.load done
    generate = (data, done) -> router.generate done
    packageBuffer = (buffer, done) -> weaponize.package buffer, './build', done

    async.waterfall [load, generate, packageBuffer], (err) ->
        console.log 'built / waterfall'

        # TODO: vary user-facing error message
        # based on the async error
        if err
            console.log "- could not load data".red
            console.log err.message
    
        if err
            console.log "- could not process #{err.path}".red
            console.log err.message

        callback err


exports._serve = ->
    exports._build arguments..., (err) ->
        console.log 'built!'
        app = express()
        app.use express.static './build'
        app.listen 3400
        console.log 'Listening on 3400'


# testing
exports.build = ->
    exports._serve arguments...