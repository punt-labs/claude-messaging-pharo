"
A web_fetch_tool_result content block from a Claude API response. Stores raw JSON for forward compatibility.

### Examples

```
ClaudeWebFetchResultBlock new type
>>> 'web_fetch_tool_result'
```

"
Class {
	#name : 'ClaudeWebFetchResultBlock',
	#superclass : 'ClaudeContentBlock',
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeWebFetchResultBlock class >> fromJson: aDictionary [
	^ self new
		type: (aDictionary at: 'type' ifAbsent: [ 'web_fetch_tool_result' ]);
		rawJson: aDictionary copy;
		yourself
]

{ #category : 'persistence' }
ClaudeWebFetchResultBlock class >> fromSton: stonReader [
	| dict raw |
	dict := Dictionary new.
	stonReader parseMapDo: [ :key :value | dict at: key put: value ].
	raw := dict at: #rawJson ifAbsent: [ Dictionary new ].
	^ self fromJson: raw
]

{ #category : 'json' }
ClaudeWebFetchResultBlock >> asJson [
	^ rawJson ifNil: [
		OrderedDictionary new
			at: 'type' put: 'web_fetch_tool_result';
			yourself ]
]

{ #category : 'initialization' }
ClaudeWebFetchResultBlock >> initialize [
	super initialize.
	type := 'web_fetch_tool_result'
]

{ #category : 'persistence' }
ClaudeWebFetchResultBlock >> stonOn: aStonWriter [
	aStonWriter writeObject: self streamMap: [ :map |
		map at: #rawJson put: rawJson ]
]
