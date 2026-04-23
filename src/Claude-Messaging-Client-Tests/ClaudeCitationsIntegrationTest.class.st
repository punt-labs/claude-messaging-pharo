"
Live end-to-end integration test for document citations. Issues a
single sendMessage: call against api.anthropic.com via
`ClaudeMessagingCitationsExample runOn: client` and asserts that at
least one response ClaudeTextBlock carries a non-empty `citations`
collection whose first entry has non-empty `citedText` and non-nil
`documentIndex`.

This test exists because citation generation cannot be mock-verified.
The citation fields (`citedText`, `documentIndex`, `startCharIndex`,
`endCharIndex`) are populated by Anthropic's infrastructure, which
extracts the cited excerpt from our input document and records its
character offsets. Only a live round-trip proves that the
`citations: {enabled: true}` marker we emit on the user document
actually activates the feature, that the server extracts an excerpt
that is present in our document, and that the server assigns a valid
document index.

**Preconditions.** Requires an Anthropic API key, resolved by
`ClaudeSDKExampleSupport resolveClient` from either the OS keyring
(service `anthropic-api`, account `default`) or the `ANTHROPIC_API_KEY`
environment variable. When no key is present the test skips via
`self skip` -- it does not fail on a key-less image. The default suite
(`ClaudeMessagingTestSuite suite`) excludes this class by protocol;
only `integrationSuite` includes it.

**citedText cannot be faked.** The server extracts the cited excerpt
from the raw document bytes we sent. A client that spoofed a
citation on the wire would need to predict server behaviour end-to-
end; a non-empty `citedText` proves that the server read our
document and chose a span to cite.

**documentIndex is server-assigned.** The index references the
position of the cited document in the user turn's content array. A
non-nil documentIndex proves the server correctly tracked the input
position through the citation-extraction pipeline.

**External-infrastructure dependency.** An Anthropic API outage or a
regression in citation extraction can turn this test red without any
change on our side. Triage should distinguish upstream infra from a
local regression.

**No cleanup.** Citations are stateless on our side: no server
resources are created, no named entries persist. Absence of an
`ensure:` block is intentional.

  ClaudeCitationsIntegrationTest buildSuite
  >>> a TestSuite

"
Class {
	#name : 'ClaudeCitationsIntegrationTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'running' }
ClaudeCitationsIntegrationTest >> defaultTimeLimit [
	"Citation extraction drives an additional pass over the input
	 document during generation. The default 10 s test timeout fires
	 before a healthy round-trip completes. 2 minutes matches
	 ClaudeMCPIntegrationTest and ClaudeServerToolIntegrationTest."

	^ 2 minutes
]

{ #category : 'tests-integration' }
ClaudeCitationsIntegrationTest >> testCitationsReturnedAgainstAnthropic [
	"Drive a sendMessage: call with a citations-enabled user document
	 against api.anthropic.com and assert that at least one response
	 text block carries non-empty citations, that the first citation
	 has non-empty citedText, and that its documentIndex is non-nil.
	 All three fields are server-computed; the client cannot fabricate
	 any of them.

	 Skips cleanly when no API key is present. No cleanup: citations
	 are stateless on our side."

	| client response textBlocksWithCitations firstCitation |
	[ client := ClaudeSDKExampleSupport resolveClient ]
		on: Error do: [ :e | ^ self skip ].
	response := ClaudeMessagingCitationsExample runOn: client.
	textBlocksWithCitations := response content select: [ :b |
		b isTextBlock
			and: [ b citations notNil
			and: [ b citations isNotEmpty ] ] ].
	self
		assert: textBlocksWithCitations isNotEmpty
		description: 'response must contain at least one text block with server-generated citations'.
	firstCitation := textBlocksWithCitations first citations first.
	"Server-extracted excerpt from our input document."
	self
		assert: (firstCitation citedText isNotNil
			and: [ firstCitation citedText isNotEmpty ])
		description: 'server-extracted citedText must be non-empty'.
	"Server-assigned reference to the input document's position."
	self
		assert: firstCitation documentIndex isNotNil
		description: 'server-populated documentIndex must be non-nil'
]
