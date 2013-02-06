tilt = require 'tilt'
f = new tilt.File path: '../example/posts/2012-08-05-hello-waukesha.md'
tilt.compile f, null, (content) -> console.log content