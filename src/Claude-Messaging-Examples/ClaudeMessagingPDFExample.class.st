"
Demonstrate base64-inline PDF document input. Builds a
ClaudeMessageRequest whose user turn carries a ClaudeDocumentBlock
constructed from a base64-encoded minimal 1-page PDF, plus a
ClaudeTextBlock asking the model to summarize the PDF. The response
carries assistant text and a usage record whose inputTokens count
reflects the processed document.

Base64-inline PDF document blocks are natively supported by the
Messages API. The server decodes the PDF from the inline data, feeds
it into the model, and charges inputTokens against both the text and
the PDF. For this prompt shape, a text-only equivalent is ~50-80
tokens; a processed inline PDF typically adds several hundred to a
few thousand tokens depending on page count and content density,
exceeding the >200 assertion threshold by a wide margin. The delta
is the server-computed proof that the PDF reached the model's
context. (Hard numbers live in the test-artifact result log, not in
docstrings, so comments don't drift when token pricing or PDF
parsing changes.)

**Why base64 inline, not URL.** URL-source PDFs require the
`document-url-2025-04-15` beta header on the request. The header is
easy to add but widens scope beyond ""does the PDF content-block type
round-trip through the Messages API?"" The base64-inline path has no
beta dependency and is the documented default for this example.

**Fixture size.** The embedded PDF is 615 bytes raw (820 base64
chars) carrying a single line of visible text (""Claude Messaging SDK
integration test fixture.""). Deliberately minimal — a larger
document would cost more inputTokens but also takes longer to round-
trip. This size is small enough to sit in the source comfortably and
large enough that the server-computed inputTokens delta is
unambiguous and well above the >200 assertion threshold.

**Prompt design.** The question asks for a single-sentence summary so
the response is cheap and the stopReason is predictable (#end_turn
rather than #max_tokens). The content of the summary is irrelevant to
the integration test: the test proves the server received and
processed the PDF, not that it summarized it correctly.

  ClaudeMessagingPDFExample buildRequest model
  >>> 'claude-sonnet-4-6'

  ClaudeMessagingPDFExample buildRequest maxTokens
  >>> 512

  ClaudeMessagingPDFExample buildRequest messages first content first type
  >>> 'document'

  ClaudeMessagingPDFExample buildRequest messages first content size
  >>> 2

  ClaudeMessagingPDFExample examplePDFBase64 size
  >>> 820

"
Class {
	#name : 'ClaudeMessagingPDFExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'building' }
ClaudeMessagingPDFExample class >> buildRequest [
	"Build a ClaudeMessageRequest carrying a base64-inline PDF document
	 block and a one-line text prompt asking the model to describe the
	 PDF contents. The server decodes the PDF, feeds it into the model,
	 and returns a response whose inputTokens count proves the PDF was
	 processed.

	 Base64-inline PDFs are natively supported by the Messages API. URL-
	 source PDFs would require the `document-url-2025-04-15` beta header,
	 which is out of scope for this example — base64 inline is cleaner
	 and eliminates external dependency."

	| req documentBlock textBlock |
	req := ClaudeMessageRequest new.
	req model: ClaudeModel sonnet46.
	req maxTokens: 512.
	documentBlock := ClaudeDocumentBlock fromBase64: self examplePDFBase64.
	textBlock := ClaudeTextBlock
		text: 'Summarize the contents of this PDF in one sentence.'.
	req addUserContent: { documentBlock. textBlock }.
	^ req
]

{ #category : 'building' }
ClaudeMessagingPDFExample class >> examplePDFBase64 [
	"A minimal 1-page PDF (615 bytes raw, 820 base64 chars) carrying a
	 single line of visible text ('Claude Messaging SDK integration test
	 fixture.'). Generated deterministically and embedded as a literal
	 so the example has no file-system or network dependency.

	 The PDF is deliberately small — a real-world document would cost
	 more inputTokens but also takes longer to fetch and parse. Even
	 this minimal fixture exceeds the text-only baseline (~50-80 tokens
	 for this prompt shape) by a wide margin — a processed inline PDF
	 typically adds several hundred to a few thousand tokens, well
	 above the >200 assertion threshold. That delta is the stable
	 server-computed proof the PDF reached the model's context."

	^ 'JVBERi0xLjQKMSAwIG9iago8PCAvVHlwZSAvQ2F0YWxvZyAvUGFnZXMgMiAwIFIgPj4KZW5kb2JqCjIgMCBvYmoKPDwgL1R5cGUgL1BhZ2VzIC9LaWRzIFszIDAgUl0gL0NvdW50IDEgPj4KZW5kb2JqCjMgMCBvYmoKPDwgL1R5cGUgL1BhZ2UgL1BhcmVudCAyIDAgUiAvTWVkaWFCb3ggWzAgMCA2MTIgNzkyXSAvQ29udGVudHMgNCAwIFIgL1Jlc291cmNlcyA8PCAvRm9udCA8PCAvRjEgNSAwIFIgPj4gPj4gPj4KZW5kb2JqCjQgMCBvYmoKPDwgL0xlbmd0aCA4NyA+PgpzdHJlYW0KQlQKL0YxIDE4IFRmCjcyIDcyMCBUZAooQ2xhdWRlIE1lc3NhZ2luZyBTREsgaW50ZWdyYXRpb24gdGVzdCBmaXh0dXJlLikgVGoKRVQKZW5kc3RyZWFtCmVuZG9iago1IDAgb2JqCjw8IC9UeXBlIC9Gb250IC9TdWJ0eXBlIC9UeXBlMSAvQmFzZUZvbnQgL0hlbHZldGljYSA+PgplbmRvYmoKeHJlZgowIDYKMDAwMDAwMDAwMCA2NTUzNSBmCjAwMDAwMDAwMTAgMDAwMDAgbgowMDAwMDAwMDYwIDAwMDAwIG4KMDAwMDAwMDExMSAwMDAwMCBuCjAwMDAwMDAyMTIgMDAwMDAgbgowMDAwMDAwMzUwIDAwMDAwIG4KdHJhaWxlcgo8PCAvU2l6ZSA2IC9Sb290IDEgMCBSID4+CnN0YXJ0eHJlZgo0MTkKJSVFT0YK'
]

{ #category : 'private' }
ClaudeMessagingPDFExample class >> resolveClient [
	^ ClaudeSDKExampleSupport resolveClient
]

{ #category : 'examples' }
ClaudeMessagingPDFExample class >> run [
	"Send the example PDF-input request and return the response."
	^ self runOn: self resolveClient
]

{ #category : 'examples' }
ClaudeMessagingPDFExample class >> runOn: aClient [
	"Send the PDF-input request using the given client and return the
	 response. The response inputTokens will reflect the processed PDF:
	 a text-only equivalent of this prompt shape is ~50-80 tokens; a
	 processed inline PDF typically adds several hundred to a few
	 thousand tokens, well above the >200 assertion threshold."
	^ aClient sendMessage: self buildRequest
]
