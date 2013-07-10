fs = require 'fs'
fs.path = require 'path'
fs.glob = require 'glob'
tilt = require 'tilt'

exports.template = 
    find: (pattern) ->
        # figure out if there are any matches with extensions
        # for template languages we can deal with
        matches = fs.glob.sync pattern
        for match in matches
            file = new tilt.File path: match
            handler = tilt.findHandler file
            # it's not enough to have a handler available, 
            # the file we're dealing with should be a template language and 
            # not e.g. a CSS preprocessor
            if handler? and handler.mime.output is 'text/html'
                return match
        return no

    compile: (path, context, callback) ->
        file = new tilt.File {path}
        tilt.compile file, context, callback


exports.functional = 
    seed: ->
        data = arguments
        (callback) ->
            callback null, data...