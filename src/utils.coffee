fs = require 'fs'
fs.path = require 'path'
fs.glob = require 'glob'
tilt = require 'tilt'


exports.findLayout = (pattern) ->
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
            return (context, callback) ->
                file.load ->
                    handler.compiler file, context, callback
    return no