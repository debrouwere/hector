Because Hector is based on Tilt and Railgun, the app itself can actually be really light. The only things it has to take care of are: 

* Using Tilt.js its context submodule to fetch data (blogposts etc.) and use it to generate a page for each context object.
* A config file that specifies
  - permalink structure
  - what files to exclude (not render or otherwise serve)
  - server port (if served)
  - where to find data or templates, so you can use the same data to render e.g. a web version and an ebook version of a site... with a file structure somewhat like this

  proj
  - data
  - platforms
    - web
      tpl.jade
    - ipad
      tpl.jade

(Use a default config file location unless a  config file is specified as a CLI flag)

* (Optionally/pony) some sort of plugin system that can hook into the rendering and context gathering processes.
* Pass Railgun a bundle instead of taking one from it, to account for 1-to-m rendering


THE "NORMAL" ROAD (Draughtsman, Middleman)

template --> find context

THE "STATIC SITE" ROAD (Jekyll & co)

context --> find template.html
-or-
route --> find template and context

(Espy should acknowledge that sometimes you just want to fetch content without knowing what template it is for, by providing separate `find` and `findFor` methods.)

Perhaps a route-like system is in order, similar to generic views in Django?

<route> <template=data.template> <context=data>

/about                      static.html     data/about.yml (this is implied)
/:title                     static.html     pages
/:year/:month/:day/:title   blogpost.html   
/:year/:month/:day/:title   :layout         _posts
/:year/:month/:day/:title   :layout         posts/:year
                                            (this looks in all subdirs to 'posts'
                                            and passes subdir name to the :year variable)

                                            posts/:year/:month-:day-:title

routes:
    - name:     blogposts                           (just for documentation's sake)
      route:    :year/:month/:day/:title            (:title is default)
      template: :layout                             (:layout is default)
      context:  posts/:year/:month-:day-:title
      defaults:
          language: en
          template: blogpost
      processors:
          - processors/customblogcontroller

`route` and `template` consume context, and `context` and `defaults` generate it, in the case of `context` both from the filename and from its contents

Or in Python syntax, which is slightly more elegant perhaps: 

routes:
    posts:
      route:    {year}/{month}/{day}/{title}
      template: {layout|'blogpost'}
      context:  posts/{year}/{month}-{day}-{title}

If the route contains placeholders, it'll loop through all context sets. If not, it'll just render the template once, and that template can access all the different context sets under `data` (also available there on dynamic renders a.k.a. loops, but usually not very useful in that case)

Because there's no controller logic, we can also do little niceties like allow default arguments / fallbacks in route parameters, as in e.g. `{layout|'blogpost'}` (quotes mean literal instead of var) -- though the `defaults` parameter can work for that too.

Default file structure could be like this: 

BLOG
- posts
- pages
- layouts
- assets

That way, combined with routing, you never have to underscore anything and have full control over what ends up where.

Serving assets could be magical (if in an `/assets` directory) but could just as well work manually with something like this:

routes:
    assets:
        route:   assets/{file}  // we'd have to make sure our regex can match across slashes
        context: assets/{file}  // context usually doesn't care too much about extensions but
                                // in this case it should
        processors:
            - preprocess    // preprocess CoffeeScript, Stylus etc. and modify the {file} variable
                            // accordingly (change extension where necessary)
            - static        // serve static files instead of gathering context, rendering templates etc.

----------

PLUGGABILITY

- add new formats through tilt.js
  (maybe add markup languages back into tilt.js anyway, because Tulsa
  would be pluggable just like a template language is, and we'd need that kind of 
  pluggability to turn Hector into a documentation generator)
- register plugins (either generic variables/functions or language-specific ones) in tilt.js
- support optional views to preprocess context or do all sorts of other crazy things, 
  even down to deciding whether to render or not, or ignore / change the 
  template defined in the route (in a middleware-like fashion, so you can stack multiple
  views/middlewares on top of each other; and you can enable middleware globally or
  for a specific route)
- ?

Processors would be passed send and next functions; middlewares pass on state to next(), custom renderers call send() instead. Processors that can be used as both middleware and final renderer can check whether `next === undefined` and act accordingly.

Built-in processors should use this same basic functionality. There should be a processor for fetching context (obviously) but also to add in helpers to the context, analog to Jekyll's prev/next variables, as well as date/time formatting helpers (convert year/month/day variables into a JS date object so people can use date.toLocaleFormat etc.; make file created and modified dates available etc.), and then finally the processor for rendering

Processor paths are hector/processors, <myproject>/processors and then myproject/<path>

Default processors:

    - find
    - help
    - render

----------

OUTPUT

- serve (to preview locally or because you don't have any other server running on your VPS)
- local build w/ railgun
- upload to S3 w/ railgun

PARTIAL RERENDERING

- Partial (re)rendering would be a true pony. Something like

hector . ./public --only posts year:2012

which would then fill in the route so instead of looking for context in 
/posts/{year}-{month}-{day}-{title} it would look for
/posts/2012-{month}-{day}-{title}

--only pages, home                     => only generate pages and homepage
--only posts layout: quote             => only generate quotes

With a couple of magical selectors that go beyond filtering on metadata:

--only posts recent                    => check last modified date on an existing /public
                                          folder and look for anything newer than that
--only posts published                 => don't publish content that's dated in the future

Or maybe --filter and --exclude make more sense

--filter posts recent --exclude pages     => render every route except pages, and only rerender recent posts

----------

DRAUGHTSMAN INTEGRATION

1. create a `data` subdir inside your `layouts` directory, where you can put fixtures / dummy data to test your templates with
2. <link rel="stylesheet" src="../assets/stylesheet.css" /> should actually work just fine, because we'll pull the static site through Railgun and it'll know how to find that relative path and remove it from the final html.