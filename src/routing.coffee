fs = require 'fs'
fs.path = require 'path'
async = require 'async'
_ = require 'underscore'
colors = require 'colors'
espy = require 'espy'
weaponize = require 'weaponize'
utils = require './utils'
{Format} = require './format'


class Page
    constructor: (@name, @data, @relatedData, @route) ->
        @locals = @getLocals()
        layoutName = new Format(@locals.meta.layout).fill(@locals.meta)
        @layout = @locals.meta.layout = @findLayout layoutName
        @path = @route.route.fill @locals.meta

        # when a route specifies a directory (e.g. `pages/my-page/`)
        # write to index.html inside of that directory
        if @path[@path.length-1] is '/'
            @path += 'index.html'

    getLocals: ->
        context =
            # TODO
            globals: _.extend {}, @route.defaults
            filename: []
            file: @data.meta

        # routes that don't have any placeholders by definition
        # can't contain any context
        if @route.route.isTemplate
            context.filename = @route.context.match @data.meta.origin.filename

        meta = _.extend {}, (_.values context)...
        data = @relatedData
        content = @data.content
        if not meta.layout then meta.layout = @route.specification.layout

        {meta, data, content}

    findLayout: (templateName) ->
        path = fs.path.join @route.router.fileRoot, 'layouts', templateName
        pattern = path + '.*'
        utils.findLayout pattern

    render: (callback) ->
        @layout @locals, (err, output) =>
            console.log "✓ #{@path}".grey
            @route.destination.add @path, output
            callback err


class Route
    constructor: (@name, spec, @router) ->
        @specification = spec
        @defaults = _.extend {}, @router.defaults, spec.defaults
        @route = new Format spec.route, @defaults
        @layout = new Format spec.layout, @defaults
        @context = new Format spec.context, @defaults
        @root = @getBaseDir @context.raw

    # this looks a bit strange, but what it does is, provided with a path
    # like `posts/{year}/{month}-{day}-{title}`, figure out that we want
    # to start looking for context in `posts`.
    getBaseDir: (str) ->
        end = str.indexOf '{'
        format = str.slice 0, end
        format.split('/').slice(0, -1).join('/')

    load: (callback) ->
        espy.findFilesFor @router.fileRoot, @root, (files) =>
            espy.getContext files, (err, context) =>
                @data = context
                callback err, @data

    generate: (@destination, callback) ->
        console.log "Generating #{@name}".bold, "\t#{@context.raw} -> #{@route.raw}"

        # when dealing with a route like `posts/{permalink}`, render once 
        # for every context set, but when dealing with a route like `feed`, 
        # only generate once and pass all the context in one bundle
        if @route.isTemplate
            render = ([name, dataset], done) =>
                page = new Page name, dataset, @router.data, this
                page.render done

            async.forEach (_.pairs @data), render, (err) ->
                callback err
        else
            (new Page null, @data, @router.data, this).render callback
            

class Router
    constructor: (@routes, @defaults, @fileRoot) ->
        (@routes[name] = new Route name, spec, @) for name, spec of @routes

    load: (callback) ->
        # preload all data for all routes with `espy`
        # so we can make it available under `data.<route>`
        tasks = ([name, (_.bind route.load, route)] for name, route of @routes)
        async.parallel (_.object tasks), (err, @data) =>
            callback err

    generate: (callback) ->
        buffer = new weaponize.Buffer()

        generateRoute = (route, done) -> route.generate buffer, done

        routes = (_.values @routes)
        async.each routes, generateRoute, (errors) ->
            callback errors, buffer


exports.Format = Format
exports.Page = Page
exports.Route = Route
exports.Router = Router