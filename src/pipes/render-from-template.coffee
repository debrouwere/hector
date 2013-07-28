fs = require 'fs'
fs.path = require 'path'
utils = require '../utils'
_ = require 'underscore'

findLayout = (templateName, root) ->
        path = fs.path.join root, 'layouts', templateName
        pattern = path + '.*'
        templatePath = utils.template.find pattern

        return null unless templatePath

        (context, callback) ->
            utils.template.compile templatePath, context, callback

module.exports = (locals, callback) ->
    _.extend locals, {data: @router.data}
    layout = findLayout locals.hector.layout, locals.hector.root.app
    
    if not layout
        return console.log "✗ Couldn't find a layout named #{locals.hector.layout}".red

    layout locals, (err, output) =>
        console.log "✓ #{locals.hector.path}".grey
        @destination.add locals.hector.path, output
        callback err