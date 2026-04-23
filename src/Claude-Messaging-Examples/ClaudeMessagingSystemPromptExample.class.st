"
Demonstrate a constraining system prompt. Builds a
ClaudeMessageRequest whose `system` field instructs the model to end
every response with a specific verbatim marker (`MKR-%%%`). The
integration test asserts the marker is present in the server response,
which proves that the system prompt reached the model and was respected.

The marker approach is deliberately structural rather than semantic. A
haiku-form constraint or a tone constraint cannot be verified without
heuristics; an exact-substring marker is cheap, reliable, and falsifiable.
If the model skips the marker, the system prompt was ignored (or the
server dropped the field) and the test fails red.

This example uses `system:` (the plain-string form) rather than
`systemBlocks:` because there is no cache_control on this request;
caching is covered separately by `ClaudeMessagingPromptCachingExample`.

  ClaudeMessagingSystemPromptExample buildRequest model
  >>> 'claude-sonnet-4-6'

  ClaudeMessagingSystemPromptExample buildRequest maxTokens
  >>> 256

  ClaudeMessagingSystemPromptExample buildRequest system
  >>> 'You must end every response with the exact marker text MKR-%%%.'

  ClaudeMessagingSystemPromptExample buildRequest messages size
  >>> 1

"
Class {
	#name : 'ClaudeMessagingSystemPromptExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'building' }
ClaudeMessagingSystemPromptExample class >> buildRequest [
	"Build a ClaudeMessageRequest with a constraining system prompt.
	 The system prompt requires the model to end every response with
	 the verbatim marker text 'MKR-%%%'. The marker is structural --
	 a string-equality test on the response content either sees it or
	 does not -- and is the integration test's proof that the system
	 prompt reached the model."
	| req |
	req := ClaudeMessageRequest new.
	req model: ClaudeModel sonnet46.
	req maxTokens: 256.
	req system: 'You must end every response with the exact marker text MKR-%%%.'.
	req addUserMessage: 'What is 2 + 2?'.
	^ req
]

{ #category : 'private' }
ClaudeMessagingSystemPromptExample class >> resolveClient [
	"Resolve a live ClaudeClient via shared example support."
	^ ClaudeSDKExampleSupport resolveClient
]

{ #category : 'examples' }
ClaudeMessagingSystemPromptExample class >> run [
	"Send the example request using a resolved client and return the response."
	^ self runOn: self resolveClient
]

{ #category : 'examples' }
ClaudeMessagingSystemPromptExample class >> runOn: aClient [
	"Send the system-prompt example request using the given client and
	 return the response. The integration test asserts the response
	 text contains the marker configured by ``buildRequest``."
	^ aClient sendMessage: self buildRequest
]
