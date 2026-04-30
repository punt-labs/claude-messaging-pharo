"
An image content block for the Claude Messages API. Contains a source dictionary with type (base64 or url), media_type, and data fields.

Example — from a Pharo Form:
  ClaudeImageBlock fromForm: (Form extent: 10@10 depth: 32)
  >>> a ClaudeImageBlock

Example — from a URL:
  (ClaudeImageBlock fromUrl: 'https://example.com/photo.png') source at: 'type'
  >>> 'url'

Example — from a file:
  (ClaudeImageBlock fromFile: 'screenshot.png') source keys
  >>> #('type' 'media_type' 'data')

Example — base64 directly:
  (ClaudeImageBlock base64: 'abc' mediaType: 'image/png') asJson keys
  >>> #('type' 'source')

"
Class {
	#name : 'ClaudeImageBlock',
	#superclass : 'ClaudeContentBlock',
	#instVars : [
		'source'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'instance creation' }
ClaudeImageBlock class >> base64: encodedData mediaType: mimeType [
	"Public factory for an image block whose source is a base64-encoded payload.
	Validates the estimated raw byte count of the encoded string against the
	per-image cap before constructing the block. fromFile: and fromForm: bypass
	this path because they already know the exact raw byte count."
	self validateRawByteCount: (self estimatedRawByteSize: encodedData).
	^ self newFromValidatedBase64: encodedData mediaType: mimeType
]

{ #category : 'private' }
ClaudeImageBlock class >> estimatedRawByteSize: encodedData [
	"Estimate the raw (decoded) byte count of a base64-encoded string without
	performing the full decode. Base64 encodes every 3 raw bytes as 4 characters
	and pads with up to 2 trailing '=' chars to align the output. The exact
	raw length is (encoded size * 3 / 4) - (count of trailing '='). Contract:
	the returned value is never negative. Degenerate inputs like '=' or '==' —
	where the padding count exceeds the trimmed length — clamp to 0 so that
	validateRawByteCount: (which tests only against an upper bound) never sees
	a negative raw-byte count."
	| encoded padding trimmedLen |
	encoded := encodedData.
	padding := 0.
	(encoded isNotEmpty and: [ encoded last = $= ]) ifTrue: [ padding := padding + 1 ].
	(encoded size >= 2 and: [ (encoded at: encoded size - 1) = $= ]) ifTrue: [ padding := padding + 1 ].
	trimmedLen := (encoded size * 3) // 4.
	^ (trimmedLen - padding) max: 0
]

{ #category : 'instance creation' }
ClaudeImageBlock class >> fromFile: aFileReferenceOrString [
	"Create an image block from an image file on disk."
	| file bytes base64 mediaType ext |
	file := aFileReferenceOrString asFileReference.
	bytes := file binaryReadStreamDo: [:s | s contents].
	self validateRawByteCount: bytes size.
	base64 := ZnBase64Encoder new encode: bytes.
	ext := file extension asLowercase.
	mediaType := (Dictionary newFromPairs: {
		'png'. 'image/png'.
		'jpg'. 'image/jpeg'.
		'jpeg'. 'image/jpeg'.
		'gif'. 'image/gif'.
		'webp'. 'image/webp' })
		at: ext ifAbsent: [ 'image/png' ].
	^ self newFromValidatedBase64: base64 mediaType: mediaType
]

{ #category : 'instance creation' }
ClaudeImageBlock class >> fromFileId: aString [
	"Create an image block referencing a file by ID."
	^ self new source: {
		'type' -> 'file'.
		'file_id' -> aString } asDictionary;
		yourself
]

{ #category : 'instance creation' }
ClaudeImageBlock class >> fromForm: aForm [
	"Create an image block from a Pharo Form (e.g. aMorph imageForm, World imageForm)."
	| pngBytes base64 |
	pngBytes := ByteArray streamContents: [:stream |
		PNGReadWriter putForm: aForm onStream: stream].
	self validateRawByteCount: pngBytes size.
	base64 := ZnBase64Encoder new encode: pngBytes.
	^ self newFromValidatedBase64: base64 mediaType: 'image/png'
]

{ #category : 'json' }
ClaudeImageBlock class >> fromJson: aDictionary [
	^ self new
		source: (aDictionary at: 'source' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'persistence' }
ClaudeImageBlock class >> fromSton: stonReader [
	| dict raw |
	dict := Dictionary new.
	stonReader parseMapDo: [ :key :value | dict at: key put: value ].
	raw := dict at: #source ifAbsent: [ nil ].
	^ self new
		source: (raw ifNotNil: [
			raw class = OrderedDictionary
				ifTrue: [ raw ]
				ifFalse: [ | od | od := OrderedDictionary new. raw keysAndValuesDo: [ :k :v | od at: k put: v ]. od ] ]);
		yourself
]

{ #category : 'instance creation' }
ClaudeImageBlock class >> fromURL: urlString [
	"Uppercase-URL alias for fromUrl:. Both selectors build identical image blocks;
	the alias aligns casing with ClaudeDocumentBlock>>fromURL: for callers that
	prefer the uppercase convention."
	^ self fromUrl: urlString
]

{ #category : 'instance creation' }
ClaudeImageBlock class >> fromUrl: urlString [
	"Create an image block with a URL source"
	| src |
	src := OrderedDictionary new.
	src at: 'type' put: 'url'.
	src at: 'url' put: urlString.
	^ self new
		source: src;
		yourself
]

{ #category : 'limits' }
ClaudeImageBlock class >> maxImageBytes [
	"Anthropic's per-image inline size cap. Raw-byte limit before base64 encoding.
	See §25 Vision for enforcement scope (applies to inline sources only)."
	^ 5 * 1024 * 1024
]

{ #category : 'private' }
ClaudeImageBlock class >> newFromValidatedBase64: encodedData mediaType: mimeType [
	"Private — construct an image block from an already-validated base64 payload.
	Callers must have called validateRawByteCount: on the raw byte count before
	invoking this method. Public entry points: base64:mediaType:, fromFile:, fromForm:."
	| src |
	src := OrderedDictionary new.
	src at: 'type' put: 'base64'.
	src at: 'media_type' put: mimeType.
	src at: 'data' put: encodedData.
	^ self new
		source: src;
		yourself
]

{ #category : 'limits' }
ClaudeImageBlock class >> validateRawByteCount: anInteger [
	"Raise a ClaudeInvalidRequestError if the raw byte count exceeds the per-image cap.
	Called by inline-source factories (base64:mediaType:, fromFile:, fromForm:) BEFORE
	base64 encoding so the check operates on the actual payload size, not the inflated
	encoded length. URL and file-ID sources skip this — the server validates at fetch
	or lookup time."
	anInteger > self maxImageBytes ifTrue: [
		ClaudeInvalidRequestError signal:
			'Image size ' , anInteger printString , ' bytes exceeds limit of ' ,
			self maxImageBytes printString , ' bytes.' ]
]

{ #category : 'json' }
ClaudeImageBlock >> asJson [
	| dict |
	dict := OrderedDictionary new.
	dict at: 'type' put: 'image'.
	source ifNotNil: [ dict at: 'source' put: source ].
	^ dict
]

{ #category : 'initialization' }
ClaudeImageBlock >> initialize [
	super initialize.
	type := 'image'
]

{ #category : 'accessing' }
ClaudeImageBlock >> source [
	^ source
]

{ #category : 'accessing' }
ClaudeImageBlock >> source: aDictionary [
	source := aDictionary
]

{ #category : 'persistence' }
ClaudeImageBlock >> stonOn: aStonWriter [
	aStonWriter writeObject: self streamMap: [ :map |
		map at: #source put: source ]
]
