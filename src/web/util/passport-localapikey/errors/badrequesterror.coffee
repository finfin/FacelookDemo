###
`BadRequestError` error.

@api public
###
BadRequestError = (message) ->
  Error.call this
  Error.captureStackTrace this, arguments.callee
  @name = "BadRequestError"
  @message = message or null

###
Inherit from `Error`.
###
BadRequestError::__proto__ = Error::

###
Expose `BadRequestError`.
###
module.exports = BadRequestError