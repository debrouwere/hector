fs = require 'fs'
fs.path = require 'path'
utils = require '../utils'
_ = require 'underscore'

findLayout = (templateName, root) ->
        path = fs.path.join root, 'layouts', templateName
        pattern = path + '.*'
        templatePath = utils.template.find pattern

        (context, callback) ->
            utils.template.compile templatePath, context, callback

module.exports = (locals, callback) ->
    console.log 'being asked to render context for', locals
    
    layout = findLayout locals.hector.layout, locals.hector.root.app
    _.extend locals, {data: @router.data}

    layout locals, (err, output) =>
        console.log "✓ #{locals.hector.path}".grey
        @destination.add locals.hector.path, output
        callback err