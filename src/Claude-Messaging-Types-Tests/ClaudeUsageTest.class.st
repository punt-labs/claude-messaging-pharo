"
Tests for ClaudeUsage JSON serialization and round-trip.
"
Class {
	#name : 'ClaudeUsageTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeUsageTest >> testAsJson [
	| usage json |
	usage := ClaudeUsage new.
	usage inputTokens: 100.
	usage outputTokens: 50.
	usage cacheCreationInputTokens: 200.
	usage cacheReadInputTokens: 75.
	json := usage asJson.
	self assert: (json at: 'input_tokens') equals: 100.
	self assert: (json at: 'output_tokens') equals: 50.
	self assert: (json at: 'cache_creation_input_tokens') equals: 200.
	self assert: (json at: 'cache_read_input_tokens') equals: 75
]

{ #category : 'tests' }
ClaudeUsageTest >> testFromJson [
	| json usage |
	json := Dictionary new.
	json at: 'input_tokens' put: 100.
	json at: 'output_tokens' put: 50.
	json at: 'cache_creation_input_tokens' put: 200.
	json at: 'cache_read_input_tokens' put: 75.
	usage := ClaudeUsage fromJson: json.
	self assert: usage inputTokens equals: 100.
	self assert: usage outputTokens equals: 50.
	self assert: usage cacheCreationInputTokens equals: 200.
	self assert: usage cacheReadInputTokens equals: 75
]

{ #category : 'tests' }
ClaudeUsageTest >> testJsonKeyMap [
  | map |
  map := ClaudeUsage jsonKeyMap.
  self assert: (map at: #inputTokens) equals: 'input_tokens'.
  self assert: (map at: #outputTokens) equals: 'output_tokens'.
  self assert: (map at: #cacheCreationInputTokens) equals: 'cache_creation_input_tokens'.
  self assert: (map at: #cacheReadInputTokens) equals: 'cache_read_input_tokens'.
  self assert: (map at: #inferenceGeo) equals: 'inference_geo'.
  self assert: (map at: #serviceTier) equals: 'service_tier'.
  self assert: map size equals: 6
]

{ #category : 'tests' }
ClaudeUsageTest >> testJsonRoundTrip [
	| original restored |
	original := ClaudeUsage new.
	original inputTokens: 100.
	original outputTokens: 50.
	original cacheCreationInputTokens: 200.
	original cacheReadInputTokens: 75.
	restored := ClaudeUsage fromJson: original asJson.
	self assert: restored inputTokens equals: original inputTokens.
	self assert: restored outputTokens equals: original outputTokens.
	self assert: restored cacheCreationInputTokens equals: original cacheCreationInputTokens.
	self assert: restored cacheReadInputTokens equals: original cacheReadInputTokens
]

{ #category : 'tests' }
ClaudeUsageTest >> testNilOmission [
	| usage json |
	usage := ClaudeUsage new.
	usage inputTokens: 100.
	usage outputTokens: 50.
	json := usage asJson.
	self assert: (json includesKey: 'input_tokens').
	self assert: (json includesKey: 'output_tokens').
	self deny: (json includesKey: 'cache_creation_input_tokens').
	self deny: (json includesKey: 'cache_read_input_tokens')
]

{ #category : 'tests' }
ClaudeUsageTest >> testServiceTierAbsentParsesToNil [
  "Backwards compatibility: existing fromJson: payloads without
   service_tier still parse, with serviceTier nil."
  | json usage |
  json := Dictionary new.
  json at: 'input_tokens' put: 10.
  json at: 'output_tokens' put: 5.
  usage := ClaudeUsage fromJson: json.
  self assert: usage inputTokens equals: 10.
  self assert: usage serviceTier isNil
]

{ #category : 'tests' }
ClaudeUsageTest >> testServiceTierFromJson [
  "usage.service_tier round-trips through fromJson:."
  | json usage |
  json := Dictionary new.
  json at: 'input_tokens' put: 10.
  json at: 'output_tokens' put: 5.
  json at: 'service_tier' put: 'standard'.
  usage := ClaudeUsage fromJson: json.
  self assert: usage serviceTier equals: 'standard'
]

{ #category : 'tests' }
ClaudeUsageTest >> testServiceTierJsonRoundTrip [
  "ClaudeUsage>>serviceTier reports the RESPONSE-side applied tier
   (typically 'standard', 'priority', or 'batch'). It is distinct
   from the REQUEST-side ClaudeServiceTier scheduling-policy catalog
   ('auto', 'standard_only'). The test stores a raw String to keep
   the response-side vocabulary explicit."
  | original restored |
  original := ClaudeUsage new.
  original inputTokens: 10.
  original outputTokens: 5.
  original serviceTier: 'standard'.
  restored := ClaudeUsage fromJson: original asJson.
  self assert: restored serviceTier equals: 'standard'
]
