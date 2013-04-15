context = require 'espy'
tilt = require 'tilt'
weaponize = require 'weaponize'
_ = require 'underscore'
fs = require 'fs'
fs.path = require 'path'
yaml = require 'js-yaml'
colors = require 'colors'
routing = exports.routing = require './routing'

exports.build = (paths..., routes) ->
    unless routes.length then routes = 'routes.yml'

    cwd = process.cwd()

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

    source = fs.path.join cwd, source
    destination = fs.path.join cwd, destination
    routes = fs.path.join source, routes

    settings = require routes
    router = new routing.Router settings.routes, settings.defaults, source
    
    router.load (err) ->
        if err
            console.log "- could not load data".red
            console.log err.message
            return

        router.generate (err, buffer) ->
            if err
                console.log "- could not process #{err.path}".red
                console.log err.message
            else
                weaponize.package buffer, './build'