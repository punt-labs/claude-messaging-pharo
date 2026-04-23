"
Live end-to-end integration test for base64-inline PDF document
input. Issues a single sendMessage: call against api.anthropic.com
via `ClaudeMessagingPDFExample runOn: client` and asserts that the
response completed cleanly (stopReason #end_turn), carries non-empty
assistant text, and that the usage record shows inputTokens > 200 —
the server-computed proof that the PDF reached the model.

This test exists because PDF processing cannot be mock-verified.
The inputTokens count is populated by Anthropic's billing
infrastructure based on the actual content it processed. A client
that stripped the PDF on the wire would see the text-only token
count — for this prompt shape, ~50-80 tokens. A processed inline
PDF typically adds several hundred to a few thousand tokens
depending on page count and content density. The >200 threshold is
a loose lower bound chosen well above the text-only ceiling and
well below the processed-PDF typical range, so it catches content-
stripping regressions without flaking on pricing or parsing changes.

**Preconditions.** Requires an Anthropic API key, resolved by
`ClaudeSDKExampleSupport resolveClient` from either the OS keyring
(service `anthropic-api`, account `default`) or the
`ANTHROPIC_API_KEY` environment variable. When no key is present
the test skips via `self skip` — it does not fail on a key-less
image. The default suite (`ClaudeMessagingTestSuite suite`) excludes
this class by protocol; only `integrationSuite` includes it.

**Base64 inline vs URL source.** The Messages API supports both PDF
document sources, but URL-source PDFs require the
`document-url-2025-04-15` beta header. This test uses the base64-
inline path — no beta header, no external URL dependency. See
`ClaudeMessagingPDFExample examplePDFBase64` for the fixture
rationale.

**External-infrastructure dependency.** An Anthropic API outage or
a regression in PDF handling can turn this test red without any
change on our side. Triage should distinguish upstream infra from a
local regression.

**No cleanup.** The request is stateless on our side — no server
resources are created, no named entries persist. Absence of an
`ensure:` block is intentional.

  ClaudePDFIntegrationTest buildSuite
  >>> a TestSuite

"
Class {
	#name : 'ClaudePDFIntegrationTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'running' }
ClaudePDFIntegrationTest >> defaultTimeLimit [
	"PDF processing drives a base64 decode, document parse, and
	 multimodal inference pass in addition to the normal text
	 generation. The default 10 s test timeout fires before a healthy
	 round-trip completes. 2 minutes matches ClaudeThinkingIntegrationTest
	 and ClaudeCitationsIntegrationTest."

	^ 2 minutes
]

{ #category : 'tests-integration' }
ClaudePDFIntegrationTest >> testPDFInputProcessedAgainstAnthropic [
	"Drive a sendMessage: call with a base64-inline PDF document against
	 api.anthropic.com and assert (a) the response completed cleanly
	 with stopReason = #end_turn, (b) the response carries non-empty
	 text, and (c) inputTokens exceeds 200 — the server-computed proof
	 that the PDF was received and processed. For this prompt shape, a
	 text-only equivalent is ~50-80 tokens; a processed inline PDF
	 typically adds several hundred to a few thousand tokens. The 200
	 threshold is loose enough to tolerate small fixtures and tight
	 enough to detect content-stripping.

	 Skips cleanly when no API key is present. No cleanup: the request
	 is stateless on our side."

	| client response |
	[ client := ClaudeSDKExampleSupport resolveClient ]
		on: Error do: [ :e | ^ self skip ].
	response := ClaudeMessagingPDFExample runOn: client.
	self
		assert: response stopReason = #end_turn
		description: 'server must complete response cleanly (stopReason #end_turn); got ' , response stopReason printString.
	self
		assert: response textContent isNotEmpty
		description: 'response must carry non-empty assistant text'.
	self
		assert: (response usage inputTokens ifNil: [ 0 ]) > 200
		description: 'inputTokens > 200 proves PDF was processed (text-only is ~50-80); got ' , response usage inputTokens printString
]
