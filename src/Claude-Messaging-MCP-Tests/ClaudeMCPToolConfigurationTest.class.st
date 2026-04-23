"
Tests for ClaudeMCPToolConfiguration JSON serialization, field handling, and forward-compat unknown-field preservation.

  ClaudeMCPToolConfigurationTest buildSuite run
  >>> 8 ran, 8 passed, 0 skipped, 0 expected failures, 0 failures, 0 errors, 0 passed unexpected


"
Class {
	#name : 'ClaudeMCPToolConfigurationTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-MCP-Tests',
	#package : 'Claude-Messaging-MCP-Tests'
}

{ #category : 'tests' }
ClaudeMCPToolConfigurationTest >> testAllowedToolsOnlySerializesArray [
	| dict |
	dict := (ClaudeMCPToolConfiguration new allowedTools: #('echo' 'add')) asJson.
	self assert: (dict at: 'allowed_tools') equals: #('echo' 'add').
	self deny: (dict includesKey: 'enabled')
]

{ #category : 'tests' }
ClaudeMCPToolConfigurationTest >> testEmptyConfigSerializesToEmptyDict [
	self assert: ClaudeMCPToolConfiguration new asJson isEmpty
]

{ #category : 'tests' }
ClaudeMCPToolConfigurationTest >> testEnabledOnlySerializesEnabled [
	| dict |
	dict := (ClaudeMCPToolConfiguration new enabled: true) asJson.
	self assert: (dict at: 'enabled') equals: true.
	self deny: (dict includesKey: 'allowed_tools')
]

{ #category : 'tests' }
ClaudeMCPToolConfigurationTest >> testFromJsonAcceptsMissingAllowedTools [
	| restored |
	restored := ClaudeMCPToolConfiguration fromJson: (Dictionary newFromPairs: { 'enabled'. true }).
	self assert: restored enabled equals: true.
	self assert: restored allowedTools isNil
]

{ #category : 'tests' }
ClaudeMCPToolConfigurationTest >> testFromJsonAcceptsMissingEnabled [
	| restored |
	restored := ClaudeMCPToolConfiguration fromJson: (Dictionary newFromPairs: { 'allowed_tools'. #('echo') }).
	self assert: restored enabled isNil.
	self assert: restored allowedTools equals: #('echo')
]

{ #category : 'tests' }
ClaudeMCPToolConfigurationTest >> testFromJsonPreservesUnknownFields [
	"A future per-server tool config field beyond enabled/allowed_tools must
	 roundtrip back through asJson. Mirrors the forward-compat strategy
	 ClaudeMCPServerDefinition uses on its parent dict."
	| restored emitted |
	restored := ClaudeMCPToolConfiguration fromJson: (Dictionary newFromPairs: {
		'enabled'. true.
		'allowed_tools'. #('echo').
		'experimental_setting'. 42 }).
	self assert: (restored extraFields at: 'experimental_setting') equals: 42.
	emitted := restored asJson.
	self assert: (emitted at: 'experimental_setting') equals: 42
]

{ #category : 'tests' }
ClaudeMCPToolConfigurationTest >> testFullConfigRoundtripsThroughAsJsonAndFromJson [
	| original dict restored |
	original := ClaudeMCPToolConfiguration enabled: true allowedTools: #('echo').
	dict := original asJson.
	restored := ClaudeMCPToolConfiguration fromJson: dict.
	self assert: restored enabled equals: true.
	self assert: restored allowedTools equals: #('echo')
]

{ #category : 'tests' }
ClaudeMCPToolConfigurationTest >> testRoundtripPreservesUnknownNestedJson [
	"Nested unknown values (Dictionary, Array) must survive the roundtrip
	 unchanged. Preservation is by-reference, so the nested structure
	 itself is unmodified — relevant when downstream consumers read keys
	 like metadata.region after the SDK passed the message through."
	| restored emitted region |
	restored := ClaudeMCPToolConfiguration fromJson: (Dictionary newFromPairs: {
		'enabled'. true.
		'metadata'. (Dictionary newFromPairs: { 'region'. 'us-west' }) }).
	emitted := restored asJson.
	region := (emitted at: 'metadata') at: 'region'.
	self assert: region equals: 'us-west'.
	self assert: (emitted at: 'metadata') class equals: Dictionary
]
