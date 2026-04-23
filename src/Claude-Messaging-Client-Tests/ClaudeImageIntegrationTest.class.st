"
Live end-to-end integration test for URL-source image input. Issues
a single sendMessage: call against api.anthropic.com via
`ClaudeMessagingImageExample runOn: client` and asserts that the
response completed cleanly (stopReason #end_turn), carries non-empty
assistant text, and that the usage record shows inputTokens > 200 —
the server-computed proof that the image reached the model.

This test exists because image processing cannot be mock-verified.
The inputTokens count is populated by Anthropic's billing
infrastructure based on the actual content it processed. A client
that stripped the image on the wire would see the text-only token
count — for this prompt shape, ~50-80 tokens. A processed image
typically adds hundreds more. The >200 threshold is a loose lower
bound chosen well above the text-only ceiling and well below the
processed-image typical range, so it catches content-stripping
regressions without flaking on pricing or compression changes.

**Preconditions.** Requires an Anthropic API key, resolved by
`ClaudeSDKExampleSupport resolveClient` from either the OS keyring
(service `anthropic-api`, account `default`) or the
`ANTHROPIC_API_KEY` environment variable. When no key is present
the test skips via `self skip` — it does not fail on a key-less
image. The default suite (`ClaudeMessagingTestSuite suite`) excludes
this class by protocol; only `integrationSuite` includes it.

**URL-source vs base64 for images.** The Messages API natively
supports URL-source images without a beta header. The server fetches
the image from the URL. See `ClaudeMessagingImageExample exampleImageUrl`
for the URL choice rationale.

**External-infrastructure dependency.** Three components can turn
this test red without any change on our side: an Anthropic API
outage, a regression in image handling, or the image URL being
retired by Wikimedia. Triage should distinguish upstream infra from
a local regression. If the URL 404s, that is a follow-up bead to
update `exampleImageUrl`, NOT a test bug.

**No cleanup.** The request is stateless on our side — no server
resources are created, no named entries persist. Absence of an
`ensure:` block is intentional.

  ClaudeImageIntegrationTest buildSuite
  >>> a TestSuite

"
Class {
	#name : 'ClaudeImageIntegrationTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'running' }
ClaudeImageIntegrationTest >> defaultTimeLimit [
	"Image processing drives a URL fetch, image decode, and multimodal
	 inference pass in addition to the normal text generation. The
	 default 10 s test timeout fires before a healthy round-trip
	 completes. 2 minutes matches ClaudeThinkingIntegrationTest and
	 ClaudeCitationsIntegrationTest."

	^ 2 minutes
]

{ #category : 'tests-integration' }
ClaudeImageIntegrationTest >> testImageInputProcessedAgainstAnthropic [
	"Drive a sendMessage: call with a URL-source image against
	 api.anthropic.com and assert (a) the response completed cleanly
	 with stopReason = #end_turn, (b) the response carries non-empty
	 text, and (c) inputTokens exceeds 200 — the server-computed proof
	 that the image was received and processed. For this prompt shape,
	 a text-only equivalent is ~50-80 tokens; a processed image
	 typically adds hundreds more. If the image were silently dropped
	 we would see the text-only count.

	 Skips cleanly when no API key is present. No cleanup: the request
	 is stateless on our side."

	| client response |
	[ client := ClaudeSDKExampleSupport resolveClient ]
		on: Error do: [ :e | ^ self skip ].
	response := ClaudeMessagingImageExample runOn: client.
	self
		assert: response stopReason = #end_turn
		description: 'server must complete response cleanly (stopReason #end_turn); got ' , response stopReason printString.
	self
		assert: response textContent isNotEmpty
		description: 'response must carry non-empty assistant text'.
	self
		assert: (response usage inputTokens ifNil: [ 0 ]) > 200
		description: 'inputTokens > 200 proves image was processed (text-only is ~50-80); got ' , response usage inputTokens printString
]
