"
Tests for ClaudeDocumentBlock — document content blocks for the Claude API supporting multiple source types. Covers all four factories (fromBase64:, fromText:, fromURL:/fromUrl: aliases, fromFileId:), JSON and STON round-trip, the tokensPerPageRange helper, the typed citations trio (enableCitations, disableCitations, citationsEnabled), and String-key normalization in the raw citations: setter.

  ClaudeDocumentBlockTest buildSuite run
  >>> 27 ran, 27 passed, 0 skipped, 0 expected failures, 0 failures, 0 errors, 0 passed unexpected




"
Class {
	#name : 'ClaudeDocumentBlockTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testAsJsonBase64Source [
  | block json source |
  block := ClaudeDocumentBlock fromBase64: 'JVBERi0xLjQ='.
  json := block asJson.
  self assert: (json at: 'type') equals: 'document'.
  source := json at: 'source'.
  self assert: (source at: 'type') equals: 'base64'.
  self assert: (source at: 'media_type') equals: 'application/pdf'.
  self assert: (source at: 'data') equals: 'JVBERi0xLjQ='
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testAsJsonFileSource [
  | block json source |
  block := ClaudeDocumentBlock fromFileId: 'file_abc123'.
  json := block asJson.
  self assert: (json at: 'type') equals: 'document'.
  source := json at: 'source'.
  self assert: (source at: 'type') equals: 'file'.
  self assert: (source at: 'file_id') equals: 'file_abc123'
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testCitationsEnabledAllPaths [
	"citationsEnabled covers: nil slot, true slot, false slot, raw dict without
	#enabled key."
	| doc |
	doc := ClaudeDocumentBlock fromText: 'hello'.
	self deny: doc citationsEnabled.
	doc citations: { #enabled -> true } asDictionary.
	self assert: doc citationsEnabled.
	doc citations: { #enabled -> false } asDictionary.
	self deny: doc citationsEnabled.
	doc citations: Dictionary new.
	self deny: doc citationsEnabled.
	doc citations: nil.
	self deny: doc citationsEnabled
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testCitationsEnabledNonDictionarySlot [
	"The citations: setter allows non-Dictionary values through as an escape hatch
	(e.g. nil clears the slot). STON/JSON restore could also land a non-Dictionary
	value. citationsEnabled must guard against this and return false rather than
	raising MessageNotUnderstood on at:ifAbsent:."
	| doc |
	doc := ClaudeDocumentBlock fromText: 'hello'.
	doc citations: 'weird'.
	self deny: doc citationsEnabled.
	doc citations: #( 1 2 3 ).
	self deny: doc citationsEnabled.
	doc citations: 42.
	self deny: doc citationsEnabled
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testCitationsSetterNormalizesStringKey [
	"The citations: setter normalizes a String 'enabled' key to the canonical
	Symbol #enabled. Guarantees JSON-restored blocks (STONJSON produces String keys)
	observe the same citationsEnabled predicate and emit the same asJson wire shape
	as hand-built blocks that use Symbol keys."
	| doc |
	doc := ClaudeDocumentBlock fromText: 'hello'.
	doc citations: ({ 'enabled' -> true } asDictionary).
	self assert: doc citationsEnabled.
	self assert: (doc citations at: #enabled) equals: true.
	self assert: doc citations keys first isSymbol.
	self assert: (STONJSON toString: doc citations) equals: '{"enabled":true}'
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testDisableCitationsSetsNil [
	"disableCitations sets the slot to nil so asJson omits the key. Does NOT emit
	{ enabled: false }."
	| doc json |
	doc := ClaudeDocumentBlock fromText: 'hello'.
	doc enableCitations.
	doc disableCitations.
	self assert: doc citations isNil.
	self deny: doc citationsEnabled.
	json := doc asJson.
	self deny: (json includesKey: 'citations')
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testEnableCitationsSetsDict [
	"enableCitations sets the underlying raw Dictionary slot to the wire shape
	{ enabled: true }."
	| doc |
	doc := ClaudeDocumentBlock fromText: 'hello'.
	doc enableCitations.
	self assert: doc citations isNotNil.
	self assert: (doc citations at: #enabled) equals: true.
	self assert: doc citationsEnabled
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testFromBase64CreatesBlock [
	| block |
	block := ClaudeDocumentBlock fromBase64: 'JVBERi0xLjQ='.
	self assert: block data equals: 'JVBERi0xLjQ='.
	self assert: block mediaType equals: 'application/pdf'.
	self assert: block type equals: 'document'
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testFromFileIdCreatesBlock [
  | block |
  block := ClaudeDocumentBlock fromFileId: 'file_abc123'.
  self assert: block source class equals: ClaudeFileDocumentSource.
  self assert: block source fileId equals: 'file_abc123'.
  self assert: block type equals: 'document'
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testFromJsonBase64Source [
  | json block |
  json := Dictionary newFromPairs: {
    'type'. 'document'.
    'source'. (Dictionary newFromPairs: {
      'type'. 'base64'.
      'media_type'. 'application/pdf'.
      'data'. 'JVBERi0xLjQ=' }) }.
  block := ClaudeDocumentBlock fromJson: json.
  self assert: block source class equals: ClaudeBase64DocumentSource.
  self assert: block data equals: 'JVBERi0xLjQ='.
  self assert: block mediaType equals: 'application/pdf'
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testFromJsonContentSource [
  | json block |
  json := Dictionary newFromPairs: {
    'type'. 'document'.
    'source'. (Dictionary newFromPairs: {
      'type'. 'content'.
      'content'. { Dictionary newFromPairs: { 'type'. 'text'. 'text'. 'inner' } } }) }.
  block := ClaudeDocumentBlock fromJson: json.
  self assert: block source class equals: ClaudeContentDocumentSource.
  self assert: block source content size equals: 1.
  self assert: block source content first isTextBlock
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testFromJsonFileSource [
  | json block |
  json := Dictionary newFromPairs: {
    'type'. 'document'.
    'source'. (Dictionary newFromPairs: {
      'type'. 'file'.
      'file_id'. 'file_abc123' }) }.
  block := ClaudeDocumentBlock fromJson: json.
  self assert: block source class equals: ClaudeFileDocumentSource.
  self assert: block source fileId equals: 'file_abc123'
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testFromJsonRoundTrip [
  | block json restored |
  block := ClaudeDocumentBlock fromBase64: 'JVBERi0xLjQ='.
  json := block asJson.
  restored := ClaudeContentBlock fromJson: json.
  self assert: restored class equals: ClaudeDocumentBlock.
  self assert: restored data equals: 'JVBERi0xLjQ='.
  self assert: restored mediaType equals: 'application/pdf'
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testFromJsonTextSource [
  | json block |
  json := Dictionary newFromPairs: {
    'type'. 'document'.
    'source'. (Dictionary newFromPairs: {
      'type'. 'text'.
      'media_type'. 'text/plain'.
      'data'. 'Hello world' }) }.
  block := ClaudeDocumentBlock fromJson: json.
  self assert: block source class equals: ClaudeTextDocumentSource.
  self assert: block source data equals: 'Hello world'
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testFromJsonURLSource [
  | json block |
  json := Dictionary newFromPairs: {
    'type'. 'document'.
    'source'. (Dictionary newFromPairs: {
      'type'. 'url'.
      'url'. 'https://example.com/doc.pdf' }) }.
  block := ClaudeDocumentBlock fromJson: json.
  self assert: block source class equals: ClaudeURLDocumentSource.
  self assert: block source url equals: 'https://example.com/doc.pdf'
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testFromTextCreatesBlock [
  | block |
  block := ClaudeDocumentBlock fromText: 'Hello world'.
  self assert: block source class equals: ClaudeTextDocumentSource.
  self assert: block source data equals: 'Hello world'.
  self assert: block type equals: 'document'
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testFromURLCreatesBlock [
  | block |
  block := ClaudeDocumentBlock fromURL: 'https://example.com/doc.pdf'.
  self assert: block source class equals: ClaudeURLDocumentSource.
  self assert: block source url equals: 'https://example.com/doc.pdf'.
  self assert: block type equals: 'document'
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testFromUrlAliasMatchesFromURL [
	"Both fromURL: and fromUrl: produce the same document block. Backward compatible:
	existing fromURL: callers (the pre-existing surface on ClaudeDocumentBlock)
	continue to work. The new alias fromUrl: mirrors ClaudeImageBlock's casing
	for cross-block symmetry."
	| upper lower |
	upper := ClaudeDocumentBlock fromURL: 'https://example.com/doc.pdf'.
	lower := ClaudeDocumentBlock fromUrl: 'https://example.com/doc.pdf'.
	self assert: upper source class equals: lower source class.
	self assert: upper source url equals: lower source url
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testIsDocumentBlock [
	self assert: (ClaudeDocumentBlock fromBase64: 'JVBERi0xLjQ=') isDocumentBlock.
	self deny: ClaudeTextBlock new isDocumentBlock
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testRawCitationsSetterStillWorks [
	"The raw citations: setter remains the escape hatch for any future wire-shape
	additions Anthropic makes. Existing callers passing a raw Dictionary continue
	to work and are observed by citationsEnabled."
	| doc |
	doc := ClaudeDocumentBlock fromText: 'hello'.
	doc citations: { #enabled -> true } asDictionary.
	self assert: doc citationsEnabled.
	self assert: (doc asJson at: 'citations') equals: ({ #enabled -> true } asDictionary)
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testSourceTypeDispatch [
  "fromJson: picks the correct source class for each source type."
  | types |
  types := {
    'base64' -> ClaudeBase64DocumentSource.
    'text' -> ClaudeTextDocumentSource.
    'content' -> ClaudeContentDocumentSource.
    'url' -> ClaudeURLDocumentSource.
    'file' -> ClaudeFileDocumentSource
  }.
  types do: [ :assoc |
    | src |
    src := ClaudeDocumentSource fromJson: (Dictionary newFromPairs: { 'type'. assoc key }).
    self assert: src class equals: assoc value ]
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testStonRoundTrip [
  "A ClaudeDocumentBlock should survive a STON serialization/deserialization round-trip."
  | block ston restored |
  block := ClaudeDocumentBlock fromBase64: 'JVBERi0xLjQ='.
  ston := STON toString: block.
  restored := STON fromString: ston.
  self assert: restored class equals: ClaudeDocumentBlock.
  self assert: restored source class equals: ClaudeBase64DocumentSource.
  self assert: restored data equals: 'JVBERi0xLjQ='.
  self assert: restored mediaType equals: 'application/pdf'
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testStonRoundTripFileSource [
  | block ston restored |
  block := ClaudeDocumentBlock fromFileId: 'file_abc123'.
  ston := STON toString: block.
  restored := STON fromString: ston.
  self assert: restored class equals: ClaudeDocumentBlock.
  self assert: restored source class equals: ClaudeFileDocumentSource.
  self assert: restored source fileId equals: 'file_abc123'
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testStonRoundTripTextSource [
  | block ston restored |
  block := ClaudeDocumentBlock fromText: 'Hello world'.
  ston := STON toString: block.
  restored := STON fromString: ston.
  self assert: restored class equals: ClaudeDocumentBlock.
  self assert: restored source class equals: ClaudeTextDocumentSource.
  self assert: restored source data equals: 'Hello world'
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testStonRoundTripURLSource [
  | block ston restored |
  block := ClaudeDocumentBlock fromURL: 'https://example.com/doc.pdf'.
  ston := STON toString: block.
  restored := STON fromString: ston.
  self assert: restored class equals: ClaudeDocumentBlock.
  self assert: restored source class equals: ClaudeURLDocumentSource.
  self assert: restored source url equals: 'https://example.com/doc.pdf'
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testStonRoundTripUnknownSource [
  | block ston restored |
  block := ClaudeDocumentBlock new
    source: (ClaudeDocumentSource fromJson: (Dictionary newFromPairs: { 'type'. 'custom' }));
    yourself.
  ston := STON toString: block.
  restored := STON fromString: ston.
  self assert: restored class equals: ClaudeDocumentBlock.
  self assert: restored source class equals: ClaudeDocumentSource.
  self assert: restored source sourceType equals: 'custom'
]

{ #category : 'tests' }
ClaudeDocumentBlockTest >> testTokensPerPageRange [
	"Anthropic's rough PDF budget: 1500-3000 input tokens per page."
	| range |
	range := ClaudeDocumentBlock tokensPerPageRange.
	self assert: range first equals: 1500.
	self assert: range last equals: 3000.
	self assert: range isInterval
]
