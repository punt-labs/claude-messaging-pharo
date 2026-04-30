"
A document content block for the Claude API. Supports multiple source types: base64, text, content, url, and file. The source slot holds a ClaudeDocumentSource subclass instance that handles type-specific serialization.

### Examples

  ClaudeDocumentBlock fromBase64: 'JVBERi0xLjQ='
  >>> a ClaudeDocumentBlock

  (ClaudeDocumentBlock fromBase64: 'JVBERi0xLjQ=') asJson at: 'type'
  >>> 'document'

  (ClaudeDocumentBlock fromBase64: 'JVBERi0xLjQ=') isDocumentBlock
  >>> true

  (ClaudeDocumentBlock fromFileId: 'file_123') source sourceType
  >>> 'file'

  (ClaudeDocumentBlock fromText: 'Hello world') source sourceType
  >>> 'text'

  (ClaudeDocumentBlock fromURL: 'https://example.com/doc.pdf') source sourceType
  >>> 'url'

"
Class {
	#name : 'ClaudeDocumentBlock',
	#superclass : 'ClaudeContentBlock',
	#instVars : [
		'source',
		'title',
		'citations'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'instance creation' }
ClaudeDocumentBlock class >> fromBase64: aBase64String [
  "Create a document block from a base64-encoded string. Backwards compatible."
  ^ self new
    source: (ClaudeBase64DocumentSource new data: aBase64String; yourself);
    yourself
]

{ #category : 'instance creation' }
ClaudeDocumentBlock class >> fromFileId: aString [
  "Create a document block referencing a file by ID."
  ^ self new
    source: (ClaudeFileDocumentSource new fileId: aString; yourself);
    yourself
]

{ #category : 'json' }
ClaudeDocumentBlock class >> fromJson: aDictionary [
  "Create from wire-format JSON dictionary."
  | sourceDict |
  sourceDict := aDictionary at: 'source' ifAbsent: [ nil ].
  ^ self new
    source: (sourceDict ifNotNil: [ ClaudeDocumentSource fromJson: sourceDict ]);
    title: (aDictionary at: 'title' ifAbsent: [ nil ]);
    citations: (aDictionary at: 'citations' ifAbsent: [ nil ]);
    yourself
]

{ #category : 'STON' }
ClaudeDocumentBlock class >> fromSton: stonReader [
  "Deserialize from STON, restoring source, title, and citations."
  | dict |
  dict := Dictionary new.
  stonReader parseMapDo: [ :key :value | dict at: key put: value ].
  ^ self new
    source: (dict at: #source ifAbsent: [ nil ]);
    title: (dict at: #title ifAbsent: [ nil ]);
    citations: (dict at: #citations ifAbsent: [ nil ]);
    yourself
]

{ #category : 'instance creation' }
ClaudeDocumentBlock class >> fromText: aString [
  "Create a document block from plain text."
  ^ self new
    source: (ClaudeTextDocumentSource new data: aString; yourself);
    yourself
]

{ #category : 'instance creation' }
ClaudeDocumentBlock class >> fromURL: aURLString [
  "Create a document block referencing a URL."
  ^ self new
    source: (ClaudeURLDocumentSource new url: aURLString; yourself);
    yourself
]

{ #category : 'instance creation' }
ClaudeDocumentBlock class >> fromUrl: aURLString [
	"Lowercase-url alias for fromURL:. Both selectors build identical document blocks;
	the alias aligns casing with ClaudeImageBlock>>fromUrl: for callers that prefer
	the lowercase convention."
	^ self fromURL: aURLString
]

{ #category : 'limits' }
ClaudeDocumentBlock class >> tokensPerPageRange [
	"Anthropic's rough per-page token budget for PDF input. Returns an Interval so
	callers can multiply by a page count to estimate minimum and maximum input-token
	cost. Use countTokens: for a precise count before sending a large PDF."
	^ 1500 to: 3000
]

{ #category : 'json' }
ClaudeDocumentBlock >> asJson [
  | dict |
  dict := OrderedDictionary new.
  dict at: 'type' put: 'document'.
  source ifNotNil: [ :s | dict at: 'source' put: s asJson ].
  title ifNotNil: [ dict at: 'title' put: title ].
  citations ifNotNil: [ dict at: 'citations' put: citations ].
  ^ dict
]

{ #category : 'accessing' }
ClaudeDocumentBlock >> citations [
  ^ citations
]

{ #category : 'accessing' }
ClaudeDocumentBlock >> citations: aDictionary [
	"Set the raw citations Dictionary slot. Normalizes a String 'enabled' key to
	the canonical Symbol #enabled so JSON-restored blocks (STONJSON produces String
	keys) and hand-built blocks behave identically through citationsEnabled and
	asJson. Non-Dictionary input passes through unchanged (e.g. nil clears the slot)."
	| normalized |
	aDictionary isDictionary
		ifFalse: [ citations := aDictionary ]
		ifTrue: [
			(aDictionary includesKey: 'enabled')
				ifFalse: [ citations := aDictionary ]
				ifTrue: [
					normalized := Dictionary new.
					aDictionary keysAndValuesDo: [ :key :value |
						(key = 'enabled' and: [ key isSymbol not ])
							ifTrue: [ normalized at: #enabled put: value ]
							ifFalse: [ normalized at: key put: value ] ].
					citations := normalized ] ]
]

{ #category : 'accessing' }
ClaudeDocumentBlock >> citationsEnabled [
	"Boolean predicate reading the citations slot. Returns true iff the slot is
	a Dictionary AND its #enabled value is the Boolean true. Returns false in
	every other case: nil slot, non-Dictionary slot (String/Array/etc. — the
	citations: setter lets arbitrary values through as an escape hatch, and
	STON/JSON restore can land one here too), { #enabled -> false }, missing
	#enabled key, or a non-Boolean value at #enabled (e.g. the String 'true'
	from a non-normalized JSON payload). The polymorphic dispatch through
	ifTrue:ifFalse: enforces the Boolean contract — Boolean responds with the
	matching branch, every other class raises a NonBooleanReceiver, which we
	catch and answer false. This stays clear of Renraku's 'Unnecessary = true'
	rule (which fires on direct = / == / ~= / ~~ against true or false), the
	bad-message rule (which forbids isKindOf:), and the True/False class-name
	rule (which forbids referencing True or False directly). Callers should
	prefer this predicate over poking at the raw Dictionary. The slot is set
	via #enableCitations / #disableCitations which always write Boolean values;
	the raw #citations: setter is an escape hatch where non-Boolean values
	would surface truthfully."
	| value |
	citations ifNil: [ ^ false ].
	citations isDictionary ifFalse: [ ^ false ].
	value := citations at: #enabled ifAbsent: [ ^ false ].
	^ [ value ifTrue: [ true ] ifFalse: [ false ] ]
		on: NonBooleanReceiver
		do: [ :ex | false ]
]

{ #category : 'accessing' }
ClaudeDocumentBlock >> data [
	"Backwards compatibility: delegate to source. ClaudeDocumentSource
	 answers nil from #data unless a subclass carries inline data
	 (Base64/Text), so the polymorphic call covers every shape without
	 a respondsTo: guard."
	^ source ifNotNil: [ source data ]
]

{ #category : 'accessing' }
ClaudeDocumentBlock >> disableCitations [
	"Turn off citation emission for this document block. Sets the slot to nil so
	asJson omits the citations key entirely. Does NOT emit { #enabled -> false } —
	Anthropic's API recognizes { enabled: true } as the opt-in signal; the opt-out
	is key omission, and emitting false is undefined behavior that must not be sent
	on the wire."
	citations := nil.
	^ self
]

{ #category : 'accessing' }
ClaudeDocumentBlock >> enableCitations [
	"Turn on citation emission for this document block. Sets the underlying raw
	Dictionary slot to { #enabled -> true } asDictionary, which is the wire shape
	Anthropic's API reads. The asJson method already gates emission on ifNotNil:,
	so an enabled block serializes its citations key and a disabled one omits it.
	Preferred over the raw citations: setter for new code — self-documenting,
	prevents accidental wire-shape drift."
	citations := { #enabled -> true } asDictionary.
	^ self
]

{ #category : 'initialization' }
ClaudeDocumentBlock >> initialize [
  super initialize.
  type := 'document'
]

{ #category : 'testing' }
ClaudeDocumentBlock >> isDocumentBlock [
  ^ true
]

{ #category : 'accessing' }
ClaudeDocumentBlock >> mediaType [
	"Backwards compatibility: delegate to source. ClaudeDocumentSource
	 answers nil from #mediaType unless a subclass advertises one
	 (Base64/Text)."
	^ source ifNotNil: [ source mediaType ]
]

{ #category : 'accessing' }
ClaudeDocumentBlock >> source [
  ^ source
]

{ #category : 'accessing' }
ClaudeDocumentBlock >> source: aClaudeDocumentSource [
  source := aClaudeDocumentSource
]

{ #category : 'STON' }
ClaudeDocumentBlock >> stonOn: aStonWriter [
  "Serialize to STON, preserving source, title, and citations."
  aStonWriter writeObject: self streamMap: [ :map |
    source ifNotNil: [ map at: #source put: source ].
    title ifNotNil: [ map at: #title put: title ].
    citations ifNotNil: [ map at: #citations put: citations ] ]
]

{ #category : 'accessing' }
ClaudeDocumentBlock >> title [
  ^ title
]

{ #category : 'accessing' }
ClaudeDocumentBlock >> title: aString [
  title := aString
]
