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


We could look at other routes that share a context, and automatically regenerate these dependencies too. We could also check generation date, and check which context base paths have new files. Then the app can decide which routes to regen automatically (and be right most of the time).

True partial rebuilds (where you can say "hey, only this file is new so only this needs to be rendered") would be pretty awesome, but again, it would only work if you're not making much/any use of the `data` global context and things like that.

Also, N=1 output should probably always be regenerated, because these files very often use `data` in lieu of context.

** double pony would be if Hector could check for a Git repo and take these actions based
   on commit messages, even something as simple as looking for the words "full rebuild"
   and when it finds them doing a force rebuild.
----------

DRAUGHTSMAN INTEGRATION

1. create a `data` subdir inside your `layouts` directory, where you can put fixtures / dummy data to test your templates with
2. <link rel="stylesheet" src="../assets/stylesheet.css" /> should actually work just fine, because we'll pull the static site through Railgun and it'll know how to find that relative path and remove it from the final html.