"
A ``compaction`` content block -- a server-emitted summary of conversation turns the server rolled up to stay within the context window.

### When you see it

Long-running conversations eventually exceed the model's context window. Rather than failing the request, the server auto-compacts older turns into a single summary block and emits it in the response content stream. You see a ``ClaudeCompactionBlock`` in ``response content`` whenever the server had to compact, so your client code should tolerate it alongside the more common text, tool-use, and thinking blocks. Sibling of other server-emitted blocks like ``ClaudeRedactedThinkingBlock``.

### Accessors

- ``type`` -- always ``'compaction'``
- ``content`` -- the compaction summary (String), or nil when the server emitted an empty block
- ``rawJson`` -- the full server payload; read further fields off this map if the server adds them

### Example

```
ClaudeCompactionBlock new type
>>> 'compaction'
```

```
| block |
block := ClaudeCompactionBlock fromJson: (Dictionary newFromPairs: {
    'type'. 'compaction'.
    'content'. 'summary here' }).
block content
>>> 'summary here'
```

### See also

``ClaudeMicrocompact`` in ``Claude-Agent-Exchange`` for the client-side compaction strategy that runs before requests go out, which is orthogonal to the server-side compaction this block represents.

"
Class {
	#name : 'ClaudeCompactionBlock',
	#superclass : 'ClaudeContentBlock',
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeCompactionBlock class >> fromJson: aDictionary [
  ^ self new
    type: (aDictionary at: 'type' ifAbsent: [ 'compaction' ]);
    rawJson: aDictionary copy;
    yourself
]

{ #category : 'persistence' }
ClaudeCompactionBlock class >> fromSton: stonReader [
  | dict raw |
  dict := Dictionary new.
  stonReader parseMapDo: [ :key :value | dict at: key put: value ].
  raw := (dict at: #rawJson ifAbsent: [ Dictionary new ]) ifNil: [ Dictionary new ].
  ^ self fromJson: raw
]

{ #category : 'json' }
ClaudeCompactionBlock >> asJson [
  ^ rawJson ifNil: [
    OrderedDictionary new
      at: 'type' put: 'compaction';
      yourself ]
]

{ #category : 'accessing' }
ClaudeCompactionBlock >> content [
  ^ rawJson at: 'content' ifAbsent: [ nil ]
]

{ #category : 'initialization' }
ClaudeCompactionBlock >> initialize [
  super initialize.
  type := 'compaction'
]

{ #category : 'persistence' }
ClaudeCompactionBlock >> stonOn: aStonWriter [
  aStonWriter writeObject: self streamMap: [ :map |
    map at: #rawJson put: rawJson ]
]
