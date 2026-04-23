"
HTTP 400 Invalid Request Error. Raised when the API rejects a malformed or invalid request.

  ClaudeInvalidRequestError new statusCode
  >>> 400

  (ClaudeApiError fromStatusCode: 400 json: '{""error"":{""message"":""bad param""}}' requestId: 'req_1') class name
  >>> 'ClaudeInvalidRequestError'

"
Class {
	#name : 'ClaudeInvalidRequestError',
	#superclass : 'ClaudeApiError',
	#category : 'Claude-Messaging-Errors',
	#package : 'Claude-Messaging-Errors'
}

{ #category : 'accessing' }
ClaudeInvalidRequestError >> statusCode [
	"Return the HTTP status code for invalid request errors"
	^ 400
]
