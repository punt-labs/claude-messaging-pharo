"
Tests for ClaudeRequestOptions, focusing on beta feature flag serialization, header generation, and MCP server serialization.

  ClaudeRequestOptionsTest buildSuite run
  >>> 18 ran, 18 passed, 0 skipped, 0 expected failures, 0 failures, 0 errors, 0 passed unexpected


"
Class {
	#name : 'ClaudeRequestOptionsTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeRequestOptionsTest >> testBetaHeaderJoinsWithComma [
	| opts |
	opts := ClaudeRequestOptions new.
	opts betas: #('pdfs-2024-09-25' 'output-128k-2025-02-19').
	self assert: opts betaHeader equals: 'pdfs-2024-09-25,output-128k-2025-02-19'
]

{ #category : 'tests' }
ClaudeRequestOptionsTest >> testBetaHeaderNilWhenEmptyBetas [
	| opts |
	opts := ClaudeRequestOptions new.
	opts betas: #().
	self assert: opts betaHeader isNil
]

{ #category : 'tests' }
ClaudeRequestOptionsTest >> testBetaHeaderNilWhenNoBetas [
	| opts |
	opts := ClaudeRequestOptions new.
	self assert: opts betaHeader isNil
]

{ #category : 'tests' }
ClaudeRequestOptionsTest >> testBetaHeaderSingleBeta [
	| opts |
	opts := ClaudeRequestOptions new.
	opts betas: #('pdfs-2024-09-25').
	self assert: opts betaHeader equals: 'pdfs-2024-09-25'
]

{ #category : 'tests' }
ClaudeRequestOptionsTest >> testContainerAcceptsClaudeContainerParams [
	| opts dict containerDict |
	opts := ClaudeRequestOptions new.
	opts container: (ClaudeContainerParams new id: 'ctr_abc'; yourself).
	dict := OrderedDictionary new.
	opts addFieldsTo: dict.
	containerDict := dict at: 'container'.
	self assert: (containerDict isKindOf: OrderedDictionary).
	self assert: (containerDict at: 'id') equals: 'ctr_abc'
]

{ #category : 'tests' }
ClaudeRequestOptionsTest >> testContainerAcceptsString [
	| opts dict |
	opts := ClaudeRequestOptions new.
	opts container: 'ctr_abc'.
	dict := OrderedDictionary new.
	opts addFieldsTo: dict.
	self assert: (dict at: 'container') equals: 'ctr_abc'.
	self assert: (dict at: 'container') isString
]

{ #category : 'tests' }
ClaudeRequestOptionsTest >> testContainerStringAndParamsProduceDifferentJsonShapes [
	| stringOpts paramsOpts stringDict paramsDict |
	stringOpts := ClaudeRequestOptions new container: 'ctr'; yourself.
	paramsOpts := ClaudeRequestOptions new container: (ClaudeContainerParams new id: 'ctr'); yourself.
	stringDict := OrderedDictionary new.
	paramsDict := OrderedDictionary new.
	stringOpts addFieldsTo: stringDict.
	paramsOpts addFieldsTo: paramsDict.
	self assert: (stringDict at: 'container') isString.
	self deny: (paramsDict at: 'container') isString.
	self assert: ((paramsDict at: 'container') isKindOf: OrderedDictionary)
]

{ #category : 'tests' }
ClaudeRequestOptionsTest >> testContainerValidatesType [
	"Setter rejects anything that is not a String, ClaudeContainerParams, or
	 nil so callers fail fast on misuse instead of getting a doesNotUnderstand:
	 deep inside addFieldsTo:."
	| opts |
	opts := ClaudeRequestOptions new.
	self should: [ opts container: 42 ] raise: Error.
	self should: [ opts container: (Dictionary new) ] raise: Error.
	"All three accepted shapes must round-trip without raising:"
	opts container: 'ctr_abc'.
	opts container: (ClaudeContainerParams new id: 'ctr').
	opts container: nil
]

{ #category : 'tests' }
ClaudeRequestOptionsTest >> testEagerInputStreamingAddFieldsTo [
	| options dict |
	options := ClaudeRequestOptions new.
	options eagerInputStreaming: true.
	dict := Dictionary new.
	options addFieldsTo: dict.
	self assert: (dict at: 'eager_input_streaming') equals: true
]

{ #category : 'tests' }
ClaudeRequestOptionsTest >> testEagerInputStreamingNilOmitted [
	| options dict |
	options := ClaudeRequestOptions new.
	dict := Dictionary new.
	options addFieldsTo: dict.
	self deny: (dict includesKey: 'eager_input_streaming')
]

{ #category : 'tests' }
ClaudeRequestOptionsTest >> testEagerInputStreamingSerialization [
	| request json |
	request := ClaudeMessageRequest new
		model: 'claude-sonnet-4-20250514';
		maxTokens: 100;
		addUserMessage: 'hi'.
	request requestOptions eagerInputStreaming: true.
	json := request asJson.
	self assert: (json at: 'eager_input_streaming') equals: true
]

{ #category : 'tests' }
ClaudeRequestOptionsTest >> testHasBetasFalseByDefault [
	self deny: ClaudeRequestOptions new hasBetas
]

{ #category : 'tests' }
ClaudeRequestOptionsTest >> testHasBetasTrueWhenSet [
	| opts |
	opts := ClaudeRequestOptions new.
	opts betas: #('pdfs-2024-09-25').
	self assert: opts hasBetas
]

{ #category : 'tests' }
ClaudeRequestOptionsTest >> testMcpServersNormalizesEmptyToNil [
	"Empty collection is normalized to nil — empty means unset for this field,
	 consistent with the Go SDK omitzero semantic for mcp_servers. Pin the
	 contract at the setter so addFieldsTo: cannot drift apart from accessor
	 reads in the future."
	| opts |
	opts := ClaudeRequestOptions new.
	opts mcpServers: #().
	self assert: opts mcpServers isNil.
	opts mcpServers: nil.
	self assert: opts mcpServers isNil.
	opts mcpServers: { ClaudeMCPServerDefinition name: 'x' url: 'https://y.com' }.
	self assert: opts mcpServers size equals: 1
]

{ #category : 'tests' }
ClaudeRequestOptionsTest >> testMcpServersOmittedWhenEmpty [
	| opts dict |
	opts := ClaudeRequestOptions new.
	opts mcpServers: #().
	dict := OrderedDictionary new.
	opts addFieldsTo: dict.
	self deny: (dict includesKey: 'mcp_servers')
]

{ #category : 'tests' }
ClaudeRequestOptionsTest >> testMcpServersOmittedWhenNil [
	| opts dict |
	opts := ClaudeRequestOptions new.
	dict := OrderedDictionary new.
	opts addFieldsTo: dict.
	self deny: (dict includesKey: 'mcp_servers')
]

{ #category : 'tests' }
ClaudeRequestOptionsTest >> testMcpServersSerializedWhenSet [
	| opts dict mcp |
	opts := ClaudeRequestOptions new.
	opts mcpServers: { ClaudeMCPServerDefinition name: 'example' url: 'https://x.com' }.
	dict := OrderedDictionary new.
	opts addFieldsTo: dict.
	mcp := dict at: 'mcp_servers'.
	self assert: mcp size equals: 1.
	self assert: (mcp first at: 'name') equals: 'example'.
	self assert: (mcp first at: 'url') equals: 'https://x.com'
]

{ #category : 'tests' }
ClaudeRequestOptionsTest >> testRequestOptionsAddFieldsTo [
	| ro dict |
	ro := ClaudeRequestOptions new.
	ro serviceTier: 'priority'.
	dict := OrderedDictionary new.
	ro addFieldsTo: dict.
	self assert: (dict at: 'service_tier') equals: 'priority'.
	self deny: (dict includesKey: 'metadata').
	self deny: (dict includesKey: 'cache_control')
]

{ #category : 'tests' }
ClaudeRequestOptionsTest >> testRequestOptionsJsonKeyMap [
	| map |
	map := ClaudeRequestOptions jsonKeyMap.
	self assert: (map at: #cacheControl) equals: 'cache_control'.
	self assert: (map at: #serviceTier) equals: 'service_tier'.
	self assert: (map at: #eagerInputStreaming) equals: 'eager_input_streaming'.
	self assert: (map at: #betas) equals: 'betas'.
	self assert: (map at: #stream) equals: 'stream'.
	self assert: (map at: #inferenceGeo) equals: 'inference_geo'.
	self assert: (map at: #container) equals: 'container'.
	self assert: (map at: #speed) equals: 'speed'.
	self assert: (map at: #mcpServers) equals: 'mcp_servers'.
	self assert: map size equals: 9
]

{ #category : 'tests' }
ClaudeRequestOptionsTest >> testStreamAddFieldsTo [
	| opts dict |
	opts := ClaudeRequestOptions new.
	opts stream: true.
	dict := Dictionary new.
	opts addFieldsTo: dict.
	self assert: (dict at: 'stream') equals: true
]

{ #category : 'tests' }
ClaudeRequestOptionsTest >> testStreamDelegationFromRequest [
	| req |
	req := ClaudeMessageRequest new model: 'test'; maxTokens: 100.
	req stream: true.
	self assert: req stream equals: true.
	self assert: req requestOptions stream equals: true
]

{ #category : 'tests' }
ClaudeRequestOptionsTest >> testStreamOmittedWhenNotSet [
	| opts dict |
	opts := ClaudeRequestOptions new.
	dict := Dictionary new.
	opts addFieldsTo: dict.
	self deny: (dict includesKey: 'stream')
]
