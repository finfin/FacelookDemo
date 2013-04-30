util				= require 'util'
async				= require 'async'
helper				= require '../util/helper'
env					= process.env.NODE_ENV || 'development'
config				= require('../../../config/config')[env]

mongoose			= require 'mongoose'
Post 			= mongoose.model('Post')


###
# GET /materials
exports.showMaterial = (req, res) ->
	#ua = req.headers['user-agent']

	#TODO: error handling
	#if /like Mac OS X/.test(ua) and /iPad/.test(ua)
	async.parallel(
		materials: (callback) ->
			getMaterials req, (err, results) ->
				return callback err if err

				callback null, results
		tags: (callback) ->
			CourseController.getCourses req, (err, results) ->
				return callback err if err

				callback null, results
	, (err, result) ->
		if err
			res.send 500, 'Insertion of materials failed'
			util.log err.stack
		else
			res.render('list_material', {title: '檔案列表', materials: result.materials, tags:result.tags, user: req.user})
	)
###

# GET /posts/
exports.listPosts = (req, res) ->
	getPosts req, (err, results) ->
		if err
			console.log err
			return res.send 500

		res.send results

# get materials by tag or get all
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


###
exports.findMaterial = (req, res) ->
	materialID = req.params.id

	Material.findById materialID, helper.parseProjection(req.query), (err, material) ->
		if err
			util.log err
			res.send 'Error Getting Requested Material'
		#download file
		if req.query.download is 'true'
			#TODO: encoding filename
			res.setHeader('Content-disposition', "attachment; filename=#{material.filename}")
			res.setHeader('Content-type', material.type)
			file = "#{config.FILE_ROOT_DIR}/files/materials/#{materialID}"
			util.log "Get File:#{file}"

			#TODO: 把file size存在DB，就不用每次存取檔案資訊
			#THINK: reading DB/FS, which is faster? any alternatives?
			fs.stat file, (err, stat) ->
				if err
					throw err
				res.setHeader('Content-Length',stat.size)
				filestream = fs.createReadStream(file)

				filestream.on 'data', (chunk) ->
					res.write(chunk)
				
				filestream.on 'end', ->
					res.end()
		else
			res.send material
###

# POST /posts/
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

