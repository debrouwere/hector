_ = require 'underscore'
routing = require '../src/routing'


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