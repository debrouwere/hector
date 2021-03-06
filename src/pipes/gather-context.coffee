_ = require 'underscore'
espy = require 'espy'
async = require 'async'
require 'colors'
utils = require '../utils'

steps = 
    findCandidates: (callback) ->
        recursive = yes
        # espy.findFiles never throws an error but our
        # callback requires it as its first argument
        callback = _.partial callback, null
        espy.findFilesFor @router.root.context, @root, recursive, callback

    filterCandidates: (candidates, callback) ->
        files = candidates.filter (file) =>
            @context.match (file.replace @router.root.context, '')[1..]
        callback null, files

    getFileContext: espy.getContext

    getSetMetadata: (meta={}) ->
        filename = meta.origin.filename
        root = @router.root.context + '/'
        relativeFilename = filename.replace root, ''
        filenameContext = @context.match relativeFilename
        delete meta.origin
        {filename, relativeFilename, context: filenameContext}   

    getPageMetadata: (meta={}) ->
        layout = @layout.fill meta

        # TODO: there's a better way to construct permalinks, see notes in routes.yml!
        path = permalink = @route.fill meta

        # when a route specifies a directory (e.g. `pages/my-page/`)
        # write to index.html inside of that directory
        if path[path.length-1] is '/'
            path += 'index.html'

        {layout, @defaults, path, permalink, root: @router.root}   

    weaveContext: (sets, callback) ->
        getSetMetadata = _.bind steps.getSetMetadata, this
        getPageMetadata = _.bind steps.getPageMetadata, this

        for name, set of sets
            try
                set.hector = getSetMetadata set.meta
            catch error
                console.log 'error w/ set', set
                throw new Error()
            
            set.meta = _.extend set.hector.context, set.meta

            if @route.isTemplate
                pageMeta = getPageMetadata set.meta
                _.extend set.hector, pageMeta

        if @route.isTemplate
            sets = _.values sets
        else
            meta = getPageMetadata {}
            sets = [{context: sets, hector: meta, meta: meta.defaults}]

        callback null, sets

module.exports = (callback) ->
    if @context
        procedure = [
            steps.findCandidates
            steps.filterCandidates
            steps.getFileContext
            steps.weaveContext
            ]
    else
        seed = utils.functional.seed []
        procedure = [
            seed
            steps.weaveContext
        ]

    procedure = procedure.map (step) => _.bind step, this
    async.waterfall procedure, (err, sets) =>
        console.log "Found #{sets.length} context files for route #{@name}"
        callback err, sets