context = require 'espy'
tilt = require 'tilt'
railgun = require 'railgun'
_ = require 'underscore'
routing = require './routing'


# DUMMY DATA

routes =
    posts:
        route:    "{year}/{month}/{day}/{title}"
        template: "{layout}"
        context:  "posts/{year}/{month}-{day}-{title}"
        defaults:
            language: "en"

file =
    filename: "posts/2012/03-27-hello-beautiful-world.textile"
    context:
        layout: 'quote'
        content: 'This is a quote from somebody.'

# turn a filename into context
format = new router.Format(routes.posts.context, routes.posts.defaults)
context = format.match file.filename
console.log _.extend {}, file.context, context

# generate a path
format = new router.Format(routes.posts.route)
template = format.toTemplate()
path = template context

console.log path
console.log format.fill context

bundle = new railgun.Bundle 'index.html', 'production'

# this looks a bit strange, but what it does is, provided with a path to context like 
# `posts/{year}/{month}-{day}-{title}`, figure out that we want to start looking in
# `posts`.
getBaseDir = (format) ->
    end = format.indexOf('{')
    format = format.slice 0, end
    format.split('/').slice(0, -1).join('/')

console.log getBaseDir "data/posts/{year}/{month}-{day}-{title}"

# Go through each route and find appropriate context (TODO)
for name, route of {} # routes
    # espy lacks some of the features we need, like giving
    # us the original filenames associated with context, 
    # going through subdirectories (not necessarily for context sets -- those should be optional), 
    # finding templates from a glob (`blogpost` whether it's `blogpost.jade` or `blogpost.haml` or whatever)
    # and lastly getting context from the filename itself (though I think it makes sense to have
    # that in `Format#match` in Hector)
    # -- anyhow, this is pseudocode

    espy.find getBaseDir route.context, (errors, context) ->
        for name, set of context
            templateName = new Format(route.template).fill(context)
            template = espy.findTemplate root, templateName
            path = new Format(route.route).fill(context)
            content = tilt.compile route.template
            compilerType: 'noop'
            bundle.push {path, content, compilerType}

#railgun.optimize bundle, ->
#    railgun.package bundle, dest, ->
#        console.log 'done'