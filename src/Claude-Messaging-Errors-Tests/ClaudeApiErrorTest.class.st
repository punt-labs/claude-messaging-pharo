"
Tests for the ClaudeApiError hierarchy — factory method, retryability, exception handling, and graceful degradation on malformed input.
"
Class {
	#name : 'ClaudeApiErrorTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Errors-Tests',
	#package : 'Claude-Messaging-Errors-Tests'
}

{ #category : 'helpers' }
ClaudeApiErrorTest >> errorJsonWithMessage: aString [
	| pre post |
	pre := String new writeStream.
	pre nextPutAll: '{"error": {"type": "api_error", "message": "'.
	pre nextPutAll: aString.
	post := String new writeStream.
	post nextPutAll: '"}}'.
	^ pre contents , post contents
]

{ #category : 'tests' }
ClaudeApiErrorTest >> testCatchBaseClass [
	| caught |
	caught := false.
	[ (ClaudeApiError fromStatusCode: 401 json: (self errorJsonWithMessage: 'bad key') requestId: 'req_b') signal ]
		on: ClaudeApiError
		do: [ :e |
			caught := true.
			self assert: e class equals: ClaudeAuthError ].
	self assert: caught
]

{ #category : 'tests' }
ClaudeApiErrorTest >> testFromStatusCode401 [
	| error |
	error := ClaudeApiError fromStatusCode: 401 json: (self errorJsonWithMessage: 'Invalid API key') requestId: 'req_auth'.
	self assert: error class equals: ClaudeAuthError.
	self assert: error statusCode equals: 401.
	self assert: error message equals: 'Invalid API key'.
	self assert: error requestId equals: 'req_auth'
]

{ #category : 'tests' }
ClaudeApiErrorTest >> testFromStatusCode402 [
	| error |
	error := ClaudeApiError fromStatusCode: 402 json: (self errorJsonWithMessage: 'Billing issue') requestId: 'req_billing'.
	self assert: error class equals: ClaudeBillingError.
	self assert: error statusCode equals: 402
]

{ #category : 'tests' }
ClaudeApiErrorTest >> testFromStatusCode403 [
	| error |
	error := ClaudeApiError fromStatusCode: 403 json: (self errorJsonWithMessage: 'Forbidden') requestId: 'req_perm'.
	self assert: error class equals: ClaudePermissionError.
	self assert: error statusCode equals: 403
]

{ #category : 'tests' }
ClaudeApiErrorTest >> testFromStatusCode404 [
	| error |
	error := ClaudeApiError fromStatusCode: 404 json: (self errorJsonWithMessage: 'Not found') requestId: 'req_nf'.
	self assert: error class equals: ClaudeNotFoundError.
	self assert: error statusCode equals: 404
]

{ #category : 'tests' }
ClaudeApiErrorTest >> testFromStatusCode408 [
	| error |
	error := ClaudeApiError fromStatusCode: 408 json: (self errorJsonWithMessage: 'Request timeout') requestId: 'req_to'.
	self assert: error class equals: ClaudeTimeoutError.
	self assert: error statusCode equals: 408
]

{ #category : 'tests' }
ClaudeApiErrorTest >> testFromStatusCode429 [
	| error |
	error := ClaudeApiError fromStatusCode: 429 json: (self errorJsonWithMessage: 'Rate limited') requestId: 'req_rl'.
	error retryAfter: 30.
	self assert: error class equals: ClaudeRateLimitError.
	self assert: error statusCode equals: 429.
	self assert: error retryAfter equals: 30
]

{ #category : 'tests' }
ClaudeApiErrorTest >> testFromStatusCode500 [
	| error |
	error := ClaudeApiError fromStatusCode: 500 json: (self errorJsonWithMessage: 'Internal error') requestId: 'req_se'.
	self assert: error class equals: ClaudeServerError.
	self assert: error statusCode equals: 500
]

{ #category : 'tests' }
ClaudeApiErrorTest >> testFromStatusCode504 [
	| error |
	error := ClaudeApiError fromStatusCode: 504 json: (self errorJsonWithMessage: 'Gateway timeout') requestId: 'req_gw'.
	self assert: error class equals: ClaudeTimeoutError.
	self assert: error statusCode equals: 504
]

{ #category : 'tests' }
ClaudeApiErrorTest >> testFromStatusCode529 [
	| error |
	error := ClaudeApiError fromStatusCode: 529 json: (self errorJsonWithMessage: 'Overloaded') requestId: 'req_ol'.
	self assert: error class equals: ClaudeOverloadedError.
	self assert: error statusCode equals: 529
]

{ #category : 'tests' }
ClaudeApiErrorTest >> testFromStatusCodeUnknown [
	| error |
	error := ClaudeApiError fromStatusCode: 418 json: (self errorJsonWithMessage: 'I am a teapot') requestId: 'req_tea'.
	self assert: error class equals: ClaudeApiError.
	self assert: error statusCode equals: 418.
	self assert: error message equals: 'I am a teapot'
]

{ #category : 'tests' }
ClaudeApiErrorTest >> testIsRetryable [
	#(408 429 500 529) do: [ :code |
		| error |
		error := ClaudeApiError fromStatusCode: code json: (self errorJsonWithMessage: 'test') requestId: 'req_r'.
		self assert: error isRetryable ].
	#(400 401 402 403 404 409) do: [ :code |
		| error |
		error := ClaudeApiError fromStatusCode: code json: (self errorJsonWithMessage: 'test') requestId: 'req_nr'.
		self deny: error isRetryable ]
]

{ #category : 'tests' }
ClaudeApiErrorTest >> testIsRetryableNilSafe [
	"Regression test for bead 8x5 round 3. Unknown SSE error.type strings
	fall back to the base ClaudeApiError class with statusCode = nil.
	isRetryable must return false in that case instead of crashing with
	DNU (receiver of >= is nil)."

	| payload err |
	payload := Dictionary newFromPairs: {
		'type'. 'error'.
		'error'. (Dictionary newFromPairs: {
			'type'. 'gremlin_error_type_never_seen'.
			'message'. 'unknown type' })
	}.
	err := ClaudeApiError fromSseErrorData: payload.
	self assert: err class equals: ClaudeApiError.
	self assert: err statusCode isNil.
	self deny: err isRetryable
]

{ #category : 'tests' }
ClaudeApiErrorTest >> testIsRetryableOnSseOriginError [
	"Regression test for bead 8x5 rounds 2 and 3. SSE-origin errors
	constructed via fromSseErrorData: must populate statusCode so
	isRetryable does not crash with DNU (receiver of >= is nil). Exercises
	both branches: overloaded_error is retryable, authentication_error is
	not. Hardens the round-2 test that only asserted the true branch."

	| retryable nonRetryable |
	retryable := ClaudeApiError fromSseErrorData: (Dictionary newFromPairs: {
		'type'. 'error'.
		'error'. (Dictionary newFromPairs: {
			'type'. 'overloaded_error'.
			'message'. 'test overload' })
	}).
	self assert: retryable class equals: ClaudeOverloadedError.
	self assert: retryable statusCode equals: 529.
	self assert: retryable message equals: 'test overload'.
	self assert: retryable isRetryable.

	nonRetryable := ClaudeApiError fromSseErrorData: (Dictionary newFromPairs: {
		'type'. 'error'.
		'error'. (Dictionary newFromPairs: {
			'type'. 'authentication_error'.
			'message'. 'bad key' })
	}).
	self assert: nonRetryable class equals: ClaudeAuthError.
	self assert: nonRetryable statusCode equals: 401.
	self deny: nonRetryable isRetryable
]

{ #category : 'tests' }
ClaudeApiErrorTest >> testMalformedJson [
	| error |
	error := ClaudeApiError fromStatusCode: 500 json: 'not valid json at all' requestId: 'req_mj'.
	self assert: error class equals: ClaudeServerError.
	self assert: error message equals: 'Unknown error'.
	self assert: error rawJson equals: 'not valid json at all'
]

{ #category : 'tests' }
ClaudeApiErrorTest >> testRequestIdInPrintOn [
	| error |
	error := ClaudeApiError fromStatusCode: 400 json: '{"error": {"message": "Bad request"}}' requestId: 'req-123'.
	
	self assert: error requestId equals: 'req-123'.
	self assert: (error printString includesSubstring: '[req-123]')
]

{ #category : 'tests' }
ClaudeApiErrorTest >> testSignalAndCatch [
	| caught |
	caught := false.
	[ (ClaudeApiError fromStatusCode: 401 json: (self errorJsonWithMessage: 'bad key') requestId: 'req_s') signal ]
		on: ClaudeAuthError
		do: [ :e | caught := true ].
	self assert: caught
]
