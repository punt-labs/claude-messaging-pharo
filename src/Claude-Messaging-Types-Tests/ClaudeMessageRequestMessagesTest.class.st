"
Tests for ClaudeMessageRequest message and content-block construction — addUserMessage:, addAssistantMessage:, addToolResult:, text blocks, image blocks, cache control.
"
Class {
	#name : 'ClaudeMessageRequestMessagesTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeMessageRequestMessagesTest >> testAddAssistantMessage [
	| params msgs msg |
	params := ClaudeMessageRequest new.
	params addAssistantMessage: 'The answer is 4.'.
	msgs := params messages.
	self assert: msgs size equals: 1.
	msg := msgs first.
	self assert: (msg isKindOf: ClaudeMessage).
	self assert: msg role equals: 'assistant'.
	self assert: msg textContent equals: 'The answer is 4.'
]

{ #category : 'tests' }
ClaudeMessageRequestMessagesTest >> testAddAssistantResponse [
	| params msg stored |
	msg := ClaudeMessage new.
	msg role: #assistant.
	msg content: (OrderedCollection with: (ClaudeTextBlock text: 'Hi there')).
	params := ClaudeMessageRequest new.
	params addAssistantResponse: msg.
	self assert: params messages size equals: 1.
	stored := params messages first.
	self assert: (stored isKindOf: ClaudeMessage).
	self assert: stored role equals: #assistant.
	self assert: stored textContent equals: 'Hi there'.
	self assert: stored identicalTo: msg
]

{ #category : 'tests' }
ClaudeMessageRequestMessagesTest >> testAddToolResult [
	| params msg block |
	params := ClaudeMessageRequest new.
	params addToolResult: 'toolu_01ABC' content: '42'.
	self assert: params messages size equals: 1.
	msg := params messages first.
	self assert: (msg isKindOf: ClaudeMessage).
	self assert: msg role equals: 'user'.
	self assert: msg content size equals: 1.
	block := msg content first.
	self assert: block isToolResultBlock.
	self assert: block toolUseId equals: 'toolu_01ABC'.
	self assert: block content equals: '42'.
	self assert: block isError isNil
]

{ #category : 'tests' }
ClaudeMessageRequestMessagesTest >> testAddToolResultWithError [
	| params msg block |
	params := ClaudeMessageRequest new.
	params addToolResult: 'toolu_01XYZ' content: 'File not found' isError: true.
	msg := params messages first.
	self assert: (msg isKindOf: ClaudeMessage).
	block := msg content first.
	self assert: block isToolResultBlock.
	self assert: block toolUseId equals: 'toolu_01XYZ'.
	self assert: block content equals: 'File not found'.
	self assert: block isError equals: true
]

{ #category : 'tests' }
ClaudeMessageRequestMessagesTest >> testAddUserContentCreatesMultiBlockMessage [
	| params msgs msg |
	params := ClaudeMessageRequest new.
	params addUserContent: {
		ClaudeTextBlock text: 'Describe this image'.
		ClaudeImageBlock base64: 'abc123' mediaType: 'image/png' }.
	msgs := params messages.
	self assert: msgs size equals: 1.
	msg := msgs first.
	self assert: (msg isKindOf: ClaudeMessage).
	self assert: msg role equals: 'user'.
	self assert: msg content size equals: 2.
	self assert: msg content first isTextBlock.
	self assert: msg content first text equals: 'Describe this image'.
	self assert: (msg content second isKindOf: ClaudeImageBlock)
]

{ #category : 'tests' }
ClaudeMessageRequestMessagesTest >> testAddUserMessage [
	| params msgs msg |
	params := ClaudeMessageRequest new.
	params addUserMessage: 'What is 2+2?'.
	msgs := params messages.
	self assert: msgs size equals: 1.
	msg := msgs first.
	self assert: (msg isKindOf: ClaudeMessage).
	self assert: msg role equals: 'user'.
	self assert: msg textContent equals: 'What is 2+2?'
]

{ #category : 'tests' }
ClaudeMessageRequestMessagesTest >> testAddUserMessageWithImage [
	| params msgs msg |
	params := ClaudeMessageRequest new.
	params addUserMessage: 'What is this?' withImage: (ClaudeImageBlock base64: 'xyz' mediaType: 'image/jpeg').
	msgs := params messages.
	self assert: msgs size equals: 1.
	msg := msgs first.
	self assert: (msg isKindOf: ClaudeMessage).
	self assert: msg role equals: 'user'.
	self assert: msg content size equals: 2.
	self assert: msg content first isTextBlock.
	self assert: msg content first text equals: 'What is this?'.
	self assert: (msg content second isKindOf: ClaudeImageBlock)
]

{ #category : 'tests' }
ClaudeMessageRequestMessagesTest >> testAddUserMessageWithImages [
	| params msgs msg images |
	params := ClaudeMessageRequest new.
	images := {
		ClaudeImageBlock base64: 'img1' mediaType: 'image/png'.
		ClaudeImageBlock base64: 'img2' mediaType: 'image/gif' }.
	params addUserMessage: 'Compare these' withImages: images.
	msgs := params messages.
	self assert: msgs size equals: 1.
	msg := msgs first.
	self assert: (msg isKindOf: ClaudeMessage).
	self assert: msg role equals: 'user'.
	self assert: msg content size equals: 3.
	self assert: msg content first isTextBlock.
	self assert: msg content first text equals: 'Compare these'.
	self assert: (msg content second isKindOf: ClaudeImageBlock).
	self assert: (msg content third isKindOf: ClaudeImageBlock)
]

{ #category : 'tests' }
ClaudeMessageRequestMessagesTest >> testFromFileCreatesBase64Image [
	| file block source |
	file := '.tmp/test-image.png' asFileReference.
	file parent ensureCreateDirectory.
	PNGReadWriter putForm: (Form extent: 2@2 depth: 32) onFileNamed: file fullName.
	[ block := ClaudeImageBlock fromFile: file.
	self assert: block source isNotNil.
	source := block source.
	self assert: (source at: 'type') equals: 'base64'.
	self assert: (source at: 'media_type') equals: 'image/png'.
	self assert: (source at: 'data') isNotEmpty ]
		ensure: [ file ensureDelete ]
]

{ #category : 'tests' }
ClaudeMessageRequestMessagesTest >> testFromFileDetectsMediaType [
	| file block |
	file := '.tmp/test-image.jpg' asFileReference.
	file parent ensureCreateDirectory.
	file binaryWriteStreamDo: [:s | s nextPutAll: #[255 216 255 224]].
	[ block := ClaudeImageBlock fromFile: file.
	self assert: (block source at: 'media_type') equals: 'image/jpeg' ]
		ensure: [ file ensureDelete ]
]

{ #category : 'tests' }
ClaudeMessageRequestMessagesTest >> testFromFormCreatesBase64Image [
	| form block source |
	form := Form extent: 2@2 depth: 32.
	block := ClaudeImageBlock fromForm: form.
	self assert: block source isNotNil.
	source := block source.
	self assert: (source at: 'type') equals: 'base64'.
	self assert: (source at: 'media_type') equals: 'image/png'.
	self assert: (source at: 'data') isNotEmpty
]

{ #category : 'tests' }
ClaudeMessageRequestMessagesTest >> testTextBlockFactory [
	| block |
	block := ClaudeTextBlock text: 'hello'.
	self assert: block text equals: 'hello'.
	self assert: (block asJson at: 'type') equals: 'text'.
	self assert: (block asJson at: 'text') equals: 'hello'
]

{ #category : 'tests' }
ClaudeMessageRequestMessagesTest >> testTextBlockFromJsonWithCacheControl [
	| json block |
	json := Dictionary newFromPairs: {
		'type'. 'text'.
		'text'. 'hello'.
		'cache_control'. (Dictionary newFromPairs: { 'type'. 'ephemeral' }) }.
	block := ClaudeTextBlock fromJson: json.
	self assert: block text equals: 'hello'.
	self assert: block cacheControl isNotNil.
	self assert: block cacheControl type equals: 'ephemeral'.
	self assert: block cacheControl ttl isNil
]

{ #category : 'tests' }
ClaudeMessageRequestMessagesTest >> testTextBlockFromJsonWithoutCacheControl [
	| json block |
	json := Dictionary newFromPairs: { 'type'. 'text'. 'text'. 'hello' }.
	block := ClaudeTextBlock fromJson: json.
	self assert: block cacheControl isNil
]

{ #category : 'tests' }
ClaudeMessageRequestMessagesTest >> testTextBlockNilCacheControlOmitted [
	| block json |
	block := ClaudeTextBlock text: 'test'.
	json := block asJson.
	self deny: (json includesKey: 'cache_control')
]

{ #category : 'tests' }
ClaudeMessageRequestMessagesTest >> testTextBlockWithCacheControl [
	| block json |
	block := ClaudeTextBlock text: 'test'.
	block cacheControl: ClaudeCacheControl ephemeral.
	json := block asJson.
	self assert: (json at: 'type') equals: 'text'.
	self assert: (json at: 'text') equals: 'test'.
	self assert: ((json at: 'cache_control') at: 'type') equals: 'ephemeral'
]
