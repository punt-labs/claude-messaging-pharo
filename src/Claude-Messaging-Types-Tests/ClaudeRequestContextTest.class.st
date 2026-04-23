"
Tests for ClaudeRequestContext construction, accessors, JSON exclusion, and STON round-trip.
"
Class {
	#name : 'ClaudeRequestContextTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeRequestContextTest >> testAccessors [
  | ctx |
  ctx := ClaudeRequestContext new.
  self assert: ctx outputFormat isNil.
  ctx outputFormat: ClaudeTextOutputFormat new.
  self assert: ctx outputFormat class equals: ClaudeTextOutputFormat
]

{ #category : 'tests' }
ClaudeRequestContextTest >> testConstruction [
  | ctx |
  ctx := ClaudeRequestContext new.
  ctx outputFormat: ClaudeTextOutputFormat new.
  self assert: ctx outputFormat class equals: ClaudeTextOutputFormat
]

{ #category : 'tests' }
ClaudeRequestContextTest >> testNoRequestIdSlot [
  "requestId migrated to ClaudeResponseMetadata in mission yvyt+pch2.
   The slot and its accessors must be gone from ClaudeRequestContext."
  self deny: (ClaudeRequestContext canUnderstand: #requestId).
  self deny: (ClaudeRequestContext canUnderstand: #requestId:).
  self deny: (ClaudeRequestContext instVarNames includes: #requestId)
]

{ #category : 'tests' }
ClaudeRequestContextTest >> testNotInJson [
	"ClaudeRequestContext is transport metadata, not serialized in JSON.
	Verify no asJson or fromJson: are implemented."
	self deny: (ClaudeRequestContext canUnderstand: #asJson).
	self deny: (ClaudeRequestContext class canUnderstand: #fromJson:)
]

{ #category : 'tests' }
ClaudeRequestContextTest >> testPrintOnEmpty [
  "Empty context prints with bare ?, no quote delimiters around it.
   Sibling pattern in ClaudeResponseMetadata>>printOn: also renders
   missing slots as a bare ?."
  self assert: ClaudeRequestContext new printString equals: 'ClaudeRequestContext(?)'
]

{ #category : 'tests' }
ClaudeRequestContextTest >> testPrintOnWithOutputFormat [
  "Non-nil outputFormat renders via its own printString without extra
   quote delimiters."
  | ctx |
  ctx := ClaudeRequestContext new outputFormat: ClaudeTextOutputFormat new; yourself.
  self assert: ctx printString equals: 'ClaudeRequestContext(ClaudeTextOutputFormat(text))'
]

{ #category : 'tests' }
ClaudeRequestContextTest >> testStonRoundTrip [
  "requestId migrated to ClaudeResponseMetadata in mission yvyt+pch2;
   only outputFormat survives the round-trip on this class."
  | original ston restored |
  original := ClaudeRequestContext new.
  original outputFormat: ClaudeTextOutputFormat new.
  ston := STON toString: original.
  restored := STON fromString: ston.
  self assert: restored outputFormat class equals: ClaudeTextOutputFormat
]
