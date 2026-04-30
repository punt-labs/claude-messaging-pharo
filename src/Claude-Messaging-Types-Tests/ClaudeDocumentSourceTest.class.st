"
Tests for ClaudeDocumentSource and its 5 concrete subclasses.

  ClaudeDocumentSourceTest buildSuite run
  >>> 12 ran, 12 passed, 0 skipped, 0 expected failures, 0 failures, 0 errors, 0 passed unexpected

"
Class {
	#name : 'ClaudeDocumentSourceTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeDocumentSourceTest >> testAbstractFromJsonDispatches [
  "ClaudeDocumentSource fromJson: dispatches on source type."
  | src |
  src := ClaudeDocumentSource fromJson: (Dictionary newFromPairs: { 'type'. 'base64' }).
  self assert: src class equals: ClaudeBase64DocumentSource.
  src := ClaudeDocumentSource fromJson: (Dictionary newFromPairs: { 'type'. 'text' }).
  self assert: src class equals: ClaudeTextDocumentSource.
  src := ClaudeDocumentSource fromJson: (Dictionary newFromPairs: { 'type'. 'content' }).
  self assert: src class equals: ClaudeContentDocumentSource.
  src := ClaudeDocumentSource fromJson: (Dictionary newFromPairs: { 'type'. 'url' }).
  self assert: src class equals: ClaudeURLDocumentSource.
  src := ClaudeDocumentSource fromJson: (Dictionary newFromPairs: { 'type'. 'file' }).
  self assert: src class equals: ClaudeFileDocumentSource
]

{ #category : 'tests' }
ClaudeDocumentSourceTest >> testBase64SourceAsJson [
  | src json |
  src := ClaudeBase64DocumentSource new data: 'JVBERi0xLjQ='; yourself.
  json := src asJson.
  self assert: (json at: 'type') equals: 'base64'.
  self assert: (json at: 'media_type') equals: 'application/pdf'.
  self assert: (json at: 'data') equals: 'JVBERi0xLjQ='
]

{ #category : 'tests' }
ClaudeDocumentSourceTest >> testBase64SourceFromJson [
  | src |
  src := ClaudeBase64DocumentSource fromJson: (Dictionary newFromPairs: {
    'type'. 'base64'. 'media_type'. 'application/pdf'. 'data'. 'JVBERi0xLjQ=' }).
  self assert: src data equals: 'JVBERi0xLjQ='.
  self assert: src mediaType equals: 'application/pdf'.
  self assert: src sourceType equals: 'base64'
]

{ #category : 'tests' }
ClaudeDocumentSourceTest >> testContentSourceAsJson [
	| src json blocks |
	src := ClaudeContentDocumentSource new.
	blocks := OrderedCollection new.
	blocks add: (ClaudeContentBlock fromJson: (Dictionary newFromPairs: { 'type'. 'text'. 'text'. 'hello' })).
	src content: blocks.
	json := src asJson.
	self assert: (json at: 'type') equals: 'content'.
	self assert: (json at: 'content') size equals: 1
]

{ #category : 'tests' }
ClaudeDocumentSourceTest >> testContentSourceFromJson [
  | src |
  src := ClaudeContentDocumentSource fromJson: (Dictionary newFromPairs: {
    'type'. 'content'.
    'content'. { Dictionary newFromPairs: { 'type'. 'text'. 'text'. 'hello' } } }).
  self assert: src content size equals: 1.
  self assert: src content first isTextBlock.
  self assert: src sourceType equals: 'content'
]

{ #category : 'tests' }
ClaudeDocumentSourceTest >> testFileSourceAsJson [
  | src json |
  src := ClaudeFileDocumentSource new fileId: 'file_abc123'; yourself.
  json := src asJson.
  self assert: (json at: 'type') equals: 'file'.
  self assert: (json at: 'file_id') equals: 'file_abc123'
]

{ #category : 'tests' }
ClaudeDocumentSourceTest >> testFileSourceFromJson [
  | src |
  src := ClaudeFileDocumentSource fromJson: (Dictionary newFromPairs: {
    'type'. 'file'. 'file_id'. 'file_abc123' }).
  self assert: src fileId equals: 'file_abc123'.
  self assert: src sourceType equals: 'file'
]

{ #category : 'tests' }
ClaudeDocumentSourceTest >> testTextSourceAsJson [
  | src json |
  src := ClaudeTextDocumentSource new data: 'Hello'; yourself.
  json := src asJson.
  self assert: (json at: 'type') equals: 'text'.
  self assert: (json at: 'media_type') equals: 'text/plain'.
  self assert: (json at: 'data') equals: 'Hello'
]

{ #category : 'tests' }
ClaudeDocumentSourceTest >> testTextSourceFromJson [
  | src |
  src := ClaudeTextDocumentSource fromJson: (Dictionary newFromPairs: {
    'type'. 'text'. 'media_type'. 'text/plain'. 'data'. 'Hello' }).
  self assert: src data equals: 'Hello'.
  self assert: src mediaType equals: 'text/plain'.
  self assert: src sourceType equals: 'text'
]

{ #category : 'tests' }
ClaudeDocumentSourceTest >> testURLSourceAsJson [
  | src json |
  src := ClaudeURLDocumentSource new url: 'https://example.com/doc.pdf'; yourself.
  json := src asJson.
  self assert: (json at: 'type') equals: 'url'.
  self assert: (json at: 'url') equals: 'https://example.com/doc.pdf'
]

{ #category : 'tests' }
ClaudeDocumentSourceTest >> testURLSourceFromJson [
  | src |
  src := ClaudeURLDocumentSource fromJson: (Dictionary newFromPairs: {
    'type'. 'url'. 'url'. 'https://example.com/doc.pdf' }).
  self assert: src url equals: 'https://example.com/doc.pdf'.
  self assert: src sourceType equals: 'url'
]

{ #category : 'tests' }
ClaudeDocumentSourceTest >> testUnknownSourceTypePreservesRawDict [
  | dict src |
  dict := Dictionary newFromPairs: { 'type'. 'future_type'. 'foo'. 'bar' }.
  src := ClaudeDocumentSource fromJson: dict.
  self assert: src class equals: ClaudeDocumentSource.
  self assert: src sourceType equals: 'future_type'.
  self assert: src rawDict equals: dict.
  self assert: src asJson equals: dict
]
