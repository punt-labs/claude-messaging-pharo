"
Tests for ClaudeThinkingParams — enabled/disabled/adaptive thinking configuration, serialization, and round-trip.
"
Class {
	#name : 'ClaudeThinkingParamsTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeThinkingParamsTest >> testAdaptiveThinkingAddFieldsTo [
	| tp dict thinkingDict |
	tp := ClaudeThinkingParams adaptive.
	dict := OrderedDictionary new.
	tp addFieldsTo: dict.
	thinkingDict := dict at: 'thinking'.
	self assert: (thinkingDict at: 'type') equals: 'adaptive'.
	self deny: (thinkingDict includesKey: 'budget_tokens').
	self deny: (thinkingDict includesKey: 'display')
]

{ #category : 'tests' }
ClaudeThinkingParamsTest >> testAdaptiveThinkingAsDictionary [
	| d |
	d := ClaudeThinkingParams adaptive asDictionary.
	self assert: (d at: 'type') equals: 'adaptive'.
	self deny: (d includesKey: 'budget_tokens').
	self deny: (d includesKey: 'display')
]

{ #category : 'tests' }
ClaudeThinkingParamsTest >> testAdaptiveThinkingFromDictionary [
	| tp d |
	d := Dictionary newFromPairs: { 'type'. 'adaptive' }.
	tp := ClaudeThinkingParams new.
	tp fromDictionary: d.
	self assert: tp type equals: 'adaptive'.
	self assert: tp budgetTokens isNil.
	self assert: tp display isNil
]

{ #category : 'tests' }
ClaudeThinkingParamsTest >> testAdaptiveThinkingRoundTrip [
	| tp d restored |
	tp := ClaudeThinkingParams adaptiveWithDisplay: 'summarized'.
	d := tp asDictionary.
	restored := ClaudeThinkingParams new.
	restored fromDictionary: d.
	self assert: restored type equals: 'adaptive'.
	self assert: restored display equals: 'summarized'.
	self assert: restored budgetTokens isNil
]

{ #category : 'tests' }
ClaudeThinkingParamsTest >> testAdaptiveThinkingWithDisplayAsDictionary [
	| d |
	d := (ClaudeThinkingParams adaptiveWithDisplay: 'summarized') asDictionary.
	self assert: (d at: 'type') equals: 'adaptive'.
	self assert: (d at: 'display') equals: 'summarized'.
	self deny: (d includesKey: 'budget_tokens')
]

{ #category : 'tests' }
ClaudeThinkingParamsTest >> testAdaptiveThinkingWithDisplayFromDictionary [
	| tp d |
	d := Dictionary newFromPairs: { 'type'. 'adaptive'. 'display'. 'omitted' }.
	tp := ClaudeThinkingParams new.
	tp fromDictionary: d.
	self assert: tp type equals: 'adaptive'.
	self assert: tp display equals: 'omitted'.
	self assert: tp budgetTokens isNil
]

{ #category : 'tests' }
ClaudeThinkingParamsTest >> testDisabledThinkingAsDictionary [
	| d |
	d := ClaudeThinkingParams disabled asDictionary.
	self assert: (d at: 'type') equals: 'disabled'.
	self deny: (d includesKey: 'budget_tokens').
	self deny: (d includesKey: 'display')
]

{ #category : 'tests' }
ClaudeThinkingParamsTest >> testEnabledThinkingAsDictionary [
	| d |
	d := (ClaudeThinkingParams enabled: 5000) asDictionary.
	self assert: (d at: 'type') equals: 'enabled'.
	self assert: (d at: 'budget_tokens') equals: 5000.
	self deny: (d includesKey: 'display')
]

{ #category : 'tests' }
ClaudeThinkingParamsTest >> testThinkingParamsAddFieldsTo [
	| tp dict thinkingDict |
	tp := ClaudeThinkingParams new.
	tp type: 'enabled'.
	tp budgetTokens: 5000.
	dict := OrderedDictionary new.
	tp addFieldsTo: dict.
	thinkingDict := dict at: 'thinking'.
	self assert: (thinkingDict at: 'type') equals: 'enabled'.
	self assert: (thinkingDict at: 'budget_tokens') equals: 5000
]

{ #category : 'tests' }
ClaudeThinkingParamsTest >> testThinkingParamsJsonKeyMap [
	| map |
	map := ClaudeThinkingParams jsonKeyMap.
	self assert: (map at: #budgetTokens) equals: 'budget_tokens'.
	self assert: (map at: #display) equals: 'display'.
	self assert: map size equals: 2
]

{ #category : 'tests' }
ClaudeThinkingParamsTest >> testThinkingRoundTrip [
	| params thinkingDict result |
	params := ClaudeMessageRequest new.
	thinkingDict := Dictionary newFromPairs: { 'type'. 'enabled'. 'budget_tokens'. 10000 }.
	params thinking: thinkingDict.
	result := params thinking.
	self assert: (result at: 'type') equals: 'enabled'.
	self assert: (result at: 'budget_tokens') equals: 10000.
	"Setting nil clears thinking"
	params thinking: nil.
	self assert: params thinking isNil
]
