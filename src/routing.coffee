fs = require 'fs'
fs.path = require 'path'
async = require 'async'
_ = require 'underscore'
colors = require 'colors'
espy = require 'espy'
weaponize = require 'weaponize'
utils = require './utils'
{Format} = require './format'

requireLocal = (name, root) ->
    name = name
        .replace('.js', '')
        .replace('.coffee', '')

    if name[0] is '/'
        localPath = name
    else if name[0] is '.'
        localPath = fs.path.join root, name
    else
        path = fs.path.join 'pipes', name
        localPath = './' + path
    require localPath

class Route
    constructor: (@name, spec, @router) ->
        load = (name) =>
            pipe = requireLocal name, @router.root.app
            _.bind pipe, this            

        @specification = spec
        @defaults = _.extend {}, @router.defaults, spec.defaults
        @pipes = (spec.pipes or ['gather-context']).map load
        @output = (spec.output or ['add-helpers', 'render-from-template']).map load

        # REFACTOR: rename to `paths`, an array w/ fallbacks
        # (and turn into array if we get a plain string from spec.route)
        # (perhaps change naming to spec.path also)
        if 'route' of spec
            @route = new Format spec.route, @defaults
        if 'layout' of spec
            @layout = new Format spec.layout, @defaults
        if 'context' of spec
            @context = new Format spec.context, @defaults
            @root = @getBaseDir @context.raw

    # this looks a bit strange, but what it does is, provided with a path
    # like `posts/{year}/{month}-{day}-{title}`, figure out that we want
    # to start looking for context in `posts`.
    getBaseDir: (str) ->
        end = str.indexOf '{'
        if end is -1
            str
        else
            format = str.slice 0, end
            format.split('/').slice(0, -1).join('/')

    load: (callback) ->
        save = (err, @data) => callback err, @data
        async.waterfall @pipes, save

    generate: (@destination, callback) ->
        context = @context?.raw or ''
        context += ' '
        console.log "Generating #{@name}".bold, "\t#{context}-> #{@route.raw}"

        process = (set, done) =>
            seed = utils.functional.seed set
            async.waterfall [seed, @output...], done

        async.each @data, process, callback

    # UNTESTED / DEPENDS ON OTHER REFACTORS / HERE AS INSPIRATION / A STUB
    fill: (context) ->
        for path in @path
            try
                return path.fill context
            catch error
                if error instanceof ReferenceError
                    continue
                else
                    throw error
            return null

class Router
    constructor: (@options, source) ->
        # we normally expect content, layouts and such to be in the same
        # location as the routes.yml, but these defaults can be overridden
        # (and in fact it's recommended to do so)
        absolutize = (path) -> fs.path.resolve source, path        
        @root = 
            app: absolutize (@options.settings.root?.app or source)
            context: absolutize (@options.settings.root?.context or source)
            assets: absolutize (@options.settings.root?.assets or source)

        @routes = {}
        (@routes[name] = new Route name, spec, @) for name, spec of @options.routes

    load: (callback) ->
        # preload all data for all routes with `espy`
        # so we can make it available under `data.<route>`
        tasks = ([name, (_.bind route.load, route)] for name, route of @routes)
        save = (err, @data) => callback err, @data
        async.parallel (_.object tasks), save

    generate: (callback) ->
        buffer = new weaponize.Buffer()

        generateRoute = (route, done) ->
            route.generate buffer, done

        routes = (_.values @routes)
        async.each routes, generateRoute, (errors) ->
            callback errors, buffer


exports.Format = Format
exports.Route = Route
exports.Router = Router