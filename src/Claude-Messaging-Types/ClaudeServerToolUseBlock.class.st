"
A server_tool_use content block from a Claude API response. Represents a server-managed tool invocation. Stores raw JSON for forward compatibility.

### Examples

```
ClaudeServerToolUseBlock new type
>>> 'server_tool_use'
```

"
Class {
	#name : 'ClaudeServerToolUseBlock',
	#superclass : 'ClaudeContentBlock',
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeServerToolUseBlock class >> fromJson: aDictionary [
	^ self new
		type: (aDictionary at: 'type' ifAbsent: [ 'server_tool_use' ]);
		rawJson: aDictionary copy;
		yourself
]

{ #category : 'persistence' }
ClaudeServerToolUseBlock class >> fromSton: stonReader [
	| dict raw |
	dict := Dictionary new.
	stonReader parseMapDo: [ :key :value | dict at: key put: value ].
	raw := dict at: #rawJson ifAbsent: [ Dictionary new ].
	^ self fromJson: raw
]

{ #category : 'json' }
ClaudeServerToolUseBlock >> asJson [
	^ rawJson ifNil: [
		OrderedDictionary new
			at: 'type' put: 'server_tool_use';
			yourself ]
]

{ #category : 'initialization' }
ClaudeServerToolUseBlock >> initialize [
	super initialize.
	type := 'server_tool_use'
]

{ #category : 'persistence' }
ClaudeServerToolUseBlock >> stonOn: aStonWriter [
	aStonWriter writeObject: self streamMap: [ :map |
		map at: #rawJson put: rawJson ]
]
