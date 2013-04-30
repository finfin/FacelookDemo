chai = require 'chai'
chai.should()
{Lecturer, LecturerController} = require '../src/lecturer'
Common	= require '../src/common'
require 'underscore'

describe 'Lecturer instance', -> 
	lecturer1 = lecturer2 = null
	lecturer1 = new Lecturer('lec1', 'token1')
	it 'should have a name and a token', ->
		lecturer1.name.should.equal 'lec1'
		lecturer1.token.should.equal 'token1'
	it 'Normal commands should return response 200', ->
		resp200 = new Common.Response(200)
		resp = lecturer1.openSlide()
		resp.should.deep.equal resp200
		resp = lecturer1.endSlide()
		resp.should.deep.equal resp200


describe 'LecturerController instance', ->
	lecturerController1 = lecturerController2 = null
