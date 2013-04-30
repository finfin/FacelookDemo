mongoose 		= require 'mongoose' 

#******* Database schema TODO add more validation
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

# User schema
postSchema = new Schema(
	text: String
	owner:
		type: Schema.Types.ObjectId
		required: true  
	#filename: String
	modifiedTime: Date

)

# Export user model
materialModel = mongoose.model 'Post', postSchema, 'Posts'

