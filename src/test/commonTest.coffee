should = require('chai').should()
{CMD, Response, Material, UserArray} = require '../src/common'

describe 'UserArray instance', -> 
	userArray = new UserArray
	it 'should have these functions', ->
		userArray.filterByProp.should.be.a 'Function'
		userArray.removeByProp.should.be.a 'Function'

