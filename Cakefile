fs = require 'fs'
mongoose      = require 'mongoose' 
{print} = require 'util'
{spawn, exec} = require 'child_process'
async = require 'async'
require './src/web/models/user'
User = mongoose.model('User')

init = require './config/init'
env         = process.env.NODE_ENV || 'development'
config = require('./config/config')[env]
bold = `'\033[0;1m'`
green = `'\033[0;32m'`
reset = `'\033[0m'`
red = `'\033[0;31m'`
walk = (dir, done) ->
  results = []
  fs.readdir dir, (err, list) ->
    return done(err, []) if err
    pending = list.length
    return done(null, results) unless pending
    for name in list
      file = "#{dir}/#{name}"
      try 
        stat = fs.statSync file 
      catch err 
        stat = null
      if stat?.isDirectory()
        walk file, (err, res) -> 
          results.push name for name in res
          done(null, results) unless --pending
      else
        results.push file
        done(null, results) unless --pending



log = (message, color, explanation) -> console.log color + message + reset + ' ' + (explanation or '')

launch = (cmd, options=[], callback) ->
  app = spawn cmd, options
  app.stdout.pipe(process.stdout)
  app.stderr.pipe(process.stderr)
  app.on 'exit', (status) -> callback?() if status is 0

build = (watch, callback) ->
  if typeof watch is 'function'
    callback = watch
    watch = false
  log "Compiling coffeescript files...", green
  options = ['-m', '-c', '-b', '-o', 'lib', 'src']
  options.unshift '-w' if watch
  launch 'coffee', options, callback

install = (options) ->
  base = options.prefix or '/data/apps/dove-server'
  lib  = "#{base}/lib"
  console.log   "Installing Dove-Server to #{base}"
  exec([
    "npm install"
    "mkdir -p #{base}"
    "cp -rf node_modules public lib views config package.json #{base}"
    "mkdir -p #{base}/files/materials"
  ].join(' && '), (err, stdout, stderr) ->
    if err then console.log stderr.trim() else log 'done', green
  )

run = () ->
  exec("sudo restart --no-wait -q dove-server", (err, stdout, stderr) ->
    if err then console.log stderr.trim() else log 'done', green
  )

mocha = (options, callback) ->
  if typeof options is 'function'
    callback = options 
    options = []
    
  launch 'mocha', options, callback

docco = (callback) ->
  walk 'src', (err, files) -> launch 'docco.cmd', files, callback

createUser = (user, callback) ->
#createUser = (parentobj, user, emailaddress, pass, adm) ->
  userModel = new User(
    username: user.username
    email: user.email
    password: user.password
    admin: user.admin
    enabled: user.enabled
    )
  userModel.save (err) ->
    if err
      callback err
    else
      log "Saved user: #{user.username}", green
      callback null

seed = () ->
  db_connect()
  log "Initialize mongodb data from config/init", green
  async.each init.users, createUser, db_callback
    

drop = () ->
  db_connect()
  
  mongoose.connection.db.dropDatabase db_callback
  
db_connect = () ->
  db = config.DB
  uristring = process.env.MONGOLAB_URI or process.env.MONGOHQ_URL or "mongodb://#{db.HOST}/#{db.NAME}"
  mongoOptions = { db: { safe: true }}
  mongoose.connect uristring, mongoOptions, (err, res) ->
    if err 
      log "ERROR connecting to: #{uristring}. #{err}", red
    else
      log "Successfully connected to: #{uristring}", green

db_callback = (err) ->
  if err
    log err, red
  else
    log "Database operation successfully finished, closing connection.", green
  mongoose.connection.close()
  
task 'docs', 'generate documentation', -> docco()
task 'build', 'compile source', -> build  -> log ":)", green
task 'watch', 'compile and watch', -> build true,  -> log "Build completed.", green
task 'test', 'run tests', -> build -> mocha -> log ":)", green
task 'install', 'installing apps', -> build -> install({})
task 'deploy', 'Deloying app...', -> install -> run()
task 'seed', 'Seed MongoDB with initial user data', -> build -> seed()
task 'drop', 'Drop all MongoDB data', -> build -> drop()
option '-n', '--name [USERNAME]', 'username for newly created user'
option '-p', '--pass [PASSWORD]', 'password for newly created user'
option '-e', '--email [EAIL]', 'email for newly created user'
task 'adduser', 'Create user', (options) ->
  
  if options.name? && options.pass?
    name = options.name
    pass = options.pass
  else
    console.log "Username/password must be provided(-n, -p), task aborted."
    return

  adm = options.adm or false
  email = options.email or ""
  async.parallel
    create: (callback) ->
      createUser callback, name, email, pass, adm
  , (err, results) ->
    if err
      log err, red
    else
      log "Successfully created user #{name}", green
    finish()



