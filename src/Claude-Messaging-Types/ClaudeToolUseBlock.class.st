"
A tool_use content block from a Claude API response. Contains the tool invocation id, tool name, and input arguments dictionary. Appears when the model decides to call a tool.

### Examples

```
ClaudeToolUseBlock new type
>>> 'tool_use'

ClaudeToolUseBlock new name: 'get_weather'; name
>>> 'get_weather'
```

"
Class {
	#name : 'ClaudeToolUseBlock',
	#superclass : 'ClaudeContentBlock',
	#instVars : [
		'id',
		'name',
		'input'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeToolUseBlock class >> fromJson: aDictionary [
	^ self new
		id: (aDictionary at: 'id' ifAbsent: [ nil ]);
		name: (aDictionary at: 'name' ifAbsent: [ nil ]);
		input: (aDictionary at: 'input' ifAbsent: [ nil ]);
		yourself
]

{ #category : 'persistence' }
ClaudeToolUseBlock class >> fromSton: stonReader [
	| dict |
	dict := Dictionary new.
	stonReader parseMapDo: [ :key :value | dict at: key put: value ].
	^ self new
		id: (dict at: #id ifAbsent: [ nil ]);
		name: (dict at: #name ifAbsent: [ nil ]);
		input: (dict at: #input ifAbsent: [ Dictionary new ]);
		yourself
]

{ #category : 'instance creation' }
ClaudeToolUseBlock class >> id: anId name: aName input: aDict [
	^ self new
		id: anId;
		name: aName;
		input: aDict;
		yourself
]

{ #category : 'streaming' }
ClaudeToolUseBlock >> applyDelta: aDeltaDict [
	| current |
	(aDeltaDict at: 'type') = 'input_json_delta' ifFalse: [ ^ self ].
	current := input.
	(current isNil or: [ current isString not ]) ifTrue: [ current := '' ].
	input := current , (aDeltaDict at: 'partial_json')
]

{ #category : 'json' }
ClaudeToolUseBlock >> asJson [
	| dict |
	dict := OrderedDictionary new.
	dict at: 'type' put: 'tool_use'.
	dict at: 'id' put: id.
	dict at: 'name' put: name.
	dict at: 'input' put: input.
	^ dict
]

{ #category : 'streaming' }
ClaudeToolUseBlock >> finalizeAfterStreaming [
	"Parse accumulated input_json_delta string into a Dictionary. applyDelta:
	concatenates partial_json fragments into a String; when the content block ends,
	parse that String. Empty string normalizes to empty Dictionary.
	Mirrors ClaudeMCPToolUseBlock>>finalizeAfterStreaming; intentional duplication
	for polymorphic evolvability — each block type may evolve its finalization
	independently as the wire protocol grows."
	input isString ifFalse: [ ^ self ].
	input := input isEmpty
		ifTrue: [ Dictionary new ]
		ifFalse: [ STONJSON fromString: input ]
]

{ #category : 'accessing' }
ClaudeToolUseBlock >> id [
	^ id
]

{ #category : 'accessing' }
ClaudeToolUseBlock >> id: aString [
	id := aString
]

{ #category : 'initialization' }
ClaudeToolUseBlock >> initialize [
	super initialize.
	type := 'tool_use'
]

{ #category : 'accessing' }
ClaudeToolUseBlock >> input [
	^ input
]

{ #category : 'accessing' }
ClaudeToolUseBlock >> input: aDictionary [
	input := aDictionary
]

{ #category : 'testing' }
ClaudeToolUseBlock >> isToolUseBlock [
	^ true
]

{ #category : 'accessing' }
ClaudeToolUseBlock >> name [
	^ name
]

{ #category : 'accessing' }
ClaudeToolUseBlock >> name: aString [
	name := aString
]

{ #category : 'persistence' }
ClaudeToolUseBlock >> stonOn: aStonWriter [
	aStonWriter writeObject: self streamMap: [ :map |
		map at: #id put: id.
		map at: #name put: name.
		map at: #input put: input ]
]
