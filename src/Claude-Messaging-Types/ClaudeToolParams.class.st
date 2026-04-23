"
The tool-configuration group on a ``ClaudeMessageRequest``. Holds the request's tool list, the tool-choice policy, and the parallel-tool-use flag -- three wire-level fields that travel together because they all control the same decision (what tools are available, which one Claude should prefer, whether multiple can fire in one turn).

### When you touch it

Usually indirectly, via ``ClaudeMessageRequest``'s delegating accessors (``tools``, ``tools:``, ``toolChoice``, ``toolChoice:``, ``disableParallelToolUse``). Touch ``toolParams`` directly when you are building a request programmatically and want the grouping explicit, or when you are reading the request object back via ``ClaudeMessageRequest >> toolParams``. Sibling of ``ClaudeSamplingParams`` (temperature, topK, topP, stopSequences), ``ClaudeThinkingParams`` (thinking mode + budget), and ``ClaudeRequestOptions`` (per-request controls like metadata, cacheControl, betas) -- each groups a distinct slice of the Messages API request body.

### Slots

- ``tools`` -- a collection of ``ClaudeTool`` (client-side) and server-tool definitions (``ClaudeBashServerTool``, ``ClaudeTextEditorServerTool``, ``ClaudeCodeExecutionServerTool``, ...) serialized via each element's ``asJson``
- ``toolChoice`` -- the tool-choice policy as a Dictionary matching the Anthropic schema: ``{ 'type' -> 'auto' }``, ``{ 'type' -> 'any' }``, ``{ 'type' -> 'tool'. 'name' -> 'get_weather' }``, or ``{ 'type' -> 'none' }``. Stored as-is so callers see raw wire shape on round-trip
- ``disableParallelToolUse`` -- Boolean; when true the server runs tool calls sequentially

### Example

```
ClaudeToolParams new toolChoice: { 'type' -> 'auto' } asDictionary; toolChoice
>>> { 'type' -> 'auto' } asDictionary
```

```
ClaudeToolParams new disableParallelToolUse: true; disableParallelToolUse
>>> true
```

### See also

``ClaudeMessageRequest >> toolParams`` -- the holder. Every request has one; the delegating accessors on the request read through to it.

"
Class {
	#name : 'ClaudeToolParams',
	#superclass : 'Object',
	#instVars : [
		'tools',
		'toolChoice',
		'disableParallelToolUse'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeToolParams class >> jsonKeyMap [
	^ {
		#toolChoice -> 'tool_choice'.
		#disableParallelToolUse -> 'disable_parallel_tool_use'
	} asDictionary
]

{ #category : 'json' }
ClaudeToolParams >> addFieldsTo: dict [
	tools ifNotNil: [ dict at: 'tools' put: (tools collect: [ :t | t asJson ]) asArray ].
	toolChoice ifNotNil: [ dict at: 'tool_choice' put: toolChoice ].
	disableParallelToolUse ifNotNil: [ dict at: 'disable_parallel_tool_use' put: disableParallelToolUse ]
]

{ #category : 'accessing' }
ClaudeToolParams >> disableParallelToolUse [
	"Return whether parallel tool use should be disabled"
	^ disableParallelToolUse
]

{ #category : 'accessing' }
ClaudeToolParams >> disableParallelToolUse: aBoolean [
	"Set whether parallel tool use should be disabled"
	disableParallelToolUse := aBoolean
]

{ #category : 'accessing' }
ClaudeToolParams >> toolChoice [
	^ toolChoice
]

{ #category : 'accessing' }
ClaudeToolParams >> toolChoice: aDictionary [
	toolChoice := aDictionary
]

{ #category : 'accessing' }
ClaudeToolParams >> tools [
	^ tools
]

{ #category : 'accessing' }
ClaudeToolParams >> tools: aCollection [
	tools := aCollection
]
