"
Tests for ClaudeSamplingParams — temperature, topP, topK, stopSequences serialization.
"
Class {
	#name : 'ClaudeSamplingParamsTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeSamplingParamsTest >> testSamplingParamsAddFieldsTo [
	| s dict |
	s := ClaudeSamplingParams new.
	s temperature: 0.7.
	s topP: 0.9.
	dict := OrderedDictionary new.
	s addFieldsTo: dict.
	self assert: (dict at: 'temperature') equals: 0.7.
	self assert: (dict at: 'top_p') equals: 0.9.
	self deny: (dict includesKey: 'top_k').
	self deny: (dict includesKey: 'stop_sequences')
]

{ #category : 'tests' }
ClaudeSamplingParamsTest >> testSamplingParamsJsonKeyMap [
	| map |
	map := ClaudeSamplingParams jsonKeyMap.
	self assert: (map at: #topP) equals: 'top_p'.
	self assert: (map at: #topK) equals: 'top_k'.
	self assert: (map at: #stopSequences) equals: 'stop_sequences'.
	self assert: map size equals: 3
]
