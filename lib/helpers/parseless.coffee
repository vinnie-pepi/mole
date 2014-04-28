fs   = require('fs')
less = require('less')
path = require('path')

module.exports.setup = (app) ->
  rootDir = process.cwd()
  parser = new less.Parser({
    paths: [ path.join(rootDir, 'public/stylesheets') ]
  })
  app.use (req, res, next) ->
    if path.extname(req.path) == '.css'
      publicPath = path.join(rootDir, 'public', req.path)
        .replace(/.css$/, '.less')
      fs.exists(publicPath, (exists) ->
        if not exists then return next()
        rawLess = fs.readFileSync(publicPath).toString()
        parser.parse(rawLess, (e, tree) ->
          if e then throw e
          res.set('Content-Type', 'text/css')
          res.end(tree.toCSS())
        )
      )
    else
      next()
      
    
