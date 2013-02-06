=========
PRIOR ART
=========

Hector takes its inspiration from Jekyll and Middleman, two other excellent static generators. Hector is a little bit more flexible and is a node.js application rather than a Ruby one, but all three are very nice options.

## Other options to explore (and their redeeming qualities)

- Jekyll

http://jekyllrb.com/

The godfather. Easy configuration through config.yml. Plugin support.

Extensible through
* Liquid extensions (adding context, functions, filters, template tags to the template language)
* Converters (new markup languages)
* Generators (generate new content according to your own rules -- equivalent to route+controller)

- Middleman

http://middlemanapp.com/guides/dynamic-pages
http://middlemanapp.com/guides/blog

Interesting because it is primarily a prototyping tool, secondarily a static site generator and thirdly a blog generator -- and it shows the kinds of trade-offs needed to cater to all these needs.

The thing to steal: its context-finding conventions make a ton of sense (though more for Draughtsman than for Hector)

- Mynt

http://mynt.mirroredwhite.com/

Freedom of markup language and rendering engine. Explicitly geared towards more complex sites. Has a couple of niceties built-in like `tags` and `archives` context -- as you may know, generating archive pages with Jekyll can be a bit of a pain.

- Octopress

http://octopress.org/

Octopress is built on top of Jekyll. Has plugins and other goodies (e.g. for code highlighting) that allow you to get started simply by forking a repo on GitHub and then you can get cracking. Sort of like wordpress.com for nerds.

- Wintersmith

http://jnordberg.github.com/wintersmith/

Opinionated: Markdown and Jade, that's what you get.

Solid CoffeeScript-based plugin system that has access to pretty much everything.

- Django-bakery

http://datadesk.latimes.com/posts/2012/03/introducing-django-bakery/
https://github.com/datadesk/django-bakery

Like Mynt, works for more complex sites too, because of its Django DNA. Interesting because sometimes we just build static sites because we're working with read-only data and would like the speed gains of going static... but aside from that, a solid back-end framework is really what we need. It's not because you're suddenly not connecting to a database that the entire way you develop a site should change.

(It is actually even more advanced, because you can host a dynamic version of your site locally or wherever you want, and then "bake" it -- so admin users have an easy way to update a static site through a web interface, which is sort of nice, and also the rationale behind Dropbox-based static site generation.)

OTOH, because it builds on Django, it has lots of complexity you don't need for static sites.

Its built-in S3 integration is very useful.

- Hyde

http://ringce.com/hyde

Hyde tries to offer a little bit more out of the box, like a Google sitemap, an RSS feed, breadcrumbs, recent posts block et cetera. Otherwise it's pretty much a Jekyll clone.

- Phrozn

Remarkably, Phrozn doesn't seem to distinguish between markup formats and theme languages, it calls all of them "text processors." Seems weird to me.

Has a command-line app to quickly initialize a project.

Because Phrozn is built in PHP, which doesn't really have a concept of "modules" or "packages" (PEAR notwithstanding), Phrozn supports "bundles" instead: pluggable code you can hook into your project without cluttering the project itself.

YAML front matter is very similar to Jekyll. You can define the permalink inside of the front matter instead of depending solely on the filename.

- Bonsai

http://tinytree.info/

Has a folder structure that doesn't depend on underscores:

    /myblog
        /content
        /public
        /templates

For content, Bonsai supports content ordering: simply prefix a directory or file with `n.`, for example `1.introduction.md`. It's true that most static site generators have lousy support for content ordering (though for a blog this isn't an issue, and just manually ordering a 7-item menu is no big deal either -- but e.g. for documentation it *is* a problem).

The trouble with Bonsai's ordering is that you can't easily update the order without renaming every file. If this is the route you take, at the very least, you need to provide reordering support through a CLI.

In line with its support for ordering, it also supports hierarchical navigation, and has `children`, `ancestors`, `parent` and `siblings` context variables. Again, useful for documentation and book-like content.

Also expects people will use YAML front matter a lot to create more complex sites.

- blatter

https://bitbucket.org/jek/blatter/

Very basic. Has publication functionality built in: send a rendered site to a server over (s)ftp.

- blogofile

http://www.blogofile.com/

Another one of those static site generators that should work very well for blogs (with goodies like Disqus integration, syntax highlighting, built-in feeds, tags, categories and so on) but isn't very suitable to anything outside of that use-case.

Can publish to S3.

- Chisel

https://github.com/dz/chisel

Very, very basic. One of the few generators that doesn't work with YAML frontmatter.

- StaticMatic

http://staticmatic.rubyforge.org/

Looks like Middleman light.

- Frank

Very basic. Has no data format, similar to Phrozn, though with YAML front matter (in your templates) and template layouts you can fake it: extend from the layout you want and then simply write your content. Anyway, still not your best bet for anything that's not a brochure.

- Hobix

http://hobix.github.com/hobix/

Hobix is one of a couple of static site generators that work entirely based on YAML, so not just YAML front matter, but your blog's body content would just be under a `content` key in a YAML file. I feel like this emphasizes purity over practicality, and also makes it less easy to specify the markup language you're using for your body copy.

Anyway, this is a scratch-an-itch deal: it probably works for the guy who made it, but that's about it.

- ikiwiki

http://ikiwiki.info/

Nothing particularly special here, except for the fact that this static site generator is explicitly used for wikis. They call it a "wiki compiler." Combined with Git, that gives you revision support etc., which is kind of neat (though perhaps not optimal in terms of performance)

- Korma

https://github.com/sandal/korma

Git-based blog, much like Octopress and a couple of others. Very tiny and basic (or 'zen', if you will)

- Pyll

https://github.com/arthurk/pyll

Looks for html, rst and markdown files and parses them, and that's all it does. Almost more like a generic template parser than a site generator.

- Nanoc

http://nanoc.stoneship.org/

Nanoc claims to be a web publishing system for small to medium-sized websites, so it's more ambitious than most static site generators. CLI-based, like most generators.

Very good (and pretty) documentation and has a good getting-started setup with a basic design built in. They even explain how to use Markdown and how to create HAML templates, so while they don't compromise on the CLI aspect of the whole thing, they do try to make it easy. They explain how to make common website elements like image galleries. (As a result, the docs are huuuuge, though.) This makes sense from a "see what this thing does" point of view, but I don't know if you can ever make a static site generator palatable to non-technical users unless you provide a WYSIWYG editor and wrap the CLI in a minimalistic desktop app that does the generating and uploading for you.

Has the common YAML front matter + data files setup. Customization through filters and helpers, also pretty common. You can also add new data sources (context finders -- like Jekyll generators but without actually generating anything) and CLI commands.

Like Jekyll and some others, has a watcher that'll recompile your site on the fly.

- Pagegen

http://pagegen.phnd.net/

Not general-purpose, but speeds up side building by assuming certain things about your site (you'll want a sidebar, a header, etc.)

- Stacey

http://www.staceyapp.com/

Stacey markets itself as "the lightweight content management system."

Uses a YAML-like (but not YAML-compatible) data format. Has its own template language too. Not really static: uses PHP to process your flat files on the fly (though it does cache some things), so there's no site generation step.

This is a flat-file-based publishing system, but not a generator.

- Toto

http://cloudhead.io/toto

Very minimalistic. Jekyll-like. YAML front-matter, but it jams your body copy and YAML in a single file without YAML document separators (`---`), so you couldn't read it with a YAML parser without first chopping off everything after the first double newline.

- Pelican

Uses ReST syntax, eww. Has importing tools. Can output to PDF. Some build-in goodies like feeds and syntax highlighting. Pretty run of the mill, though the PDF feature is nice for ebooks, books or presentations I suppose.

- Poole

https://bitbucket.org/obensonne/poole

Jekyll-like. Not a lot of redeeming features.

- Webby

http://webby.rubyforge.org/

Super-basic, though it has some niceties for scientists: embed LaTeX formulates, GraphViz graphs and source code. Supports multiple template languages, though.

- PieCrust

http://bolt80.com/piecrust/

Very Jekyll/Middleman-like. Has support for SmartyPants (proper typographic quotes etc.) out of the box, which is a nice touch. You can choose between static or dynamic serving.

- Petrify

https://github.com/caolan/petrify

Node.js, by Caolan. Docs explain the benefits of static generation in detail: security, speed, deployment etc... though that's about all they explain.

    /data
    /media
    /templates
    /views

Has views/controllers. Can't really tell if some of them are built-in or if you have to create all of them yourself. Would be annoying if the latter.

- Ace

http://blog.101ideas.cz/posts/ace-static-site-generator.html

Ace isn't special in itself, but it's interesting because it claims to be "assumptionless": doesn't assume anything about the kind of content you're creating, where to output it etc.

- Stasis

http://stasis.me/

Supports controllers, though they're not what you think: "Controllers contain Ruby code that executes once before all templates render." Doesn't seem to have a data format / context finder built in.

- Graze

http://mikaelkoskinen.net/post/Graze-Static-site-generator-using-Razor.aspx

One from the C# crowd. Nothing special.

- Rizzo

http://incoherencies.net/archives/announcing-rizzo/

Inspired on Jekyll, but in Groovy. Tiny.

- Flask-Static

http://exyr.org/2010/Flask-Static/

Like Django-bakery and some of the Sinatra-based static site generators. The idea is that you build your site like a dynamic one... and then you "bake it." "Flask-Static builds a static snapshot of a Flask application. It takes a list of URLs, simulates requests to the application, and save the responses in files." You get more flexibility in some cases, though it can be a bit of a mess in other cases: for a blog, how do you know which urls to visit considering all of them share the same route?

- BAM

http://jackhq.tumblr.com/post/17864806180/bam-easiest-static-site-generator-on-the-planet

Minimalistic.

- Blacksmith

http://blacksmith.jit.su/

Minimalistic. Opinionated: no templating language (uses Weld instead), only Markdown.

- Tempo

http://www.catnapgames.com/blog/2011/10/13/tempo-php-static-site-generator.html

A tiny Jekyll in PHP, originally built as a Tumblr replacement.

- Masonic

http://code.google.com/p/masonic/

Study project, Jekyll-inspired.

- Statix

http://www.terafied.com/post/16776048600/statix-template-agnostic-static-site-generator

Minimalistic. Jekyll-inspired. Supports many template languages, using consolidate.js.

- Zodiac

http://www.nu-ex.com/projects/zodiac.html

Zodiac is shell-based: it uses general-purpose tools like awk and find to do its thing. Pretty basic / not very user-friendly. Combines files as such: 

    main.layout
    index.md
    index.meta

- Molehill

http://code.google.com/p/molehil/

Clojure-based. Can import from WordPress. Otherwise tiny.

- Machined

http://rubygems.org/gems/machined

Repurposes Sprockets, Rails 3.1 asset pipeline, for very speedy static websites.

- Voldemort

http://foobarnbaz.com/2011/10/05/voldemort-a-jinja-powered-static-site-generator/

Scratch-an-itch deal in Python. Only supports Markdown and Jinja2.

## Thoughts

When people say that there's a lot of static site generators out there, that's not necessarily true. Building a blog is a fun little project for most programmers, and so there's many code dumps or very tiny generators out there that were made "just for the heck of it" – but very few that actually have a community around them and do more than what the author needed for his or her own blog. Moreover, even when you look at just the popular ones, a lot of them are Jekyll clones, made because the author wanted Jekyll in <insert language>.

Django-bakery and Flask-static are the ones to look at in the "bake a dynamic site" sphere.

Jekyll, Hyde and Nanoc have the most mindshare among the blog engines.

Phrozn, Middleman and to a lesser extent Bonsai and Machined have some mindshare as static site (not blog) generation.

Octopress and Jekyll are leading the way in Git/GitHub-based systems.

So the static site generator sphere is really not as crowded as it looks.

## Other resources

http://www.odopod.com/blog/introduction-static-website-generators/
http://rrees.wordpress.com/2009/06/01/semi-static-cmss/
http://www.quora.com/How-a-does-a-static-site-generator-like-Jekyll-work

## Conclusions

=> allow any kind of templating language and markup language
=> support more complex sites
   - real, proper routing
   - because there's no concept of controllers (except through plugins), 
     you generally want to provide more conveniences out of the box so you can do more in the template (without overloading it with logic): template helpers, context sliced up in a couple of different ways (e.g. archive in a dict per year/month) etc.
=> try to build something that tries to stick close to good MVC practices, 
   but simply happens to work with static data sources rather than dynamic ones
=> partial rebuilds if possible: if nothing in /layouts has changed since the last build,
   just regenerate pages from data that has changed (new or changed blogposts, say)