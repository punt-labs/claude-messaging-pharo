"
A ``tool_search_tool_result`` content block -- the server-side tool-search tool's output appearing in ``response content`` after Claude invokes it to discover available tools.

### When you see it

When a request enables the server-side tool-search tool, Claude can query the server for tools that match a task description instead of having them all preloaded in the request. The response content stream includes a ``ClaudeServerToolUseBlock`` (the search call) followed by a ``ClaudeToolSearchResultBlock`` carrying the matched tool references. Sibling of ``ClaudeBashResultBlock`` and ``ClaudeTextEditorResultBlock`` -- each is the result leg for a different server-side tool.

### Accessors

- ``type`` -- always ``'tool_search_tool_result'``
- ``toolReferences`` -- the array of tool reference records returned by the server, or nil when absent; each entry describes a tool the server knows about (name, description, schema)
- ``toolUseId`` -- the id of the matching ``ClaudeServerToolUseBlock`` so you can pair call with result
- ``rawJson`` -- the full server payload

### Example

```
ClaudeToolSearchResultBlock new type
>>> 'tool_search_tool_result'
```

```
| block |
block := ClaudeToolSearchResultBlock fromJson: (Dictionary newFromPairs: {
    'type'. 'tool_search_tool_result'.
    'tool_use_id'. 'toolu_abc'.
    'content'. (Dictionary newFromPairs: { 'tool_references'. #() }) }).
block toolReferences
>>> #()
```

### See also

``ClaudeServerToolUseBlock`` -- the call-side companion; the two blocks are matched via ``toolUseId``.

"
Class {
	#name : 'ClaudeToolSearchResultBlock',
	#superclass : 'ClaudeContentBlock',
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeToolSearchResultBlock class >> fromJson: aDictionary [
  ^ self new
    type: (aDictionary at: 'type' ifAbsent: [ 'tool_search_tool_result' ]);
    rawJson: aDictionary copy;
    yourself
]

{ #category : 'persistence' }
ClaudeToolSearchResultBlock class >> fromSton: stonReader [
  | dict raw |
  dict := Dictionary new.
  stonReader parseMapDo: [ :key :value | dict at: key put: value ].
  raw := dict at: #rawJson ifAbsent: [ Dictionary new ].
  ^ self fromJson: raw
]

{ #category : 'json' }
ClaudeToolSearchResultBlock >> asJson [
  ^ rawJson ifNil: [
    OrderedDictionary new
      at: 'type' put: 'tool_search_tool_result';
      yourself ]
]

{ #category : 'initialization' }
ClaudeToolSearchResultBlock >> initialize [
  super initialize.
  type := 'tool_search_tool_result'
]

{ #category : 'persistence' }
ClaudeToolSearchResultBlock >> stonOn: aStonWriter [
  aStonWriter writeObject: self streamMap: [ :map |
    map at: #rawJson put: rawJson ]
]

{ #category : 'accessing' }
ClaudeToolSearchResultBlock >> toolReferences [
  | content |
  content := rawJson at: 'content' ifAbsent: [ ^ nil ].
  ^ content at: 'tool_references' ifAbsent: [ nil ]
]

{ #category : 'accessing' }
ClaudeToolSearchResultBlock >> toolUseId [
  ^ rawJson at: 'tool_use_id' ifAbsent: [ nil ]
]
