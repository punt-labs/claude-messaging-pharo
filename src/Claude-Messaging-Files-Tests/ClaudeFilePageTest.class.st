"
Tests for ClaudeFilePage JSON parsing and round-trip.
"
Class {
	#name : 'ClaudeFilePageTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Files-Tests',
	#package : 'Claude-Messaging-Files-Tests'
}

{ #category : 'tests' }
ClaudeFilePageTest >> testAsJsonRoundTrip [
	| json fileJson page restored |
	fileJson := Dictionary new.
	fileJson at: 'id' put: 'file-2'.
	fileJson at: 'filename' put: 'b.txt'.
	json := Dictionary new.
	json at: 'data' put: { fileJson }.
	json at: 'has_more' put: false.
	page := ClaudeFilePage fromJson: json.
	restored := page asJson.
	self assert: (restored at: 'data') size equals: 1.
	self assert: ((restored at: 'data') first at: 'id') equals: 'file-2'.
	self assert: (restored at: 'has_more') equals: false
]

{ #category : 'tests' }
ClaudeFilePageTest >> testConstruction [
	| page |
	page := ClaudeFilePage new.
	self assert: page data equals: #().
	self assert: page hasMore equals: false.
	self assert: page firstId isNil.
	self assert: page lastId isNil
]

{ #category : 'tests' }
ClaudeFilePageTest >> testFromJsonEmptyPage [
	| json page |
	json := Dictionary new.
	page := ClaudeFilePage fromJson: json.
	self assert: page data size equals: 0.
	self assert: page hasMore equals: false
]

{ #category : 'tests' }
ClaudeFilePageTest >> testFromJsonParsesMetadataArray [
	| json fileJson page |
	fileJson := Dictionary new.
	fileJson at: 'id' put: 'file-1'.
	fileJson at: 'filename' put: 'a.pdf'.
	json := Dictionary new.
	json at: 'data' put: { fileJson }.
	json at: 'has_more' put: true.
	json at: 'first_id' put: 'file-1'.
	json at: 'last_id' put: 'file-1'.
	page := ClaudeFilePage fromJson: json.
	self assert: page data size equals: 1.
	self assert: (page data first isKindOf: ClaudeFileMetadata).
	self assert: page data first id equals: 'file-1'.
	self assert: page hasMore equals: true.
	self assert: page firstId equals: 'file-1'.
	self assert: page lastId equals: 'file-1'
]
