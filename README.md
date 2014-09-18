Hector is an MIT-licensed static site generator. It takes your content and spits it out as static HTML. Perfect for blogs, but built to handle more complex sites especially. Hector has routes and views and controllers and it treats the file system like a database – all the things you're used to from dynamic MVC frameworks like Rails or Django. If you can think it up, Hector can generate it.

Static sites are fast, secure, don't crash under load, are easy to deploy and cheap to host, and you can still add in any dynamic bits you might need through JavaScript or server-side includes.

## Status

Hector is not stable software. It is not actively maintained anymore. Take a look at the [gather](https://github.com/stdbrouw/gather) and [render](https://github.com/stdbrouw/render) command-line interfaces and node.js modules. Gather and render are a newer take on the philosophy behind Hector: static site generation as a bunch of data transformations rather than something you do with specialized blogging software.

## Features

* Support for many different templating and markup languages.
* Use any markup language as well as YAML, CSV and JSON content with whatever directory layout you like. See [Tilt.js] for a list of currently supported formats.
* Preprocess anything that compiles into CSS or JavaScript (like [LESS](http://lesscss.org) or [CoffeeScript](http://coffeescript.org)) and automatically optimize scripts, styles and HTML.
* An relatively straightforward switch from Jekyll.
* A full-featured plugin system. Hook into any part of Hector's data gathering and rendering process.

## Get started

### Directory layout

Hector can support any directory layout, but we find the tidiest setups are those that separate content from code. Here's an example of what that could look like: 

    platform/
        assets/
            scripts/
            stylesheets/
        layouts/
        routes.yml
    content/
        posts/
        pages/

### Routing

Here's what your routes.yml might look like, with a file structure like the above: 

    content: '../content'

    routes:
        posts:
            route: '{year}/{month}/{day}/{permalink}'
            layout: 'post'
            context: 'posts/{year}-{month}-{day}-{permalink}'
        pages:
            route: '{permalink}'
            layout: '{layout}'
            context: 'pages/{permalink}'
            defaults:
                layout: 'page'
        feed:
            route: 'feed.xml'
            layout: 'feed'
            context: 'posts/{year}/{month}-{day}-{permalink}'

Routes shouldn't include file extensions. Hector will find Markdown and Textile files as well as JSON, YAML and CSV.

### Content

You can pick whatever naming structure you like for your content. The one we specified for blogposts in our routes above is `posts/{year}/{month}-{day}-{permalink}` so you'd create files like `posts/2013-01-01-happy-new-year.md`.

That file could look like: 

    # Happy new year!

    A happy new year to **everyone**!

But it's often useful to specify some metadata too, which we call YAML front matter, because it'll be in [YAML]() and it comes before the main content.

    ---
    language: en
    title: Happy new year!
    author: Stijn Debrouwere
    categories:
        - wishes
        - personal
    ---

    A dummy blogpost.

Your front matter can contain anything you want it to. YAML front matter will be picked up as additional context that'll be handed to your template. There are no required fields, though obviously if your template requires, for example, a `title` variable, it won't be able to get rendered unless you specify that variable somewhere.

### Templates

You can pick any template language you like. Our recommendation would be [Jade](http://jade-lang.com), which is very similar to HAML or Slim if you've ever used those. A simple blog template might look like this: 

    html
        head
            title= meta.title
        body
            h1= meta.title
            != content

### Static assets

- regular
- preprocessors
- cdn links

### Building

### Version control

We recommend keeping both your content and your site's templates and other code under version control, for example with Git. For your content, you could create a `master` and a `drafts` branch, and whenever you've finished and committed a draft to the `drafts` branch and wish to publish, do: 

    git co drafts posts/2013-01-01-happy-new-year.md
    git add .
    git commit -m "New post."

## Concepts

### Data sources

Data sources are the files an individual route will use to render pages.

### Context, or, how Hector finds things to render

Context are the variables that get passed to a template to render it, and that also often determine the path and name of the rendered file. You might know them as _locals_ or _data_ or _template variables_.

In most web frameworks, context mostly comes from a database. In Hector, context comes from the file path, a file's content (available as `content`) or its front matter (available as `meta`), any defaults or global variables you specify.

Hector also uses context to fill in placeholders in a route or a layout.

In addition to the context Hector passes on from the individual file that is being rendered (available under `context`, but also expanded out into `content` and `meta`), it will also include the context from all other files in the data source for a route. You'll find these under `data`. Hector also passes in a couple of template helpers. These are under `helpers`.

    context set
        file path
        front matter
        content
    siblings context sets
        file path
        front matter
        content
    defaults
    globals
    helpers

The main use for context is filling out the placeholders in your template files, but it will also be used to figure out where the output of a rendered template should go (as specified in your `route` parameter) and you can also use it to dynamically pick the layout that should be used to render a context set with.

    layout
    template
    path

If a route contains placeholders, like for example `{year}/{permalink}`, Hector will loop through all context sets, and render a file for each. Routes almost always have placeholders, so you can do things like render however many blogposts using the same route, rather than having to create a separate route for each individual file.

If your route doesn't contain any placeholders and looks like, for example, `feed.xml`, Hector just render the template once. Any templates can access all the different context sets from a data source through the `data` variable. If you specify a context in your route, which is optional for routes without placeholders, you can access that data through `context`. This is useful for generating feeds, archives and the like, where you put many different pieces of content on a single page, or it can be useful for generating prev/next links on individual blogposts.

Advanced users can use pipes to add, combine or remove context programmatically before it gets passed to the rendering engine. For example, if you have separate `{page}-side` and `{page}-main` files in a data source, you can modify the rendering pipeline. See "How to use pipes" below.)

Hector will try to find any files that match your `context` parameter, and use any placeholders you have in that parameter to populate the context, just as it can use the file's content to populate context. So for example you can have your traditional, Jekyll-like file structure like 
`posts/{year}-{month}-{day}-{title}` but it's equally easy to do something like `{author}/{year}/{category}/{title}`. Or you can just do `content/{filename}` and specify the permalink, publication date and whatever else you need in the file itself. Hector treats context from the filename exactly the same as it does context from the file.

A context set is the name for one bundle of content, gathered from a file, its file path and any default and global variables that may exist.

Context can be put to use almost everywhere in Hector. So for example, you don't need to render a route using just a single layout, you can specify `layout: '{layout}'` and Hector will decide where to send the context set based on the metadata in the front matter, the file path or a default value.

### Front matter

Front matter is metadata that belongs with your content. It allows you to write your content in, say, Markdown or Textile, but allows you to add in some YAML metadata before your writing, so specify for example that content's author, its title and some tags or categories.

If you're not really working with prose content, but rather with data, it is probably easier to use JSON or pure YAML instead of working with front matter.

### Globals and defaults

Context sets from data sources can be supplemented with defaults (activated whenever a variable is not specified in the context set) and globals (available to any route and any template, can be either data or JavaScript functions that get passed to the template).

If a variable is present in a context set, it'll be used instead of the default. A default will take precedence over any same-named global.

### Routes and rendering

* route
* layout
* template functions
* pipes: parsers/mungers/plugins/generators (a pipe that doesn't receive any context)/processors/whatever

### Partial rendering

* only rerender certain routes (specify an information source and 
  we'll find all applicable routes, or pass a route and we'll
  rerender that route and all others with the same information source, 
  e.g. detail and list routes for your posts)
* partial rendering: only render files that are newer than the last build
* advanced partial rerendering through custom functions (we pass you 
  a list of what we want to render, you give us back a list of
  files we actually should render)

## How to prototype your site

While you can rebuild your site every time you make a change to a template or a static asset, to see the results, you might consider using `Draughtsman` as a prototyping server.

:: explain how ::

## How to use pipes

Pipes can generate context, manipulate it, render it or whatever else you want them to do. Together with template helpers, they are the most important plugin mechanism in Hector. The basic structure of a pipe is this:

    /*
     * Context is any context the previous pipe is passing on next is how you 
     * pass control to the next pipe send will add content to Hector's output
     * (only useful if you want to bail out early, otherwise `next` will take 
     * care of this for the last pipe in the line)
     */
    function pipe (context, next, send) {
        context.debug = 'This is a test.';
        next(context);
    }

Pipes give you full control over the flow from data gathering to the final rendering.

    function pipe (context, next, send) {
        if (context.doNotPublish) {
            return;
        } else if (context.raw) {
            send(context.path, JSON.stringify(context));
        } else {
            next(context);
        }
    }

Processors would be passed send and next functions; middlewares pass on state to next(), custom renderers call send() instead. Processors that can be used as both middleware and final renderer can check whether `next === undefined` and act accordingly.

### As context generators

Sometimes, you need to grab content from usual places.

### As file generators

Occassionally, you might want to bypass Hector altogether and render or otherwise generate output your own way.

### As filters

Sometimes, you need to decide what gets rendered and what doesn't.

### As processors

Sometimes, you want to add metadata or modify context before handing off your data or content to get rendered.

### The default rendering pipeline

When your route doesn't specify any pipes, Hector will use two by default, called `find.js`, `help.js` and `render.js`. When specifying your own pipes, usually (though not always) you will want to add these back in there, usually as the very first and very last steps.

    route:
        pipes:
            - find.js
            - help.js
            - my-pipe.js
            - render.js

To make your life a little bit easier, pipes are dividided into three phases: `collect`, `process` and `render`. If you specify the pipeline for just one phase, others are unaffected. The last example, rewritten, would look like: 

    pipes:
        process:
            - my-pipe.js

## Template helpers and globals

:: todo ::

## Other ways to extend Hector

Hector depends on a couple of external libraries that provide much of its functionality. If you want to change how Hector works, there's a good chance you'll actually be changing one of those dependencies.

You can add new template langagues and markup formats through [Tilt.js](http://github.com/stdbrouw/tilt.js)

You can improve the optimization and actual page generation process in [Railgun](http://github.com/stdbrouw/railgun).

Fetching the context from data sources happens in [Espy](http://github.com/stdbrouw/espy).

::examples::

## Using Hector in tandem with dynamic applications

Some options: 

* Use your dynamic application to generate JSON or other data files, set up Hector to turn that data into a static website and trigger a Hector build whenever the data changes.
* Use Hector and add server-side includes into your templates for any dynamic bits
* Use JavaScript to add in any dynamic bits like comments or things like "time ago".

## How to do...

### How can I just render a single static page?

### How do I include static assets?

### What do I do if Hector's context fetcher doesn't work for my data or content?

## Coming from Jekyll

What if you have a Jekyll blog, and are considering moving it to Hector?

Converting your Jekyll permalinks into a Hector route is easy. This route will work for most people: 

    routes:
        posts:
            route: '{year}/{month}/{day}/{permalink}'
            layout: 'post'
            context: '_posts/{year}-{month}-{day}-{permalink}'

You can leave your content perfectly as-is: Hector works with YAML front matter just like Jekyll does.

While Hector has support for the [Plate](https://github.com/chrisdickinson/plate) template language, which is very similar to Liquid and to the Django template language, it might be easiest to create new templates. Some of the template helpers you are used to might be missing, and the syntax and feature set of Plate and Liquid is *mostly* but not entirely the same.

Instead of `page`, use the `meta` variable to access the YAML front matter. Content is still available through `content`.

## Prior art

We like how [Jekyll](http://jekyllrb.com/) can be extended through extensions, converters and generators. And with [Octopress](http://octopress.org/) on top, it's really easy to set up a blog and push it to S3. We dislike how constrained you are in where your content lives and where it is output out of the box, making it less than ideal for anything that's not a blog.

We like [Middleman](http://middlemanapp.com/guides/dynamic-pages) because it is both a prototyping tool and a site generator. We dislike all the trade-offs Middleman makes to cater to both use-cases in a single tool.

We like [Mynt](http://mynt.mirroredwhite.com/) because it gives you freedom of markup and rendering engines, and because it's geared towards producing more complex sites. But it sticks too close to the Jekyll mold.

We're impressed by [Django-bakery](https://github.com/datadesk/django-bakery) and [Flask-Static](http://exyr.org/2010/Flask-Static/) because they are some of the few site generators that rely on routes and controllers, rather than a whole host of naming conventions, but they carries too much unnecessary baggage because they're built on top of dynamic web frameworks rather than being built for static site generation from the start.

We're intrigued by how [Bonsai](http://tinytree.info/) makes it easy to produce books and documentation, with hierarchical navigation and ordered chapters. Similarly, [Pelican](http://docs.getpelican.com) can output to PDF, which is useful too.

We hope to someday have docs as good as [Nanoc](http://nanoc.stoneship.org/)'s.

We also looked at Wintersmith, Hyde, Phrozn, blatter, blogofile, Chisel, StaticMatic, Frank, Hobix, ikiwiki, Korma, Pyll, Pagegen, Stacey, Toto, Poole, Webby, PieCrust, Petrify, Ace, Stasis, Graze, Rizzo, BAM, Blacksmith, Tempo, Masonic, Statix, Zodiac, Molehill, Machined and Voldemort. They were built for no other reason than that crafting your own blog software is fun. That's pretty cool too.

### Other resources

http://www.odopod.com/blog/introduction-static-website-generators/
http://rrees.wordpress.com/2009/06/01/semi-static-cmss/
http://www.quora.com/How-a-does-a-static-site-generator-like-Jekyll-work