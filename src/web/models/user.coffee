mongoose 		= require 'mongoose' 
bcrypt			= require 'bcrypt'
env				= process.env.NODE_ENV || 'development'
config			= require('../../../config/config')[env]

SALT_WORK_FACTOR = 10


#******* Database schema TODO add more validation
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

# User schema
userSchema = new Schema(
	username:
		type: String
		required: true
		unique: true

	password:
		type: String
		required: true  

	admin:
		type: Boolean
		required: true

	apikey:
		type: String
		required: false
		unique: true

	token:
		type: String
		required: false

	enabled:
		type: Boolean
		required: true

)


# Bcrypt middleware
userSchema.pre 'save', (next) ->
	user = this

	return next()  unless user.isModified("password")

	bcrypt.genSalt SALT_WORK_FACTOR, (err, salt) ->
		return next(err)  if err

		#user.password = bcrypt.hashSync user.password, salt
		#TODO: make sure apikey unique
		user.apikey = generateAPIKey()


		if user.enabled
			user.token = null
		else
			user.token = generateValidationToken()
		bcrypt.hash user.password, salt, (err, hash) ->
			return next(err)  if err
			user.password = hash
			next()
		



# Password verification
userSchema.methods.comparePassword = (candidatePassword, cb) ->
	bcrypt.compare candidatePassword, this.password, (err, isMatch) ->
		return cb(err)  if err
		cb null, isMatch

generateAPIKey = ->
	chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"
	
	return generateRandomToken 32, chars

generateValidationToken = ->
	chars = "1234567890"
	
	return generateRandomToken 8, chars

generateRandomToken = (len, chars) ->
	charLen = chars.length
	#token = new Date().getTime() + "_"
	token = ''
	x = 0

	while x < len
		i = Math.floor(Math.random() * charLen)
		token += chars.charAt(i)
		x++
	return token

# Export user model
userModel = mongoose.model 'User', userSchema, 'Users'

