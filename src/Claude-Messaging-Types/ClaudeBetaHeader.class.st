"
Catalog of known Anthropic beta identifiers.

Class-side messages return the wire String identifier for each known beta.
Use this class as a catalog of discoverable constants and pass the returned
Strings to ClaudeRequestOptions>>betas: or let ClaudeClient inject them on
your behalf (Files API, Skills API).

Using class-side selectors helps catch typos earlier in normal development:
an unknown selector will raise doesNotUnderstand: when the code is executed,
instead of sending an invalid beta String that may only fail as a server 400
at request time.

  ClaudeBetaHeader filesApi
  >>> 'files-api-2025-04-14'

  ClaudeBetaHeader skills
  >>> 'skills-2025-10-02'

  ClaudeBetaHeader pdfs
  >>> 'pdfs-2024-09-25'

  ClaudeBetaHeader allKnown size
  >>> 9

Idiomatic per-request usage via ClaudeRequestOptions (betas: still accepts
plain Strings --- the catalog is a discovery surface, not a new type):

  | opts |
  opts := ClaudeRequestOptions new
      betas: { ClaudeBetaHeader pdfs. ClaudeBetaHeader output128k };
      yourself.
  opts betaHeader
  >>> 'pdfs-2024-09-25,output-128k-2025-02-19'


"
Class {
	#name : 'ClaudeBetaHeader',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'betas' }
ClaudeBetaHeader class >> allKnown [
	"Answer an OrderedCollection of all known beta wire identifiers in documentation order. Useful for docs generation, validation, and test parity."
	^ OrderedCollection new
		add: self filesApi;
		add: self skills;
		add: self mcpClient;
		add: self pdfs;
		add: self output128k;
		add: self documentUrl;
		add: self context1m;
		add: self structuredOutputs;
		add: self interleavedThinking;
		add: self messageBatches;
		yourself
]

{ #category : 'betas' }
ClaudeBetaHeader class >> context1m [
	"Wire identifier for the 1M-token context window beta."
	^ 'context-1m-2025-08-07'
]

{ #category : 'betas' }
ClaudeBetaHeader class >> documentUrl [
	"Wire identifier for the URL-sourced document input beta."
	^ 'document-url-2025-04-15'
]

{ #category : 'betas' }
ClaudeBetaHeader class >> filesApi [
	"Wire identifier for the Files API beta. ClaudeClient injects this on every /v1/files request via newFileHttpClient."
	^ 'files-api-2025-04-14'
]

{ #category : 'betas' }
ClaudeBetaHeader class >> interleavedThinking [
	"Wire identifier for the interleaved-thinking beta on Claude 4 models."
	^ 'interleaved-thinking-2025-05-14'
]

{ #category : 'betas' }
ClaudeBetaHeader class >> mcpClient [
	"Wire identifier for the MCP connector beta. Set via ClaudeRequestOptions>>betas: alongside mcpServers:."
	^ 'mcp-client-2025-04-04'
]

{ #category : 'betas' }
ClaudeBetaHeader class >> messageBatches [
	"Wire identifier for the Message Batches API beta. ClaudeClient injects this on every /v1/messages/batches request via newBatchHttpClient."
	^ 'message-batches-2024-09-24'
]

{ #category : 'betas' }
ClaudeBetaHeader class >> output128k [
	"Wire identifier for the extended 128k output-tokens beta on Sonnet 3.7."
	^ 'output-128k-2025-02-19'
]

{ #category : 'betas' }
ClaudeBetaHeader class >> pdfs [
	"Wire identifier for the PDF input beta. Set via ClaudeRequestOptions>>betas: when sending base64 or URL PDF document blocks."
	^ 'pdfs-2024-09-25'
]

{ #category : 'betas' }
ClaudeBetaHeader class >> skills [
	"Wire identifier for the Skills API beta. ClaudeClient injects this on every /v1/skills request via newSkillHttpClient."
	^ 'skills-2025-10-02'
]

{ #category : 'betas' }
ClaudeBetaHeader class >> structuredOutputs [
	"Wire identifier for the structured outputs beta."
	^ 'structured-outputs-2025-11-13'
]
