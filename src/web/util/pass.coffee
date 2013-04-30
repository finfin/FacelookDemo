passport = require("passport")
util = require "util"
LocalStrategy = require("passport-local").Strategy
LocalAPIKeyStrategy = require("./passport-localapikey/index").Strategy
mongoose = require("mongoose")
User = mongoose.model('User')
passport.serializeUser (user, done) ->
	done null, user.id

passport.deserializeUser (id, done) ->
	User.findById id, (err, user) ->
		done err, user


passport.use new LocalStrategy((username, password, done) ->
	User.findOne
		username: username
	, (err, user) ->
		return done(err)  if err
		unless user
			return done(null, false,
				message: "Invalid username or password"
			)
		user.comparePassword password, (err, isMatch) ->
			return done(err)  if err
			if isMatch
				done null, user
			else
				done null, false,
					message: "Invalid username or password"
)

passport.use new LocalAPIKeyStrategy((apikey, done) ->
	User.findOne
		apikey: apikey
	, (err, user) ->
		return done(err)  if err
		return done(null, false)  unless user
		done null, user

)

# Simple route middleware to ensure user is authenticated.  Otherwise send to login page.
exports.ensureAuthenticated = ensureAuthenticated = (req, res, next) ->
	return next()  if req.isAuthenticated()
	res.redirect "/logout"

exports.authenticateAPIKey = authenticateAPIKey = (req, res, next) ->
	util.log 'autheticating api'
	passport.authenticate('localapikey', (err, user, info) ->
		return res.send 500 if err
		unless user
			#req.session.messages = [info.message]
			return res.send 403
		return res.send 506 unless user.enabled
		
		req.logIn user,  (err) ->
			console.log "req.user #{util.inspect req.user}"
			return next(err)  if err

			return next()
			#res.redirect "/"

	) req, res, next
	#return next()

# Check for admin middleware, this is unrelated to passport.js
# You can delete this if you use different method to check for admins or don't need admins
exports.ensureAdmin = ensureAdmin = (req, res, next) ->
	(req, res, next) ->
		console.log req.user
		if req.user and req.user.admin is true
			next()
		else
			res.send 403