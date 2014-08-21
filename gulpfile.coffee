"use strict"

# Load plugins
handleError = (err) ->
  console.warn err
  @emit "end"
gulp = require("gulp")

path = require("path")
sass = require('gulp-sass')
#haml = require('gulp-hamlc')
haml = require('gulp-haml-coffee')

$ = require("gulp-load-plugins")()
sourcemaps = require("gulp-sourcemaps")

options = {}

# Scripts
gulp.task "scripts", ->
  
  #.pipe($.jshint('.jshintrc'))
  #.pipe($.jshint.reporter('default'))
  gulp.src("app/scripts/app.coffee",
    read: false
  )
    .pipe($.browserify(
      insertGlobals: true
      extensions: [
        ".coffee"
        ".csjx"
        ".js.jsx.coffee"
      ]
      transform: [
        "coffeeify"
        "reactify"
        "debowerify"
      ]
      shim:
        'jquery-waypoints':
          path: 'app/bower_components/jquery-waypoints/waypoints.js'
          exports: null
        'eventEmitter':
          path: 'app/bower_components/eventEmitter/EventEmitter.js'
          exports: null
    ))
    .on("error", handleError)
    .pipe($.rename("bundle.js"))
    .pipe(gulp.dest("dist/scripts"))
    .pipe($.size())
    .pipe $.connect.reload()


#less_pipe = $.less(paths: [path.join(__dirname, "less", "includes")])
#sass_pipe = $.sass(paths: [path.join(__dirname, "sass", "includes")])

options.sass =
  errLogToConsole: true
  sourceComments: 'normal'
  #sourceMap: 'sass'

gulp.task "sass", ->
  gulp
    .src("./app/stylesheets/app.sass")
    .pipe(sass(options.sass))
    .pipe(gulp.dest("dist/stylesheets"))
    .pipe($.connect.reload())
    .on "error", $.util.log
  return

gulp.task "jade", ->
  gulp
    .src("app/template/*.jade")
    .pipe($.jade(pretty: true))
    .pipe(gulp.dest("dist"))
    .pipe $.connect.reload()


gulp.task "fonts", ->
  $.bowerFiles()
    .pipe($.filter("**/*.{eot,svg,ttf,woff}"))
    .pipe($.flatten())
    .pipe(gulp.dest("dist/fonts"))
    .pipe $.size()

gulp.task "assets", ->
  gulp
    .src("app/{api,stylesheets,includes}/**/*.{less,sass,css,json,html,haml,js}")
    .pipe gulp.dest("dist/")

# HTML
gulp.task "html", ->
  gulp
    .src("app/*.html")
    .pipe($.useref())
    .pipe(gulp.dest("dist"))
    .pipe($.size())
    .pipe($.connect.reload())
    .on "error", $.util.log

gulp.task "haml", ->
  gulp
    .src("app/**/*.haml")
    .pipe(haml())
    .pipe(gulp.dest("dist"))
    .pipe($.connect.reload())
    .on "error", $.util.log
  return

# Images
gulp.task "images", ->
  
  #.pipe($.cache($.imagemin({
  #optimizationLevel: 3,
  #progressive: true,
  #interlaced: true
  #})))
  gulp
    .src("app/images/**/*")
    .pipe(gulp.dest("dist/images"))
    .pipe($.size())
    .pipe $.connect.reload()


# Clean
gulp.task "clean", ->
  gulp.src("dist",
    read: false
  ).pipe $.clean()


gulp.task "styles", ["sass"]

# Bundle
gulp.task "bundle", [
  "assets"
  "scripts"
  "styles"
  "bower"
], $.bundle("./app/*.html")

# Build
gulp.task "build", [
  "html"
  "haml"
  "bundle"
  "images"
]

# Default task
gulp.task "default", ["clean"], ->
  gulp.start "build"
  return


# Connect
gulp.task "connect", $.connect.server(
  root: ["dist"]
  port: 9000
  livereload: true
)

# Bower helper
gulp.task "bower", ->
  gulp.src("app/bower_components/**/*.{js,css}",
    base: "app/bower_components"
  ).pipe gulp.dest("dist/bower_components/")
  return

gulp.task "json", ->
  gulp.src("app/scripts/json/**/*.json",
    base: "app/scripts"
  ).pipe gulp.dest("dist/scripts/")
  return


# Watch
gulp.task "watch", [
  "images"
  "assets"
  "html"
  "haml"
  "bundle"
  "connect"
], ->
  
  # Watch .json files
  #gulp.watch('app/scripts/**/*.json', ['json']);
  
  # Watch .html files
  gulp.watch "app/*.html", ["html"]
  gulp.watch "app/**/*.haml", ["haml"]
 
  # Watch .jade files
  #gulp.watch('app/template/**/*.jade', ['jade', 'html']);
  
  # Watch .coffeescript files
  #gulp.watch('app/scripts/**/*.coffee', ['coffee', 'scripts']);
  gulp.watch "app/scripts/**/*.coffee", ["scripts"]
  gulp.watch "app/stylesheets/**/*.css", ["assets"]
  gulp.watch "app/stylesheets/**/*.sass", ["sass"]
 
  # Watch .jsx files
  # gulp.watch('app/scripts/**/*.jsx', ['jsx', 'scripts']);
  
  # Watch .js files
  gulp.watch "app/scripts/**/*.js", ["scripts"]
  
  # Watch image files
  gulp.watch "app/images/**/*", ["images"]
  return

