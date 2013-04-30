util				= require 'util'
fs 					= require 'fs'
express				= require 'express'
path				= require 'path'
passport			= require 'passport'
env					= process.env.NODE_ENV || 'development'
config				= require('../config/config')[env]
mongoose 			= require 'mongoose' 
#upload 				= require 'jquery-file-upload-middleware'

require('source-map-support').install()


# Database connect
db = config.DB
dbName = db.NAME
uristring = process.env.MONGOLAB_URI or process.env.MONGOHQ_URL or "mongodb://localhost/#{dbName}"
mongoOptions = { db: { safe: true }}
mongoose.connect uristring, mongoOptions, (err, res) ->
	if err 
		console.log "ERROR connecting to: #{uristring}. #{err}"
	else
		console.log "Successfully connected to: #{uristring}"


#cleanup before exit
process.on 'exit', ->
	util.log "Closing DB..."
	mongoose.connection.close()

# Bootstrap models
models_path = "#{__dirname}/web/models"
fs.readdirSync(models_path).forEach (file) ->
	if file.match /.js$/
		require "#{models_path}/#{file}"

#require passport config
pass				= require './web/util/pass'
app					= express()

#WEB Server
app.set('views', "#{__dirname}/../views")
app.set('view engine', 'jade')
app.use(express.favicon())
app.use(express.logger())
app.use(express.cookieParser())
app.use(express.bodyParser())
app.use(express.methodOverride())
app.use(express.session({ secret: 'signupdemo dev' }))
app.use(passport.initialize());
app.use(passport.session());
app.use('/api', pass.authenticateAPIKey)
app.use(app.router)
app.use(express.static(path.join(__dirname, '..', 'public')))
app.use((err, req, res, next) ->
	console.log err
	res.send 500
)

# require controllers
#routes				= require './web/controllers/routes'
#views				= require './web/controllers/views'
user				= require './web/controllers/users'
post				= require './web/controllers/posts'

#RESTful API Route
app.post('/signup', user.signup)
app.get('/login', user.login)
app.get('/validateToken', user.validateToken)
app.get('/logout', user.logout)

app.get('/api/posts', post.listPosts)
app.post('/api/posts', post.createPost)
app.delete('/api/posts/:id', post.deletePost)
app.listen(config.WEB_PORT)


process.on 'uncaughtException', (err) ->
	util.log err
	console.log err.stack