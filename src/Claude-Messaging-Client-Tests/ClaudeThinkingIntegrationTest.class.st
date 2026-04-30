"
Live end-to-end integration test for extended thinking. Issues a
single sendMessage: call against api.anthropic.com via
`ClaudeMessagingThinkingExample runOn: client` and asserts that the
response content includes at least one ClaudeThinkingBlock with a
non-empty server-generated signature and non-empty thinking content.

This test exists because thinking-block generation cannot be mock-
verified. The thinking content and its cryptographic signature are
populated by Anthropic's infrastructure, not by our client. Only a
live round-trip proves that the `thinking` parameter we emit on the
request actually activates the feature, that the model produces a
thinking block for the configured budget, and that the signature is
well-formed enough to round-trip in follow-up requests.

**Preconditions.** Requires an Anthropic API key, resolved by
`ClaudeSDKExampleSupport resolveClient` from either the OS keyring
(service `anthropic-api`, account `default`) or the `ANTHROPIC_API_KEY`
environment variable. When no key is present the test skips via
`self skip` -- it does not fail on a key-less image. The default suite
(`ClaudeMessagingTestSuite suite`) excludes this class by protocol;
only `integrationSuite` includes it.

**Block-type filter uses isThinkingBlock.** `ClaudeContentBlock`
defines polymorphic predicates (`isTextBlock`, `isToolUseBlock`,
`isToolResultBlock`, `isMCPToolUseBlock`, `isMCPToolResultBlock`,
`isDocumentBlock`, `isThinkingBlock`) that callers use instead of
`isKindOf:`. See bead 1xgi.

**Signature cannot be faked.** The signature is a cryptographic
hash derived from the thinking content and server-side secrets. It
must be preserved verbatim when round-tripping the thinking block
in subsequent requests. A non-empty signature proves the server
actually generated the thinking block rather than the client
spoofing one on the wire.

**External-infrastructure dependency.** An Anthropic API outage or
a regression in the thinking feature can turn this test red without
any change on our side. Triage should distinguish upstream infra
from a local regression.

**No cleanup.** Thinking blocks are stateless on our side: no
server resources are created, no named entries persist. Absence of
an `ensure:` block is intentional.

  ClaudeThinkingIntegrationTest buildSuite
  >>> a TestSuite

"
Class {
	#name : 'ClaudeThinkingIntegrationTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'accessing' }
ClaudeThinkingIntegrationTest >> defaultTimeLimit [
	"Extended thinking generation drives a larger maxTokens budget and
	 the model spends additional compute producing chain-of-thought
	 before the final answer. The default 10 s test timeout fires
	 before a healthy round-trip completes. 2 minutes matches
	 ClaudeMCPIntegrationTest and ClaudeServerToolIntegrationTest."

	^ 2 minutes
]

{ #category : 'tests-integration' }
ClaudeThinkingIntegrationTest >> testThinkingBlockReturnedAgainstAnthropic [
	"Drive a sendMessage: call with extended thinking enabled against
	 api.anthropic.com and assert that the response content includes at
	 least one ClaudeThinkingBlock whose signature is non-empty and
	 whose thinking content is non-empty. Both fields are server-
	 computed; the client cannot fabricate either.

	 Skips cleanly when no API key is present. No cleanup: thinking
	 blocks are stateless on our side. See 1xgi — filter uses the
	 polymorphic isThinkingBlock predicate rather than isKindOf:."

	| client response thinkingBlocks first |
	[ client := ClaudeSDKExampleSupport resolveClient ]
		on: Error do: [ :e | ^ self skip ].
	response := ClaudeMessagingThinkingExample runOn: client.
	thinkingBlocks := response content select: [ :b | b isThinkingBlock ].
	self
		assert: thinkingBlocks isNotEmpty
		description: 'response must contain at least one server-generated thinking block'.
	first := thinkingBlocks first.
	"Server-generated cryptographic signature required for round-trip."
	self
		assert: (first signature isNotNil and: [ first signature isNotEmpty ])
		description: 'server-generated thinking signature must be non-empty'.
	"Server-generated chain-of-thought content."
	self
		assert: (first thinking isNotNil and: [ first thinking isNotEmpty ])
		description: 'server-generated thinking content must be non-empty'
]
