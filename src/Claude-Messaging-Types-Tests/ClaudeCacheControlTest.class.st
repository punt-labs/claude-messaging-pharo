"
Tests for ClaudeCacheControl -- cache control markers for prompt caching. Covers JSON serialization, round-trip, factory methods, and TTL handling.
"
Class {
	#name : 'ClaudeCacheControlTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeCacheControlTest >> testAsJsonWithTTL [
	| json |
	json := (ClaudeCacheControl ephemeralWithTTL: '1h') asJson.
	self assert: (json at: 'type') equals: 'ephemeral'.
	self assert: (json at: 'ttl') equals: '1h'
]

{ #category : 'tests' }
ClaudeCacheControlTest >> testAsJsonWithoutTTL [
	| json |
	json := ClaudeCacheControl ephemeral asJson.
	self assert: (json at: 'type') equals: 'ephemeral'.
	self deny: (json includesKey: 'ttl')
]

{ #category : 'tests' }
ClaudeCacheControlTest >> testEphemeralFactory [
	| cc |
	cc := ClaudeCacheControl ephemeral.
	self assert: cc type equals: 'ephemeral'.
	self assert: cc ttl isNil
]

{ #category : 'tests' }
ClaudeCacheControlTest >> testEphemeralWithTTLFactory [
	| cc |
	cc := ClaudeCacheControl ephemeralWithTTL: '5m'.
	self assert: cc type equals: 'ephemeral'.
	self assert: cc ttl equals: '5m'
]

{ #category : 'tests' }
ClaudeCacheControlTest >> testFromJsonRoundTrip [
	| original json restored |
	original := ClaudeCacheControl ephemeralWithTTL: '5m'.
	json := original asJson.
	restored := ClaudeCacheControl fromJson: json.
	self assert: restored type equals: 'ephemeral'.
	self assert: restored ttl equals: '5m'
]

{ #category : 'tests' }
ClaudeCacheControlTest >> testFromJsonWithoutTTL [
	| json restored |
	json := Dictionary newFromPairs: { 'type'. 'ephemeral' }.
	restored := ClaudeCacheControl fromJson: json.
	self assert: restored type equals: 'ephemeral'.
	self assert: restored ttl isNil
]

{ #category : 'tests' }
ClaudeCacheControlTest >> testPrintOn [
	| cc |
	cc := ClaudeCacheControl ephemeral.
	self assert: cc printString equals: 'ClaudeCacheControl(ephemeral)'.
	cc := ClaudeCacheControl ephemeralWithTTL: '5m'.
	self assert: cc printString equals: 'ClaudeCacheControl(ephemeral ttl: 5m)'
]
