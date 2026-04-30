"
Structural tests for ClaudeMessagingBatchesExample. Verifies the build helper
shape, JSON round-trip stability for the create-params payload, and that the
example class implements the required entry points. The end-to-end create ->
poll -> stream behaviour is covered by ClaudeBatchClientTest in
Claude-Messaging-Batches-Tests against ClaudeMockServer; that wire-level
coverage is the durable spec, so this test class focuses on the example-shape
guarantees that the doctests in the class comment depend on.

  ClaudeMessagingBatchesExampleTest buildSuite tests size
  >>> 5

"
Class {
	#name : 'ClaudeMessagingBatchesExampleTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Examples-Tests',
	#package : 'Claude-Messaging-Examples-Tests'
}

{ #category : 'tests' }
ClaudeMessagingBatchesExampleTest >> testBuildSampleCreateParamsAsJsonRoundTrip [
	"asJson round-trip stability for the wire payload. Each request entry preserves
	 its custom_id, and the params dict carries a non-empty messages array. The full
	 ClaudeMessageRequest fromJson: round-trip is a non-goal of this SDK
	 (ClaudeBatchRequest fromJson: keeps params as the raw Dictionary), so we
	 inspect the wire shape directly rather than rebuilding the object graph."
	| params json requestsArr first |
	params := ClaudeMessagingBatchesExample buildSampleCreateParams.
	json := params asJson.
	requestsArr := json at: 'requests'.
	self assert: requestsArr size equals: 2.
	first := requestsArr first.
	self assert: (first at: 'custom_id') equals: 'r-1'.
	self assert: ((first at: 'params') at: 'messages') notEmpty.
	self assert: ((first at: 'params') at: 'model') equals: 'claude-haiku-4-5-20251001'.
	self assert: ((requestsArr second) at: 'custom_id') equals: 'r-2'
]

{ #category : 'tests' }
ClaudeMessagingBatchesExampleTest >> testBuildSampleCreateParamsHasTwoRequestsWithExpectedIds [
	"Build helper shape: 2 requests, custom_ids r-1 and r-2 in submission order."
	| params |
	params := ClaudeMessagingBatchesExample buildSampleCreateParams.
	self assert: params size equals: 2.
	self assert: params requests first customId equals: 'r-1'.
	self assert: params requests second customId equals: 'r-2'
]

{ #category : 'tests' }
ClaudeMessagingBatchesExampleTest >> testBuildSampleCreateParamsUsesHaikuAndSmallMaxTokens [
	"Build helper uses Haiku 4.5 and a tiny maxTokens so live runs stay cheap and fast."
	| params first |
	params := ClaudeMessagingBatchesExample buildSampleCreateParams.
	first := params requests first.
	self assert: first params model equals: ClaudeModel haiku45.
	self assert: first params maxTokens equals: 64.
	self assert: params requests second params model equals: ClaudeModel haiku45.
	self assert: params requests second params maxTokens equals: 64
]

{ #category : 'tests' }
ClaudeMessagingBatchesExampleTest >> testClassImplementsRunOn [
	"runOn: is the public entry that takes a ClaudeClient and drives the full
	 create -> poll -> stream loop. Asserting the selector exists on the class
	 side keeps the example-shape contract enforced even when the body changes."
	self assert: (ClaudeMessagingBatchesExample class includesSelector: #runOn:)
]

{ #category : 'tests' }
ClaudeMessagingBatchesExampleTest >> testClassImplementsRunWithoutArgs [
	"run is the convenience entry that resolves a client from the keyring or env
	 and delegates to runOn:. Asserting the selector exists keeps the example-shape
	 contract enforced even when the body changes."
	self assert: (ClaudeMessagingBatchesExample class includesSelector: #run)
]
