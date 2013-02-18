Hector is an MIT-licensed static site generator. Perfect for blogs, but built to handle more complex sites especially. Hector is inspired on dynamic MVC frameworks. It has routes and views and controllers and it treats the file system like a database. If you can think it up, Hector can generate it.

Because Hector is built on Tilt.js, you can use just about any template language and markup language you want. Here's a list of languages we currently support......

## Features

* Support for many different templating and markup languages.
* Use any markup language as well as YAML, CSV and JSON content with whatever directory layout you like.
* Preprocesses anything that compiles into CSS or JavaScript (like [LESS](http://lesscss.org) or [CoffeeScript](http://coffeescript.org)) and optimizes scripts, styles and HTML.
* An easy switch from Jekyll.
* A full-featured plugin system. Hook into any part of Hector's data gathering and rendering process.

## Get started

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

Here's what your routes.yml might look like, with a file structure like the above: 

    :: todo ::

### How to prototype your site

While you can rebuild your site every time you make a change to a template or a static asset, to see the results, you might consider using `Draughtsman` as a prototyping server.

:: explain how ::

## Concepts

### Context, or, how Hector finds things to render

* context

If the route contains placeholders, it'll loop through all context sets, and render a file for each. If not, it'll just render the template once, and that template can access all the different context sets under `data` (also available there on dynamic renders a.k.a. loops, but usually not very useful in that case)

(If multiple input files should be combined into one rendered page, for example if you have separate `{page}-side` and `{page}-main` files, you can modify the rendering pipeline. See "How to use pipes" below.)

Hector will try to find any files that match your `context` parameter, and use any placeholders you have in that parameter to populate the context, just as it can use the file's content to populate context. So for example you can have your traditional, Jekyll-like file structure like 
`posts/{year}-{month}-{day}-{title}` but it's equally easy to do something like `{author}/{year}/{category}/{title}`. Or you can just do `content/{filename}` and specify the permalink, publication date and whatever else you need in the file itself. Hector treats context from the filename exactly the same as it does context from the file.

* front matter

Front matter is a concept you'll find in most static site generators. It allows you to write your content in, say, Markdown or Textile, but allows you to add in some YAML metadata before your writing, so specify for example that content's author, its title and some tags or categories.

* globals and defaults (and precedence: context > defaults > globals)

### Routes and rendering

* route
* layout
* template functions
* pipes: parsers/mungers/plugins/generators (a pipe that doesn't receive any context)/processors/whatever

## How to use pipes

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

When your route doesn't specify any pipes, Hector will use two by default, called `find.js`, `help.js` and `render.js`. When specifying your own pipes, usually (though not always) you will want to add these back in there, usually as the very first and very last steps. Some examples.

## Other ways to extend Hector

- add new layout or markup formats through tilt.js
- add template functions to `globals`
- Modify the libraries Hector depends on: improve the optimization and rendering process in `railgun`and context fetching in `espy`.

::examples::

## How to do...

### How can I just render a single static page?

### How do I include static assets?

### What do I do if Hector's context fetcher doesn't work for my data or content?

## Coming from Jekyll

What if you have a Jekyll blog, and are considering moving it to Hector?

* permalinks => route
* Liquid templates => ?

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