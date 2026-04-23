"
Demonstrate ``ClaudeRequestOptions`` fields that travel with every request but do not change the response shape. Sets ``metadata`` (a key/value dictionary used for server-side observability) and ``serviceTier`` (the priority tier the scheduler uses for the request).

Use this when you need to correlate requests with user sessions for billing/observability (``metadata``) or choose between service tiers. Most simple message sends do NOT need ``requestOptions`` — the defaults are correct for a single chat turn. Reach for these when you are operating a production service and need per-request telemetry, or when you want explicit control over the scheduling tier on a latency-sensitive path.

Valid ``serviceTier`` values are ``'auto'`` (the default — server picks the best tier) and ``'standard_only'`` (force the standard tier even when priority capacity is available). This example uses ``'auto'`` because it works on every account; ``'standard_only'`` is also valid but only interesting on accounts with provisioned priority throughput.

The response is a plain ``ClaudeMessage`` identical in shape to any other ``sendMessage:`` response — ``requestOptions`` does not alter the response body.

NOTE: the server echoes the requested tier back in ``usage.service_tier``, but ``ClaudeUsage`` does not currently parse that field (see ``ClaudeUsage class >> fromJson:``). The integration test asserts the request succeeds and the server returns a clean ``end_turn`` — proving the options cleared server validation — rather than probing an accessor that does not exist yet. When ``ClaudeUsage`` grows a ``serviceTier`` accessor, the integration test should be strengthened to assert the echo.

  ClaudeMessagingRequestOptionsExample buildRequest model
  >>> 'claude-sonnet-4-6'

  ClaudeMessagingRequestOptionsExample buildRequest maxTokens
  >>> 256

  ClaudeMessagingRequestOptionsExample buildRequest requestOptions serviceTier
  >>> 'auto'

  (ClaudeMessagingRequestOptionsExample buildRequest requestOptions metadata
    at: 'user_id')
  >>> 'sdk-test-user'

  ClaudeMessagingRequestOptionsExample buildRequest messages size
  >>> 1

Live end-to-end coverage lives in ``ClaudeRequestOptionsIntegrationTest``, which sends the request against api.anthropic.com and asserts the options cleared server-side validation.
"
Class {
	#name : 'ClaudeMessagingRequestOptionsExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'building' }
ClaudeMessagingRequestOptionsExample class >> buildRequest [
	"Build a request that sets two ClaudeRequestOptions fields:
	  - metadata: a dictionary echoed back in observability tooling
	    (e.g. to correlate requests with user sessions).
	  - serviceTier: the priority tier the server should use to
	    schedule generation. Valid values are 'auto' and
	    'standard_only' (per Anthropic's API — 'standard' alone
	    is rejected).
	 The integration test asserts that the request succeeds, proving
	 both options cleared server-side validation."
	| req |
	req := ClaudeMessageRequest new.
	req model: ClaudeModel sonnet46.
	req maxTokens: 256.
	req metadata: (Dictionary newFromPairs: { 'user_id'. 'sdk-test-user' }).
	req serviceTier: 'auto'.
	req addUserMessage: 'What is 2+2? Reply with just the number.'.
	^ req
]

{ #category : 'private' }
ClaudeMessagingRequestOptionsExample class >> resolveClient [
	"Resolve a live ClaudeClient via shared example support."
	^ ClaudeSDKExampleSupport resolveClient
]

{ #category : 'examples' }
ClaudeMessagingRequestOptionsExample class >> run [
	"Send the example request using a resolved client and return the response."
	^ self runOn: self resolveClient
]

{ #category : 'examples' }
ClaudeMessagingRequestOptionsExample class >> runOn: aClient [
	"Send the request-options example using the given client and
	 return the response. The integration test asserts stopReason,
	 request success, and that the request cleared server validation."
	^ aClient sendMessage: self buildRequest
]
