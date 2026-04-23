"
Tests for ClaudeImageBlock — image content blocks for the Claude API. Covers factories (fromFileId:, fromUrl:/fromURL: aliases, base64:mediaType:, fromFile:, fromForm:), JSON round-trip, and raw-byte size validation against Anthropic's 5 MB per-image cap.

  ClaudeImageBlockTest buildSuite run
  >>> 12 ran, 12 passed, 0 skipped, 0 expected failures, 0 failures, 0 errors, 0 passed unexpected




"
Class {
	#name : 'ClaudeImageBlockTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeImageBlockTest >> testBase64AtLimitAccepted [
	"Raw byte count at the cap passes validation (boundary is inclusive)."
	| encoded block |
	encoded := ZnBase64Encoder new encode: (ByteArray new: ClaudeImageBlock maxImageBytes withAll: 0).
	block := ClaudeImageBlock base64: encoded mediaType: 'image/png'.
	self assert: block source isNotNil.
	self assert: (block source at: 'type') equals: 'base64'
]

{ #category : 'tests' }
ClaudeImageBlockTest >> testBase64OverLimitRejected [
	"Raw byte count above the cap raises ClaudeInvalidRequestError with the actual
	size and the cap both in the message."
	| encoded raised |
	encoded := ZnBase64Encoder new encode: (ByteArray new: ClaudeImageBlock maxImageBytes + 1 withAll: 0).
	raised := false.
	[ ClaudeImageBlock base64: encoded mediaType: 'image/png' ]
		on: ClaudeInvalidRequestError
		do: [ :e |
			raised := true.
			self assert: (e messageText includesSubstring: (ClaudeImageBlock maxImageBytes + 1) printString).
			self assert: (e messageText includesSubstring: ClaudeImageBlock maxImageBytes printString) ].
	self assert: raised
]

{ #category : 'tests' }
ClaudeImageBlockTest >> testEstimatedRawByteSizeDegenerateInputClampsToZero [
	"Degenerate base64 inputs '=' and '==' would naively yield negative raw byte
	counts (padding exceeds trimmedLen); the contract clamps the return to 0 so
	validateRawByteCount: (upper-bound only) never sees a negative value. Copilot
	flagged this on PR #134 round-3."
	self assert: (ClaudeImageBlock estimatedRawByteSize: '=') equals: 0.
	self assert: (ClaudeImageBlock estimatedRawByteSize: '==') equals: 0.
	self assert: (ClaudeImageBlock estimatedRawByteSize: '') equals: 0
]

{ #category : 'tests' }
ClaudeImageBlockTest >> testFromFileAtLimitAccepted [
	"A file whose bytes are exactly at the cap passes. Uses project-local .tmp/ per
	the workspace convention rather than a Pharo VM runtime directory."
	| tmpDir file block |
	tmpDir := '.tmp/claude-image-test-at' asFileReference.
	tmpDir ensureDeleteAll.
	tmpDir ensureCreateDirectory.
	file := tmpDir / 'at.png'.
	[ file binaryWriteStreamDo: [ :s | s nextPutAll: (ByteArray new: ClaudeImageBlock maxImageBytes withAll: 0) ].
	  block := ClaudeImageBlock fromFile: file.
	  self assert: block source isNotNil.
	  self assert: (block source at: 'type') equals: 'base64' ]
		ensure: [
			file ensureDelete.
			tmpDir ensureDeleteAll ]
]

{ #category : 'tests' }
ClaudeImageBlockTest >> testFromFileIdAsJson [
  | block json source |
  block := ClaudeImageBlock fromFileId: 'file-abc123'.
  json := block asJson.
  self assert: (json at: 'type') equals: 'image'.
  source := json at: 'source'.
  self assert: (source at: 'type') equals: 'file'.
  self assert: (source at: 'file_id') equals: 'file-abc123'
]

{ #category : 'tests' }
ClaudeImageBlockTest >> testFromFileIdCreatesBlock [
  | block |
  block := ClaudeImageBlock fromFileId: 'file-abc123'.
  self assert: block source isNotNil.
  self assert: (block source at: 'type') equals: 'file'.
  self assert: (block source at: 'file_id') equals: 'file-abc123'
]

{ #category : 'tests' }
ClaudeImageBlockTest >> testFromFileIdRoundTrip [
  | block json restored |
  block := ClaudeImageBlock fromFileId: 'file-abc123'.
  json := block asJson.
  restored := ClaudeImageBlock fromJson: json.
  self assert: (restored source at: 'type') equals: 'file'.
  self assert: (restored source at: 'file_id') equals: 'file-abc123'
]

{ #category : 'tests' }
ClaudeImageBlockTest >> testFromFileOverLimitRejected [
	"A file one byte over the cap raises ClaudeInvalidRequestError before encoding.
	Uses project-local .tmp/ per the workspace convention."
	| tmpDir file raised |
	tmpDir := '.tmp/claude-image-test-over' asFileReference.
	tmpDir ensureDeleteAll.
	tmpDir ensureCreateDirectory.
	file := tmpDir / 'over.png'.
	raised := false.
	[ file binaryWriteStreamDo: [ :s | s nextPutAll: (ByteArray new: ClaudeImageBlock maxImageBytes + 1 withAll: 0) ].
	  [ ClaudeImageBlock fromFile: file ]
	    on: ClaudeInvalidRequestError
	    do: [ :e |
	      raised := true.
	      self assert: (e messageText includesSubstring: (ClaudeImageBlock maxImageBytes + 1) printString) ] ]
		ensure: [
			file ensureDelete.
			tmpDir ensureDeleteAll ].
	self assert: raised
]

{ #category : 'tests' }
ClaudeImageBlockTest >> testFromFormSmallAccepted [
	"Small Forms produce small PNG bytes and pass validation."
	| block |
	block := ClaudeImageBlock fromForm: (Form extent: 10@10 depth: 32).
	self assert: block source isNotNil.
	self assert: (block source at: 'type') equals: 'base64'.
	self assert: (block source at: 'media_type') equals: 'image/png'
]

{ #category : 'tests' }
ClaudeImageBlockTest >> testFromURLAliasMatchesFromUrl [
	"Both fromUrl: and fromURL: produce the same wire shape. Backward compatible:
	existing fromUrl: callers continue to work."
	| lower upper |
	lower := ClaudeImageBlock fromUrl: 'https://example.com/photo.png'.
	upper := ClaudeImageBlock fromURL: 'https://example.com/photo.png'.
	self assert: (lower source at: 'type') equals: (upper source at: 'type').
	self assert: (lower source at: 'url') equals: (upper source at: 'url')
]

{ #category : 'tests' }
ClaudeImageBlockTest >> testValidateRawByteCountErrorClass [
	"Size-rejection errors are ClaudeInvalidRequestError instances with status 400."
	| caught |
	caught := [ ClaudeImageBlock validateRawByteCount: ClaudeImageBlock maxImageBytes + 1. nil ]
		on: ClaudeInvalidRequestError
		do: [ :e | e ].
	self assert: caught class equals: ClaudeInvalidRequestError.
	self assert: caught statusCode equals: 400
]

{ #category : 'tests' }
ClaudeImageBlockTest >> testValidateRawByteCountOverLimit [
	"The over-cap rejection fires from validateRawByteCount: directly — no PNG
	round-trip needed. Replaces the old 1500x1500 Form test (2.25M pixel fills were
	slow and noisy). The fromForm: happy path is still covered by testFromFormSmallAccepted."
	| raised |
	raised := false.
	[ ClaudeImageBlock validateRawByteCount: ClaudeImageBlock maxImageBytes + 1 ]
		on: ClaudeInvalidRequestError
		do: [ :e |
			raised := true.
			self assert: (e messageText includesSubstring: (ClaudeImageBlock maxImageBytes + 1) printString).
			self assert: (e messageText includesSubstring: ClaudeImageBlock maxImageBytes printString) ].
	self assert: raised
]
