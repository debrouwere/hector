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