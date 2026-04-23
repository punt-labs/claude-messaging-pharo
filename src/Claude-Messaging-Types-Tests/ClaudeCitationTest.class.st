"
Tests for ClaudeCitation — citation references on text blocks.
"
Class {
	#name : 'ClaudeCitationTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeCitationTest >> testCitationAsJson [
	| citation json |
	citation := ClaudeCitation new
		citedText: 'hello world';
		documentIndex: 2;
		documentTitle: 'My Doc';
		startCharIndex: 5;
		endCharIndex: 15.
	json := citation asJson.
	self assert: (json at: 'type') equals: 'char_location'.
	self assert: (json at: 'cited_text') equals: 'hello world'.
	self assert: (json at: 'document_index') equals: 2.
	self assert: (json at: 'document_title') equals: 'My Doc'.
	self assert: (json at: 'start_char_index') equals: 5.
	self assert: (json at: 'end_char_index') equals: 15
]

{ #category : 'tests' }
ClaudeCitationTest >> testCitationFromJson [
	| dict citation |
	dict := Dictionary new.
	dict at: 'cited_text' put: 'some text'.
	dict at: 'document_index' put: 0.
	dict at: 'document_title' put: 'Doc'.
	dict at: 'start_char_index' put: 10.
	dict at: 'end_char_index' put: 20.
	citation := ClaudeCitation fromJson: dict.
	self assert: citation citedText equals: 'some text'.
	self assert: citation documentIndex equals: 0.
	self assert: citation documentTitle equals: 'Doc'.
	self assert: citation startCharIndex equals: 10.
	self assert: citation endCharIndex equals: 20
]

{ #category : 'tests' }
ClaudeCitationTest >> testCitationJsonKeyMap [
	| map |
	map := ClaudeCitation jsonKeyMap.
	self assert: (map at: #citedText) equals: 'cited_text'.
	self assert: (map at: #documentIndex) equals: 'document_index'.
	self assert: (map at: #documentTitle) equals: 'document_title'.
	self assert: (map at: #startCharIndex) equals: 'start_char_index'.
	self assert: (map at: #endCharIndex) equals: 'end_char_index'.
	self assert: map size equals: 5
]

{ #category : 'tests' }
ClaudeCitationTest >> testCitationRoundTrip [
	| original json restored |
	original := ClaudeCitation new
		citedText: 'round trip text';
		documentIndex: 3;
		documentTitle: 'Source Doc';
		startCharIndex: 100;
		endCharIndex: 200.
	json := original asJson.
	restored := ClaudeCitation fromJson: json.
	self assert: restored citedText equals: original citedText.
	self assert: restored documentIndex equals: original documentIndex.
	self assert: restored documentTitle equals: original documentTitle.
	self assert: restored startCharIndex equals: original startCharIndex.
	self assert: restored endCharIndex equals: original endCharIndex
]

{ #category : 'tests' }
ClaudeCitationTest >> testTextBlockFromJsonWithCitations [
	| citDict json block citations |
	citDict := Dictionary new.
	citDict at: 'cited_text' put: 'some text'.
	citDict at: 'document_index' put: 0.
	citDict at: 'document_title' put: 'Doc'.
	citDict at: 'start_char_index' put: 10.
	citDict at: 'end_char_index' put: 20.
	json := Dictionary new.
	json at: 'type' put: 'text'.
	json at: 'text' put: 'hello'.
	json at: 'citations' put: { citDict }.
	block := ClaudeTextBlock fromJson: json.
	self assert: block text equals: 'hello'.
	citations := block citations.
	self assert: citations size equals: 1.
	self assert: citations first class equals: ClaudeCitation.
	self assert: citations first citedText equals: 'some text'.
	self assert: citations first documentIndex equals: 0.
	self assert: citations first documentTitle equals: 'Doc'
]

{ #category : 'tests' }
ClaudeCitationTest >> testTextBlockWithCitations [
	| block citation json parsedCitations |
	citation := ClaudeCitation new
		citedText: 'cited';
		documentIndex: 1;
		documentTitle: 'Title';
		startCharIndex: 0;
		endCharIndex: 5.
	block := ClaudeTextBlock text: 'hello'.
	block citations: (OrderedCollection with: citation).
	json := block asJson.
	self assert: (json at: 'type') equals: 'text'.
	self assert: (json at: 'text') equals: 'hello'.
	parsedCitations := json at: 'citations'.
	self assert: parsedCitations size equals: 1.
	self assert: (parsedCitations first at: 'cited_text') equals: 'cited'
]

{ #category : 'tests' }
ClaudeCitationTest >> testTextBlockWithoutCitations [
	| block json |
	block := ClaudeTextBlock text: 'no citations'.
	json := block asJson.
	self assert: (json at: 'type') equals: 'text'.
	self assert: (json at: 'text') equals: 'no citations'.
	self deny: (json includesKey: 'citations')
]
