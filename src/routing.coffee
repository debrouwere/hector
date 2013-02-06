context = require 'espy'
tilt = require 'tilt'
railgun = require 'railgun'
_ = require 'underscore'
fs = require 'fs'
fs.path = require 'path'
fs.glob = require 'glob'
async = require 'async'

class exports.Format
    constructor: (@raw, @defaults = {}) ->
        # is this a fully-specified path or a template with placeholders?
        if (@raw.indexOf '{') > -1
            @isTemplate = yes
        else
            @isTemplate = no

    # analog to matching a regular expression against a string
    match: (str) ->
        keys = @raw.match /\{([^\}]+)\}/g
        keys = keys.map (match) ->
            match.slice 1, -1
        keys.push 'extension'

        regex = @raw.replace /\{([^\}]+)\}/g, '(.+?)'
        regex = new RegExp "#{regex}\.([^.]+)$"
        matches = regex.exec(str)[1..]
        context = @defaults
        for key in keys
            context[key] = matches.shift()

        context

    toTemplate: ->
        (context) =>
            str = @raw
            for key, value of context
                str = str.replace "{#{key}}", value, 'g'
            str
    
    # fill the placeholders in our formatted string with 
    # the context variables
    fill: (context) ->
        @toTemplate()(context)

class exports.Route
    constructor: (spec, @router) ->
        @defaults = _.extend {}, @router.defaults, spec.defaults
        @route = new exports.Format spec.route, @defaults
        @layout = new exports.Format spec.layout, @defaults
        @context = new exports.Format spec.context, @defaults
        @root = @getBaseDir @context.raw

    # this looks a bit strange, but what it does is, provided with a path to context like 
    # `posts/{year}/{month}-{day}-{title}`, figure out that we want to start looking in
    # `posts`.
    getBaseDir: (str) ->
        end = str.indexOf('{')
        format = str.slice 0, end
        format.split('/').slice(0, -1).join('/')

    getData: (callback) ->
        # TODO: should really be (errors, context) =>
        context.findFilesFor @router.fileRoot, @root, (files) ->
            context.getContext files, (errors, context) ->
                callback context

    findLayout: (templateName) ->
        path = fs.path.join @router.fileRoot, 'layouts', templateName
        pattern = path + '.*'
        # we need to glob for this basepath, and among the options
        # (if any) we need to figure out if there are any with extensions
        # for template languages we can deal with
        matches = fs.glob.sync pattern
        for match in matches
            file = new tilt.File path: match
            handler = tilt.findHandler file
            # it's not enough to have a handler available, 
            # the file we're dealing with should be a template language and 
            # not e.g. a CSS preprocessor
            if handler? and handler.mime.output is 'text/html'
                return (context, callback) ->
                    file.load ->
                        handler.compiler file, context, callback

    generate: (bundle, callback) ->
        # TODO
        contextFromGlobals = _.extend {}, @defaults

        gen = (item, done) =>
            [name, set] = item

            relpath = set.meta.origin.filename.replace @router.fileRoot + '/', ''
            contextFromFilename = @context.match set.meta.origin.filename
            contextFromFile = set.meta

            locals = 
                meta: _.extend {}, contextFromGlobals, contextFromFilename, contextFromFile
                body: set.body

            #data[name] = locals

            # locals.meta.layout can be variable, so we want to run
            # it through a formatter first
            layoutName = new exports.Format(locals.meta.layout).fill(locals.meta)
            layout = @findLayout layoutName
            path = @route.fill(locals.meta) + '/index.html'
            
            # TESTING
            # abspath here is sort of silly, since the bundle will cut it right 
            # off again -- but we can worry about the fine details of the interop
            # later
            abspath = fs.path.join bundle.root, path

            layout locals, (err, output) ->
                bundle.push abspath, {content: output, compilerType: 'noop'}
                done err

        @getData (data) =>
            if @route.isTemplate
                # render once for every context set
                async.forEach (_.pairs data), gen, (err) ->
                    callback err, bundle
            else
                # render once
                'todo'

class exports.Router
    constructor: (@routes, @defaults, @fileRoot) ->
        (@routes[name] = new exports.Route spec, @) for name, spec of @routes

    generate: (callback) ->
        bundle = new railgun.Bundle @fileRoot + 'index'
        console.log 'root', bundle.root
        @routes.posts.generate bundle, callback