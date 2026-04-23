"
Tests for ClaudeStopDetails construction, JSON serialization, nil field omission, and STON round-trip.
"
Class {
	#name : 'ClaudeStopDetailsTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeStopDetailsTest >> testAsJson [
	| sd json |
	sd := ClaudeStopDetails new.
	sd stopReason: 'end_turn'.
	json := sd asJson.
	self assert: (json at: 'stop_reason') equals: 'end_turn'.
	self assert: (json at: 'stop_reason') isString.
	self deny: (json includesKey: 'stop_sequence').
	self deny: (json includesKey: 'stop_details')
]

{ #category : 'tests' }
ClaudeStopDetailsTest >> testAsJsonWithRefusal [
	| sd json details |
	sd := ClaudeStopDetails new.
	sd stopReason: 'end_turn'.
	sd category: 'bio'.
	sd explanation: 'Refused'.
	json := sd asJson.
	self assert: (json at: 'stop_reason') equals: 'end_turn'.
	self assert: (json at: 'stop_reason') isString.
	details := json at: 'stop_details'.
	self assert: (details at: 'type') equals: 'refusal'.
	self assert: (details at: 'category') equals: 'bio'.
	self assert: (details at: 'explanation') equals: 'Refused'
]

{ #category : 'tests' }
ClaudeStopDetailsTest >> testConstruction [
	| sd |
	sd := ClaudeStopDetails new.
	sd stopReason: 'end_turn'.
	sd stopSequence: nil.
	sd category: 'cyber'.
	sd explanation: 'Refused due to policy'.
	self assert: sd stopReason equals: #end_turn.
	self assert: sd stopSequence isNil.
	self assert: sd category equals: 'cyber'.
	self assert: sd explanation equals: 'Refused due to policy'
]

{ #category : 'tests' }
ClaudeStopDetailsTest >> testFromJson [
	| json sd |
	json := Dictionary new.
	json at: 'stop_reason' put: 'end_turn'.
	json at: 'stop_sequence' put: nil.
	sd := ClaudeStopDetails fromJson: json.
	self assert: sd stopReason equals: #end_turn.
	self assert: sd stopSequence isNil.
	self assert: sd category isNil.
	self assert: sd explanation isNil
]

{ #category : 'tests' }
ClaudeStopDetailsTest >> testFromJsonWithStopDetails [
	| json sd |
	json := Dictionary new.
	json at: 'stop_reason' put: 'end_turn'.
	json at: 'stop_sequence' put: nil.
	json at: 'stop_details' put: (Dictionary newFromPairs: {
		'type'. 'refusal'.
		'category'. 'cyber'.
		'explanation'. 'Refused due to policy' }).
	sd := ClaudeStopDetails fromJson: json.
	self assert: sd stopReason equals: #end_turn.
	self assert: sd category equals: 'cyber'.
	self assert: sd explanation equals: 'Refused due to policy'
]

{ #category : 'tests' }
ClaudeStopDetailsTest >> testJsonRoundTrip [
	| original json restored |
	original := ClaudeStopDetails new.
	original stopReason: 'end_turn'.
	original category: 'cyber'.
	original explanation: 'Policy violation'.
	json := original asJson.
	restored := ClaudeStopDetails fromJson: json.
	self assert: restored stopReason equals: #end_turn.
	self assert: restored category equals: 'cyber'.
	self assert: restored explanation equals: 'Policy violation'
]

{ #category : 'tests' }
ClaudeStopDetailsTest >> testNilFieldsOmitted [
	| sd json |
	sd := ClaudeStopDetails new.
	sd stopReason: 'end_turn'.
	json := sd asJson.
	self assert: (json includesKey: 'stop_reason').
	self deny: (json includesKey: 'stop_sequence').
	self deny: (json includesKey: 'stop_details')
]

{ #category : 'tests' }
ClaudeStopDetailsTest >> testStonRoundTrip [
	| original ston restored |
	original := ClaudeStopDetails new.
	original stopReason: 'end_turn'.
	original category: 'cyber'.
	original explanation: 'Refused'.
	ston := STON toString: original.
	restored := STON fromString: ston.
	self assert: restored stopReason equals: #end_turn.
	self assert: restored category equals: 'cyber'.
	self assert: restored explanation equals: 'Refused'
]
