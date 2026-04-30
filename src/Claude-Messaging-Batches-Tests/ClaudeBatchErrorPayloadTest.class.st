"
Tests for ClaudeBatchErrorPayload fromJson, asJson round-trip, and nil-omitting behavior.

  ClaudeBatchErrorPayloadTest buildSuite run
  >>> 3 run, 3 passes

"
Class {
	#name : 'ClaudeBatchErrorPayloadTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Batches-Tests',
	#package : 'Claude-Messaging-Batches-Tests'
}

{ #category : 'tests' }
ClaudeBatchErrorPayloadTest >> testAsJsonOmitsNil [
	"asJson omits nil-valued slots so partial payloads stay clean."
	| dict |
	dict := ClaudeBatchErrorPayload new asJson.
	self assert: dict isEmpty
]

{ #category : 'tests' }
ClaudeBatchErrorPayloadTest >> testAsJsonRoundTrip [
	| p restored |
	p := ClaudeBatchErrorPayload new
		type: 'api_error';
		message: 'boom';
		yourself.
	restored := ClaudeBatchErrorPayload fromJson: p asJson.
	self assert: restored type equals: 'api_error'.
	self assert: restored message equals: 'boom'
]

{ #category : 'tests' }
ClaudeBatchErrorPayloadTest >> testFromJson [
	| p |
	p := ClaudeBatchErrorPayload fromJson: (Dictionary newFromPairs: {
		'type'. 'invalid_request_error'. 'message'. 'bad' }).
	self assert: p type equals: 'invalid_request_error'.
	self assert: p message equals: 'bad'
]
