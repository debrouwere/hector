_ = require 'underscore'

class exports.Format
    constructor: (@raw, @defaults = {}) ->
        # checks whether this is a fully-specified path
        # or rather a template with placeholders
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
        
        matchObj = regex.exec(str)
        return null unless matchObj

        matches = matchObj[1..]
        context = _.clone @defaults
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
    # TODO: throw an error if we can't fill every placeholder
    fill: (context) ->
        @toTemplate()(context)