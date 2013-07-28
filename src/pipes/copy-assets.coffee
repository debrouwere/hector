fs = require 'fs'
fs.path = require 'path'

module.exports = (assets, callback) ->
    # I can't say that I quite understand why we don't always get
    # a proper array, but there ya go.
    if typeof assets is 'string' then assets = [assets]

    for asset in assets
        relativePath = asset.replace (@router.root.assets + '/'), ''
        @destination.add relativePath, {source: asset}

    callback null