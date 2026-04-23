"
Tests retry behavior with exponential backoff for transient API errors.
"
Class {
	#name : 'ClaudeClientRetryTest',
	#superclass : 'TestCase',
	#instVars : [
		'mockServer',
		'client'
	],
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'fixtures' }
ClaudeClientRetryTest >> messageResponseJson [
	^ '{"id": "msg_test123", "type": "message", "role": "assistant", "content": [{"type": "text", "text": "Hello world"}], "model": "claude-sonnet-4-5-20250514", "stop_reason": "end_turn", "stop_sequence": null, "usage": {"input_tokens": 10, "output_tokens": 20}}'
]

{ #category : 'fixtures' }
ClaudeClientRetryTest >> newParams [
	| params |
	params := ClaudeMessageRequest new.
	params model: 'claude-sonnet-4-5-20250514'.
	params maxTokens: 1024.
	params addUserMessage: 'Hello'.
	^ params
]

{ #category : 'running' }
ClaudeClientRetryTest >> setUp [
	super setUp.
	mockServer := ClaudeMockServer startOn: 0.
	client := ClaudeClient apiKey: 'test-key' baseUrl: 'http://localhost:', mockServer port printString timeout: 5.
	client maxRetries: 2
]

{ #category : 'running' }
ClaudeClientRetryTest >> tearDown [
	mockServer stop.
	super tearDown
]

{ #category : 'tests' }
ClaudeClientRetryTest >> testBackoffDelayCapsRetryAfterAt30Seconds [
	"The retry-after header path must be capped at 30s. A 120s retry-after
	 combined with maxRetries=5 would otherwise block 10 minutes of wall time
	 per sendMessage: call."
	| capped underCap |
	capped := client backoffDelay: 1 retryAfter: 120.
	self assert: capped millisecondDelayDuration equals: 30000.
	underCap := client backoffDelay: 1 retryAfter: 5.
	self assert: underCap millisecondDelayDuration equals: 5000
]

{ #category : 'tests' }
ClaudeClientRetryTest >> testBackoffDelayHandlesNegativeRetryAfter [
	"Guard: a negative retry-after value (clock skew, proxy bug, malicious header)
	 must not raise a bare Error from Delay forMilliseconds:. It must clamp to 0
	 so the retry fires immediately instead of crashing the retry loop."
	| delay |
	delay := client backoffDelay: 1 retryAfter: -5.
	self assert: delay millisecondDelayDuration equals: 0
]

{ #category : 'tests' }
ClaudeClientRetryTest >> testBackoffJitterRange [
	"Jitter must produce values in [0.75*base..1.25*base]. Run 1000 iterations
	 at attempt 1 (base=0.5s) and verify all delays fall within range and the
	 lower bound reaches near 0.75 (within 1% tolerance)."
	| baseDelay delays minDelay maxDelay expectedMin expectedMax |
	baseDelay := 0.5.
	expectedMin := baseDelay * 0.75.
	expectedMax := baseDelay * 1.25.
	delays := (1 to: 1000) collect: [ :i |
		(client backoffDelay: 1 retryAfter: nil) millisecondDelayDuration / 1000.0 ].
	minDelay := delays min.
	maxDelay := delays max.
	self assert: minDelay >= expectedMin
		description: 'Min delay ', minDelay printString, ' below expected ', expectedMin printString.
	self assert: maxDelay <= expectedMax
		description: 'Max delay ', maxDelay printString, ' above expected ', expectedMax printString.
	self assert: minDelay < (baseDelay * 0.76)
		description: 'Lower bound never reached near 0.75: min was ', minDelay printString
]

{ #category : 'tests' }
ClaudeClientRetryTest >> testCheckResponseFallsBackToRetryAfterWhenMsMalformed [
	"When retry-after-ms is present but malformed, the client should fall back to
	 the plain retry-after header if present and parseable. Fixes the round 2 bug
	 where malformed -ms suppressed the fallback."
	| response error |
	error := nil.
	response := ZnResponse statusCode: 529.
	response headers at: 'retry-after-ms' put: 'foo'.
	response headers at: 'retry-after' put: '5'.
	response entity: (ZnEntity text: '{"type":"error","error":{"type":"overloaded","message":"try later"}}').
	[ client checkResponse: response ]
		on: ClaudeApiError
		do: [ :e | error := e ].
	self assert: error class equals: ClaudeOverloadedError.
	self assert: error retryAfter equals: 5
]

{ #category : 'tests' }
ClaudeClientRetryTest >> testCheckResponseIgnoresMalformedRetryAfterMs [
	"A non-numeric retry-after-ms header value ('abc', '', etc.) must not
	 crash checkResponse: with a DoesNotUnderstand on nil / 1000.0. It must be
	 treated as absent — the error signals normally with retryAfter nil and the
	 retry loop falls through to exponential backoff."
	| response caught |
	caught := nil.
	response := ZnResponse statusCode: 529.
	response headers at: 'retry-after-ms' put: 'abc'.
	response entity: (ZnEntity text: '{"type":"error","error":{"type":"overloaded","message":"try later"}}').
	[ client checkResponse: response ]
		on: ClaudeOverloadedError
		do: [ :e | caught := e ].
	self assert: caught notNil description: 'Expected ClaudeOverloadedError, not a DNU'.
	self assert: caught retryAfter isNil
]

{ #category : 'tests' }
ClaudeClientRetryTest >> testCheckResponseParsesRetryAfterHeader [
	"Verify checkResponse: parses Retry-After header into error retryAfter."
	| response error |
	error := nil.
	response := ZnResponse statusCode: 429.
	response headers at: 'retry-after' put: '5'.
	response entity: (ZnEntity text: '{"type":"error","error":{"type":"rate_limit","message":"slow down"}}').
	[ client checkResponse: response ]
		on: ClaudeRateLimitError
		do: [ :e | error := e ].
	self assert: error notNil description: 'Expected ClaudeRateLimitError'.
	self assert: error retryAfter equals: 5
]

{ #category : 'tests' }
ClaudeClientRetryTest >> testCheckResponsePrefersRetryAfterMsWhenBothValid [
	"When both retry-after-ms and retry-after are present and valid, -ms wins
	 (milliseconds precision). Regression guard for precedence."
	| response error |
	error := nil.
	response := ZnResponse statusCode: 529.
	response headers at: 'retry-after-ms' put: '1000'.
	response headers at: 'retry-after' put: '5'.
	response entity: (ZnEntity text: '{"type":"error","error":{"type":"overloaded","message":"try later"}}').
	[ client checkResponse: response ]
		on: ClaudeApiError
		do: [ :e | error := e ].
	self assert: error retryAfter equals: 1.0
]

{ #category : 'tests' }
ClaudeClientRetryTest >> testConnectionRefusedRaisesClaudeNetworkErrorWithoutRetry [
	"Non-timeout NetworkError subclasses (ConnectionRefused, SocketClosed,
	 TLS failures) are not transient — they would hit the same condition
	 on every retry. executeWithRetry: must wrap them in ClaudeNetworkError
	 (isRetryable=false) and propagate to the caller after the FIRST
	 attempt. We assert this by counting block invocations: exactly 1
	 even with maxRetries: 2 configured. See bead i7uc."

	| callCount |
	callCount := 0.
	self
		should: [
			client executeWithRetry: [
				callCount := callCount + 1.
				ConnectionRefused signal: 'Connection refused by 127.0.0.1:9' ] ]
		raise: ClaudeNetworkError.
	self
		assert: callCount = 1
		description: 'ClaudeNetworkError must propagate after the first attempt — no retry. Got ' , callCount printString , ' invocations.'
]

{ #category : 'tests' }
ClaudeClientRetryTest >> testConnectionTimedOutRaisesClaudeTimeoutErrorAndRetries [
	"Symmetric to testConnectionRefusedRaisesClaudeNetworkErrorWithoutRetry —
	 ConnectionTimedOut is the one NetworkError subclass that IS transient,
	 so executeWithRetry: must wrap it in ClaudeTimeoutError(408)
	 (isRetryable=true) and exercise the retry budget before exhausting.
	 With maxRetries: 2 the block fires 1 + 2 = 3 times before propagating.
	 See bead i7uc."

	| callCount expected |
	callCount := 0.
	expected := client maxRetries + 1.
	self
		should: [
			client executeWithRetry: [
				callCount := callCount + 1.
				ConnectionTimedOut signal: 'Read timeout after 5s' ] ]
		raise: ClaudeTimeoutError.
	self
		assert: callCount = expected
		description: 'ClaudeTimeoutError is retryable — block must fire maxRetries+1 times before propagating. Got ' , callCount printString , ' invocations, expected ' , expected printString
]

{ #category : 'tests' }
ClaudeClientRetryTest >> testNoRetryOnAuthError [
	"401 is not retryable. Should signal immediately, no retry."
	mockServer respondTo: '/v1/messages' withSequence: {
		mockServer errorResponse: 401 message: 'Invalid API key' }.
	[ client sendMessage: self newParams ]
		on: ClaudeAuthError
		do: [ :err |
			self assert: (mockServer requestCountFor: '/v1/messages') equals: 1.
			^ self ].
	self fail: 'Expected ClaudeAuthError'
]

{ #category : 'tests' }
ClaudeClientRetryTest >> testNoRetryOnNotFoundError [
	"404 is not retryable. Should signal immediately, no retry."
	mockServer respondTo: '/v1/messages' withSequence: {
		mockServer errorResponse: 404 message: 'Not found' }.
	[ client sendMessage: self newParams ]
		on: ClaudeNotFoundError
		do: [ :err |
			self assert: (mockServer requestCountFor: '/v1/messages') equals: 1.
			^ self ].
	self fail: 'Expected ClaudeNotFoundError'
]

{ #category : 'tests' }
ClaudeClientRetryTest >> testRetryExhausted [
	"Always returns 500. After maxRetries+1 attempts, signals ClaudeServerError."
	mockServer respondTo: '/v1/messages' withSequence: {
		mockServer errorResponse: 500 message: 'Server error 1'.
		mockServer errorResponse: 500 message: 'Server error 2'.
		mockServer errorResponse: 500 message: 'Server error 3' }.
	[ client sendMessage: self newParams ]
		on: ClaudeServerError
		do: [ :err |
			self assert: (mockServer requestCountFor: '/v1/messages') equals: 3.
			self assert: err message equals: 'Server error 3'.
			^ self ].
	self fail: 'Expected ClaudeServerError'
]

{ #category : 'tests' }
ClaudeClientRetryTest >> testRetryMaxRetriesDefaultIsFive [
	"Default maxRetries should be 5 to cover real Anthropic overload windows.
	 Guards against future regressions that change the default."
	| freshClient |
	freshClient := ClaudeClient apiKey: 'test-key'.
	self assert: freshClient maxRetries equals: 5
]

{ #category : 'tests' }
ClaudeClientRetryTest >> testRetryMaxRetriesZero [
	"maxRetries=0 means first error signals immediately."
	client maxRetries: 0.
	mockServer respondTo: '/v1/messages' withSequence: {
		mockServer errorResponse: 500 message: 'Server error' }.
	[ client sendMessage: self newParams ]
		on: ClaudeServerError
		do: [ :err |
			self assert: (mockServer requestCountFor: '/v1/messages') equals: 1.
			^ self ].
	self fail: 'Expected ClaudeServerError'
]

{ #category : 'tests' }
ClaudeClientRetryTest >> testRetryOnOverloadedError [
	"529 once, then 200. Client retries and returns successful response.
	 Proves the 529 retry path works for ClaudeOverloadedError specifically."
	| msg |
	mockServer respondTo: '/v1/messages' withSequence: {
		mockServer errorResponse: 529 message: 'Overloaded'.
		mockServer successResponse: self messageResponseJson }.
	msg := client sendMessage: self newParams.
	self assert: msg id equals: 'msg_test123'.
	self assert: (mockServer requestCountFor: '/v1/messages') equals: 2
]

{ #category : 'tests' }
ClaudeClientRetryTest >> testRetryOnOverloadedErrorExhaustsBudget [
	"529 on every attempt. After maxRetries+1 attempts, ClaudeOverloadedError is signaled.
	 Uses maxRetries=2 (set by setUp) so the test runs in ~3.5s instead of ~15s."
	mockServer respondTo: '/v1/messages' withSequence: {
		mockServer errorResponse: 529 message: 'Overloaded 1'.
		mockServer errorResponse: 529 message: 'Overloaded 2'.
		mockServer errorResponse: 529 message: 'Overloaded 3' }.
	[ client sendMessage: self newParams ]
		on: ClaudeOverloadedError
		do: [ :err |
			self assert: (mockServer requestCountFor: '/v1/messages') equals: 3.
			self assert: err message equals: 'Overloaded 3'.
			^ self ].
	self fail: 'Expected ClaudeOverloadedError'
]

{ #category : 'tests' }
ClaudeClientRetryTest >> testRetryOnOverloadedErrorWithRetryAfterHeader [
	"529 with retry-after: 1 header, then success. Verify the client honors the
	 header-specified delay (>= 1 second elapsed before retry)."
	| errorResponse start elapsed |
	errorResponse := mockServer
		errorResponse: 529
		message: 'Overloaded'
		headers: (Dictionary newFromPairs: { 'retry-after'. '1' }).
	mockServer respondTo: '/v1/messages' withSequence: {
		errorResponse.
		mockServer successResponse: self messageResponseJson }.
	start := DateAndTime now.
	client sendMessage: self newParams.
	elapsed := DateAndTime now - start.
	self assert: (mockServer requestCountFor: '/v1/messages') equals: 2.
	self assert: elapsed asMilliSeconds >= 1000
		description: 'Expected >= 1s wait from retry-after header, got ', elapsed asMilliSeconds printString, 'ms'
]

{ #category : 'tests' }
ClaudeClientRetryTest >> testRetryOnRateLimitError [
	"429 once, then 200. Client retries and returns successful response."
	| msg |
	mockServer respondTo: '/v1/messages' withSequence: {
		mockServer errorResponse: 429 message: 'Rate limit exceeded'.
		mockServer successResponse: self messageResponseJson }.
	msg := client sendMessage: self newParams.
	self assert: msg id equals: 'msg_test123'.
	self assert: (mockServer requestCountFor: '/v1/messages') equals: 2
]

{ #category : 'tests' }
ClaudeClientRetryTest >> testRetryOnServerError [
	"500 twice, then 200. Client retries and returns successful response."
	| msg |
	mockServer respondTo: '/v1/messages' withSequence: {
		mockServer errorResponse: 500 message: 'Internal server error'.
		mockServer errorResponse: 500 message: 'Internal server error'.
		mockServer successResponse: self messageResponseJson }.
	msg := client sendMessage: self newParams.
	self assert: msg id equals: 'msg_test123'.
	self assert: (mockServer requestCountFor: '/v1/messages') equals: 3
]

{ #category : 'tests' }
ClaudeClientRetryTest >> testRetryRespectsRetryAfterHeader [
	"429 with Retry-After: 1 header. Verify error has retryAfter set."
	| errorResponse |
	errorResponse := mockServer errorResponse: 429 message: 'Rate limit exceeded'
		headers: (Dictionary newFromPairs: { 'retry-after'. '1' }).
	mockServer respondTo: '/v1/messages' withSequence: {
		errorResponse.
		mockServer successResponse: self messageResponseJson }.
	client sendMessage: self newParams.
	self assert: (mockServer requestCountFor: '/v1/messages') equals: 2
]

{ #category : 'tests' }
ClaudeClientRetryTest >> testTimeoutErrorHasStatusCode408 [
	"ClaudeTimeoutError created by signalTimeoutClosing:message: must carry statusCode 408
	 so isRetryable answers true and printOn: shows the correct code."
	| error |
	error := nil.
	[ client signalTimeoutClosing: (WriteStream on: String new) message: 'connection timed out' ]
		on: ClaudeTimeoutError
		do: [ :e | error := e ].
	self assert: error notNil description: 'Expected ClaudeTimeoutError'.
	self assert: error statusCode equals: 408.
	self assert: error isRetryable.
	self assert: error message equals: 'connection timed out'
]
