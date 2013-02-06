context = require 'espy'
tilt = require 'tilt'
railgun = require 'railgun'
_ = require 'underscore'
fs = require 'fs'
fs.path = require 'path'
yaml = require 'js-yaml'
routing = require './routing'

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
    #console.log router.routes
    router.generate (err, bundle) ->
        console.log bundle
        railgun.package bundle, destination