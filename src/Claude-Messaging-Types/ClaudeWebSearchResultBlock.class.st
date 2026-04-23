"
A web_search_tool_result content block from a Claude API response. Stores raw JSON for forward compatibility.

### Examples

```
ClaudeWebSearchResultBlock new type
>>> 'web_search_tool_result'
```

"
Class {
	#name : 'ClaudeWebSearchResultBlock',
	#superclass : 'ClaudeContentBlock',
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeWebSearchResultBlock class >> fromJson: aDictionary [
	^ self new
		type: (aDictionary at: 'type' ifAbsent: [ 'web_search_tool_result' ]);
		rawJson: aDictionary copy;
		yourself
]

{ #category : 'persistence' }
ClaudeWebSearchResultBlock class >> fromSton: stonReader [
	| dict raw |
	dict := Dictionary new.
	stonReader parseMapDo: [ :key :value | dict at: key put: value ].
	raw := dict at: #rawJson ifAbsent: [ Dictionary new ].
	^ self fromJson: raw
]

{ #category : 'json' }
ClaudeWebSearchResultBlock >> asJson [
	^ rawJson ifNil: [
		OrderedDictionary new
			at: 'type' put: 'web_search_tool_result';
			yourself ]
]

{ #category : 'initialization' }
ClaudeWebSearchResultBlock >> initialize [
	super initialize.
	type := 'web_search_tool_result'
]

{ #category : 'persistence' }
ClaudeWebSearchResultBlock >> stonOn: aStonWriter [
	aStonWriter writeObject: self streamMap: [ :map |
		map at: #rawJson put: rawJson ]
]
