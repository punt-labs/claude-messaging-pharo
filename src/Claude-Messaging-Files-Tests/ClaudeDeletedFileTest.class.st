"
Tests for ClaudeDeletedFile JSON round-trip and default type.
"
Class {
	#name : 'ClaudeDeletedFileTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Files-Tests',
	#package : 'Claude-Messaging-Files-Tests'
}

{ #category : 'tests' }
ClaudeDeletedFileTest >> testConstruction [
	| d |
	d := ClaudeDeletedFile new.
	d id: 'file-abc'.
	self assert: d id equals: 'file-abc'.
	self assert: d type equals: 'file_deleted'
]

{ #category : 'tests' }
ClaudeDeletedFileTest >> testDefaultType [
	| d |
	d := ClaudeDeletedFile new.
	self assert: d type equals: 'file_deleted'
]

{ #category : 'tests' }
ClaudeDeletedFileTest >> testFromJsonRoundTrip [
	| json original restored |
	json := Dictionary new.
	json at: 'id' put: 'file-xyz'.
	json at: 'type' put: 'file_deleted'.
	original := ClaudeDeletedFile fromJson: json.
	restored := original asJson.
	self assert: (restored at: 'id') equals: 'file-xyz'.
	self assert: (restored at: 'type') equals: 'file_deleted'
]
