"
Closes two real-timing gaps left by `ClaudeClientRetryTest`:

- The plain 429 retry path (no retry-after header) exercises the
  jitter-based backoff in `backoffDelay:retryAfter:`. The unit test
  `testRetryOnRateLimitError` proves the retry fires but does not
  bound elapsed time. This suite bounds it: a retried 429 must sleep
  at least the 375ms jitter floor on attempt 1.

- The client timeout path has no end-to-end coverage.
  `testTimeoutErrorHasStatusCode408` exercises the unit-level
  `signalTimeoutClosing:message:` helper, but no test drives a real
  wall-clock timeout through `sendMessage:` and asserts a
  `ClaudeTimeoutError` is signaled.

These tests live in the `tests-integration` protocol because their
assertions are real wall-clock `Delay wait` calls. The fast suite
excludes them via protocol filter; the CI slow-suite runs them.
No API key is required -- `ClaudeMockServer` serves the traffic
locally.

  ClaudeClientRetryIntegrationTest buildSuite run
  >>> 0 failures, 0 errors

"
Class {
	#name : 'ClaudeClientRetryIntegrationTest',
	#superclass : 'TestCase',
	#instVars : [
		'mockServer',
		'client'
	],
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'fixtures' }
ClaudeClientRetryIntegrationTest >> messageResponseJson [
	"A minimal success-message JSON body used to satisfy ClaudeMessage fromJson:
	 after the retry loop resolves or the mock slow path eventually answers."
	^ '{"id": "msg_test123", "type": "message", "role": "assistant", "content": [{"type": "text", "text": "Hello world"}], "model": "claude-sonnet-4-5-20250514", "stop_reason": "end_turn", "stop_sequence": null, "usage": {"input_tokens": 10, "output_tokens": 20}}'
]

{ #category : 'fixtures' }
ClaudeClientRetryIntegrationTest >> newParams [
	"A minimal ClaudeMessageRequest the mock server will accept as valid."
	| params |
	params := ClaudeMessageRequest new.
	params model: 'claude-sonnet-4-5-20250514'.
	params maxTokens: 1024.
	params addUserMessage: 'Hello'.
	^ params
]

{ #category : 'running' }
ClaudeClientRetryIntegrationTest >> setUp [
	super setUp.
	mockServer := ClaudeMockServer startOn: 0.
	client := ClaudeClient apiKey: 'test-key' baseUrl: 'http://localhost:', mockServer port printString timeout: 5.
	client maxRetries: 2
]

{ #category : 'running' }
ClaudeClientRetryIntegrationTest >> tearDown [
	mockServer stop.
	super tearDown
]

{ #category : 'tests-integration' }
ClaudeClientRetryIntegrationTest >> testJitterBasedBackoffFiresOnPlain429 [
	"A 429 with no retry-after header drives the jitter-based backoff path in
	 `backoffDelay: attempt retryAfter: nil`. Attempt 1 sleeps a random value in
	 [0.75 * 0.5s .. 1.25 * 0.5s] = [375ms .. 625ms]. We assert the floor with a
	 small CI slack so the check is tight without being flaky. Distinct from
	 testRetryOnOverloadedErrorWithRetryAfterHeader, which proves the header-based
	 path."
	| response elapsed start |
	mockServer respondTo: '/v1/messages' withSequence: {
		mockServer errorResponse: 429 message: 'Rate limit exceeded'.
		mockServer successResponse: self messageResponseJson }.
	start := DateAndTime now.
	response := client sendMessage: self newParams.
	elapsed := DateAndTime now - start.
	self
		assert: response id = 'msg_test123'
		description: 'retried request returned 200 content; id was ', response id printString.
	self
		assert: (mockServer requestCountFor: '/v1/messages') = 2
		description: 'exactly one retry fired; count was ', (mockServer requestCountFor: '/v1/messages') printString.
	self
		assert: elapsed asMilliSeconds >= 350
		description: 'jitter-based backoff slept at least the floor (375ms lower jitter minus small CI slack); got ', elapsed asMilliSeconds printString, 'ms'
]

{ #category : 'tests-integration' }
ClaudeClientRetryIntegrationTest >> testTimeoutRaisesClaudeTimeoutErrorAfterRealWallClockDelay [
	"The mock server delays 2s; the client timeout is 1s (ZnClient timeout is
	 in integer seconds). The HTTP read aborts before the response lands and
	 ClaudeClient signals ClaudeTimeoutError. We assert real wall-clock elapsed
	 sits near the configured 1s timeout: lower bound tight (800ms leaves
	 slack for scheduler startup), upper bound loose (3s tolerates CI scheduler
	 latency). Closes the end-to-end timeout coverage gap."
	| start elapsed |
	mockServer
		respondTo: '/v1/messages'
		withDelay: 2 seconds
		thenWith: (mockServer successResponse: self messageResponseJson).
	client timeout: 1. "ZnClient timeout: is in integer seconds"
	client maxRetries: 0. "One attempt only; no retry budget to mask the timeout."
	start := DateAndTime now.
	self
		should: [ client sendMessage: self newParams ]
		raise: ClaudeTimeoutError.
	elapsed := DateAndTime now - start.
	self
		assert: (elapsed asMilliSeconds between: 800 and: 3000)
		description: 'timeout fired near configured 1s (with CI scheduler slack up to 3s); got ', elapsed asMilliSeconds printString, 'ms'
]
