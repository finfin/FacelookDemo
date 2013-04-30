# /lib/emailer.coffee

emailer = require("nodemailer")
fs      = require("fs")
_       = require("underscore")
#env					= process.env.NODE_ENV || 'development'
config				= require('../../../config/mailer')

class Emailer

	options: {}

	data: {}

	attachments: []
	###
		# Define attachments here
		attachments: [
			fileName: "logo.png"
			filePath: "./public/images/email/logo.png"
			cid: "logo@myapp"
		]
	###

	constructor: (@options, @data)->
		console.log @data

	send: (callback)->
		html = @getHtml(@options.template, @data)
		attachments = @getAttachments(html)
		messageData =
			to: "'#{@options.to.name}' <#{@options.to.email}>"
			from: "'Zencher.com' <#{config.username}>"
			subject: @options.subject
			html: html
			generateTextFromHTML: true
			attachments: attachments
		transport = @getTransport()
		transport.sendMail messageData, callback

	getTransport: ()->
		emailer.createTransport "SMTP",
			service: config.service
			auth:
				user: config.username
				pass: config.password

	getHtml: (templateName, data)->
		#host = config.host
		data.host = config.host
		templatePath = "./views/emails/#{templateName}.html"
		templateContent = fs.readFileSync(templatePath, encoding = "utf8")
		_.template templateContent, data, {interpolate: /\{\{(.+?)\}\}/g}

	getAttachments: (html)->
		attachments = []
		for attachment in @attachments
			attachments.push(attachment) if html.search("cid:#{attachment.cid}") > -1
		attachments

exports = module.exports = Emailer