fs = require 'fs'
fs.path = require 'path'
glob = require 'glob'

module.exports = (callback) ->
    root = fs.path.join @router.root.assets, @root
    pattern = root + '/**'

    glob pattern, {mark: yes}, (err, entries) ->
        # there's probably a better way to filter out directories, 
        # but this works
        files = entries.filter (entry) -> (entry.slice -1) isnt '/'
        callback err, files