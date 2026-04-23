"
A code_execution_tool_result content block from a Claude API response. Stores raw JSON for forward compatibility.

### Examples

```
ClaudeCodeExecutionResultBlock new type
>>> 'code_execution_tool_result'
```

"
Class {
	#name : 'ClaudeCodeExecutionResultBlock',
	#superclass : 'ClaudeContentBlock',
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeCodeExecutionResultBlock class >> fromJson: aDictionary [
	^ self new
		type: (aDictionary at: 'type' ifAbsent: [ 'code_execution_tool_result' ]);
		rawJson: aDictionary copy;
		yourself
]

{ #category : 'persistence' }
ClaudeCodeExecutionResultBlock class >> fromSton: stonReader [
	| dict raw |
	dict := Dictionary new.
	stonReader parseMapDo: [ :key :value | dict at: key put: value ].
	raw := dict at: #rawJson ifAbsent: [ Dictionary new ].
	^ self fromJson: raw
]

{ #category : 'json' }
ClaudeCodeExecutionResultBlock >> asJson [
	^ rawJson ifNil: [
		OrderedDictionary new
			at: 'type' put: 'code_execution_tool_result';
			yourself ]
]

{ #category : 'initialization' }
ClaudeCodeExecutionResultBlock >> initialize [
	super initialize.
	type := 'code_execution_tool_result'
]

{ #category : 'persistence' }
ClaudeCodeExecutionResultBlock >> stonOn: aStonWriter [
	aStonWriter writeObject: self streamMap: [ :map |
		map at: #rawJson put: rawJson ]
]
