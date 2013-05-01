passport	= require 'passport'
helper		= require '../util/helper'
mongoose	= require 'mongoose'
util		= require 'util'
Mailer		= require '../util/mailer'
User = mongoose.model('User')

exports.index = (req, res) ->
	if req.user
		res.redirect('/materials')
	else
		res.redirect('/login')

exports.getlogin = (req, res) ->
	res.render "login", 
		title: "Login Page"
		user: req.user
		message: req.session.messages


exports.admin = (req, res) ->
	res.send "access granted admin!"



exports.signup = (req, res) ->
	user = new User(
		username: req.body.username
		password: req.body.password
		admin: false
		enabled: false
	)
	
	user.save (err, user) ->
		if err 
			# same user exist
			console.log err
			if err.code == 11000
				return res.send 409
			else
				return res.send 500
		
		res.cookie 'apikey', user.apikey, {maxAge: 86409000, httpOnly: true}
		res.statusCode = 506
		res.end()

		#send email
		options =
			to:
				email: user.username
				name: user.username
			subject: "Confirmation mail"
			template: "confirmation"

		data =
			name: user.username
			token: user.token

		mailer = new Mailer options, data
		mailer.send (err, result) ->
			if err
				console.log err


exports.login = (req, res, next) ->
	passport.authenticate("local", (err, user, info) ->
		return next(err)  if err
		return res.send 403 unless user
		#return res.send 506 unless user.enabled
		res.cookie 'apikey', user.apikey, {maxAge: 86409000, httpOnly: true}
		res.statusCode = if user.enabled then 200 else 506
		res.end()
		###			res.send 
						username: user.username
						apikey: user.apikey
						admin: user.admin
		###
	) req, res, next

exports.validateToken = (req, res) ->
	apikey = req.cookies.apikey
	token = req.query.token
	console.log apikey, token

	#enable account and clear token
	User.findOneAndUpdate
		token: token
	, { enabled: true , token: null}, (err, user) ->
		console.log "user: #{user}"
		return res.send 500 if err
		return res.send 403 unless user

		res.send 200
		
		


exports.logout = (req, res, next) ->
	res.clearCookie 'apikey'
	res.end()