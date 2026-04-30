"
Tests for the ClaudeBetaHeader beta-identifier catalog.

One test per class-side selector pins each wire String. testAllKnownSize and testAllKnownOrder pin the catalog contract so new entries show up as a focused failure, not a drift nobody notices.

  ClaudeBetaHeaderTest buildSuite run
  >>> 11 run, 11 passes

"
Class {
	#name : 'ClaudeBetaHeaderTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeBetaHeaderTest >> testAllKnownOrder [
	"allKnown returns identifiers in documentation order."
	self assert: ClaudeBetaHeader allKnown asArray equals: #(
		'files-api-2025-04-14'
		'skills-2025-10-02'
		'mcp-client-2025-04-04'
		'pdfs-2024-09-25'
		'output-128k-2025-02-19'
		'document-url-2025-04-15'
		'context-1m-2025-08-07'
		'structured-outputs-2025-11-13'
		'interleaved-thinking-2025-05-14'
		'message-batches-2024-09-24')
]

{ #category : 'tests' }
ClaudeBetaHeaderTest >> testAllKnownSize [
	"The catalog ships exactly 10 known identifiers."
	self assert: ClaudeBetaHeader allKnown size equals: 10
]

{ #category : 'tests' }
ClaudeBetaHeaderTest >> testContext1m [
	self assert: ClaudeBetaHeader context1m equals: 'context-1m-2025-08-07'
]

{ #category : 'tests' }
ClaudeBetaHeaderTest >> testDocumentUrl [
	self assert: ClaudeBetaHeader documentUrl equals: 'document-url-2025-04-15'
]

{ #category : 'tests' }
ClaudeBetaHeaderTest >> testFilesApi [
	self assert: ClaudeBetaHeader filesApi equals: 'files-api-2025-04-14'
]

{ #category : 'tests' }
ClaudeBetaHeaderTest >> testInterleavedThinking [
	self assert: ClaudeBetaHeader interleavedThinking equals: 'interleaved-thinking-2025-05-14'
]

{ #category : 'tests' }
ClaudeBetaHeaderTest >> testMcpClient [
	self assert: ClaudeBetaHeader mcpClient equals: 'mcp-client-2025-04-04'
]

{ #category : 'tests' }
ClaudeBetaHeaderTest >> testMessageBatches [
	self assert: ClaudeBetaHeader messageBatches equals: 'message-batches-2024-09-24'
]

{ #category : 'tests' }
ClaudeBetaHeaderTest >> testOutput128k [
	self assert: ClaudeBetaHeader output128k equals: 'output-128k-2025-02-19'
]

{ #category : 'tests' }
ClaudeBetaHeaderTest >> testPdfs [
	self assert: ClaudeBetaHeader pdfs equals: 'pdfs-2024-09-25'
]

{ #category : 'tests' }
ClaudeBetaHeaderTest >> testSkills [
	self assert: ClaudeBetaHeader skills equals: 'skills-2025-10-02'
]

{ #category : 'tests' }
ClaudeBetaHeaderTest >> testStructuredOutputs [
	self assert: ClaudeBetaHeader structuredOutputs equals: 'structured-outputs-2025-11-13'
]
