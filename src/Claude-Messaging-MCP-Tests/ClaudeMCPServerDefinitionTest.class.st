"
Tests for ClaudeMCPServerDefinition JSON serialization, required + optional fields, forward-compat type discriminator, and forward-compat unknown-field preservation.

  ClaudeMCPServerDefinitionTest buildSuite run
  >>> 11 ran, 11 passed, 0 skipped, 0 expected failures, 0 failures, 0 errors, 0 passed unexpected



"
Class {
	#name : 'ClaudeMCPServerDefinitionTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-MCP-Tests',
	#package : 'Claude-Messaging-MCP-Tests'
}

{ #category : 'tests' }
ClaudeMCPServerDefinitionTest >> testAsJsonRequiresNameAndUrl [
	"Both name and url are required by the wire. The previously-existing guard
	on authorizationToken (omitted when nil) is for an OPTIONAL field; required
	fields raise explicitly to surface bugs early."
	| def |
	def := ClaudeMCPServerDefinition new.
	self should: [ def asJson ] raise: Error.
	def name: 'ex'.
	self should: [ def asJson ] raise: Error.
	def url: 'https://x.com'.
	self shouldnt: [ def asJson ] raise: Error
]

{ #category : 'tests' }
ClaudeMCPServerDefinitionTest >> testAuthorizationTokenOmittedWhenNil [
	| dict |
	dict := (ClaudeMCPServerDefinition name: 'ex' url: 'https://x.com') asJson.
	self deny: (dict includesKey: 'authorization_token')
]

{ #category : 'tests' }
ClaudeMCPServerDefinitionTest >> testAuthorizationTokenSerializedWhenSet [
	| def dict |
	def := ClaudeMCPServerDefinition name: 'ex' url: 'https://x.com'.
	def authorizationToken: 'tok'.
	dict := def asJson.
	self assert: (dict at: 'authorization_token') equals: 'tok'
]

{ #category : 'tests' }
ClaudeMCPServerDefinitionTest >> testFromJsonPreservesUnknownFields [
	"A future transport variant adding fields beyond the five known keys
	 must roundtrip back through asJson. Mirrors the forward-compat strategy
	 ClaudeContentBlock uses for unknown block types — design §1 locked
	 decision 2 in .tmp/missions/9lss-design.md."
	| restored emitted |
	restored := ClaudeMCPServerDefinition fromJson: (Dictionary newFromPairs: {
		'type'. 'url'.
		'name'. 'ex'.
		'url'. 'https://x.com'.
		'experimental_setting'. 42 }).
	self assert: (restored extraFields at: 'experimental_setting') equals: 42.
	emitted := restored asJson.
	self assert: (emitted at: 'experimental_setting') equals: 42
]

{ #category : 'tests' }
ClaudeMCPServerDefinitionTest >> testFromJsonPreservesUnknownTypeForForwardCompat [
	| restored |
	restored := ClaudeMCPServerDefinition fromJson: (Dictionary newFromPairs: {
		'type'. 'stdio'.
		'name'. 'future'.
		'url'. 'ipc:///tmp/x' }).
	self assert: restored type equals: 'stdio'.
	self assert: restored name equals: 'future'
]

{ #category : 'tests' }
ClaudeMCPServerDefinitionTest >> testFullDefinitionRoundtripsThroughAsJsonAndFromJson [
	| original dict restored |
	original := ClaudeMCPServerDefinition name: 'example' url: 'https://x.com/sse'.
	original authorizationToken: 'bearer'.
	original toolConfiguration: (ClaudeMCPToolConfiguration enabled: true allowedTools: #('echo')).
	dict := original asJson.
	restored := ClaudeMCPServerDefinition fromJson: dict.
	self assert: restored name equals: 'example'.
	self assert: restored url equals: 'https://x.com/sse'.
	self assert: restored authorizationToken equals: 'bearer'.
	self assert: restored type equals: 'url'.
	self assert: restored toolConfiguration enabled equals: true.
	self assert: restored toolConfiguration allowedTools equals: #('echo')
]

{ #category : 'tests' }
ClaudeMCPServerDefinitionTest >> testRequiredFieldsSerialize [
	| dict |
	dict := (ClaudeMCPServerDefinition name: 'example' url: 'https://x.com/sse') asJson.
	self assert: (dict at: 'name') equals: 'example'.
	self assert: (dict at: 'url') equals: 'https://x.com/sse'
]

{ #category : 'tests' }
ClaudeMCPServerDefinitionTest >> testRoundtripPreservesUnknownNestedJson [
	"Nested unknown values (Dictionary, Array) must survive the roundtrip
	 unchanged. The preservation is by-reference, so the nested structure
	 itself is unmodified — relevant when downstream consumers read keys
	 like metadata.region after the SDK passed the message through."
	| restored emitted region |
	restored := ClaudeMCPServerDefinition fromJson: (Dictionary newFromPairs: {
		'type'. 'url'.
		'name'. 'ex'.
		'url'. 'https://x.com'.
		'metadata'. (Dictionary newFromPairs: { 'region'. 'us-west' }) }).
	emitted := restored asJson.
	region := (emitted at: 'metadata') at: 'region'.
	self assert: region equals: 'us-west'.
	self assert: (emitted at: 'metadata') class equals: Dictionary
]

{ #category : 'tests' }
ClaudeMCPServerDefinitionTest >> testToolConfigurationOmittedWhenEmpty [
	| def dict |
	def := ClaudeMCPServerDefinition name: 'ex' url: 'https://x.com'.
	def toolConfiguration: ClaudeMCPToolConfiguration new.
	dict := def asJson.
	self deny: (dict includesKey: 'tool_configuration')
]

{ #category : 'tests' }
ClaudeMCPServerDefinitionTest >> testToolConfigurationSerializedWhenNonEmpty [
	| def dict |
	def := ClaudeMCPServerDefinition name: 'ex' url: 'https://x.com'.
	def toolConfiguration: (ClaudeMCPToolConfiguration enabled: true allowedTools: #('echo')).
	dict := def asJson.
	self assert: ((dict at: 'tool_configuration') at: 'enabled') equals: true
]

{ #category : 'tests' }
ClaudeMCPServerDefinitionTest >> testTypeDefaultsToUrl [
	self assert: ClaudeMCPServerDefinition new type equals: 'url'
]
