util				= require 'util'
async				= require 'async'
helper				= require '../util/helper'
env					= process.env.NODE_ENV || 'development'
config				= require('../../../config/config')[env]

mongoose			= require 'mongoose'
Post 			= mongoose.model('Post')


# GET /posts/
exports.listPosts = (req, res) ->
	getPosts req, (err, results) ->
		if err
			console.log err
			return res.send 500

		res.send results

# GET /api/posts
# get all post
getPosts = (req, cb) ->
	util.log util.inspect req.query
	
	async.waterfall([(callback) ->
		Post.find {}, helper.parseProjection(req.query), (err, materials) ->
			return callback err if err
			callback(null, materials)
	], (err, result) ->
		return cb err if err
			#res.send 500, 'Insertion of materials failed'
			#util.log err.stack
		return cb null, result
			#res.send result.materials
	)

# POST /api/posts/
# Create new post
exports.createPost = (req, res) ->
	console.log("user posting #{req.user._id}")
	post = new Post(
		text: req.body.text
		owner: mongoose.Types.ObjectId("#{req.user._id}")
		#filename: req.files.files[0].name
		modifiedTime: new Date()
	)
	util.log util.inspect post

	post.save (err, post) ->
		if  err
			console.log err
			return res.send 500

		res.send post


# DELETE /posts/:id
exports.deletePost = (req, res) ->
	id = req.params.id
	Post.findByIdAndRemove(id, (err, post) ->
		if err
			console.log err
			return res.send 500
		res.send 200
	)

