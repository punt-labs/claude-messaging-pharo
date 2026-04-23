"
An mcp_tool_use content block from a Claude API response. Identifies an MCP tool invocation by id, names the MCP server (server_name) and the tool (name), and carries the input arguments as parsed JSON. Created by ClaudeContentBlock class >> fromJson: when the wire 'type' is 'mcp_tool_use'.

Streaming: applyDelta: accumulates input_json_delta partial_json fragments into a String; finalizeAfterStreaming parses that String into a Dictionary at content_block_stop. Without this, MCP tool arguments streamed via SSE would be silently dropped.

Invariant: input is never nil. The default-init, fromJson:, and input: setter all normalize nil to an empty Dictionary because Anthropic rejects null on the required input field.

  ClaudeMCPToolUseBlock new type
  >>> 'mcp_tool_use'

  ClaudeMCPToolUseBlock new isMCPToolUseBlock
  >>> true

  (ClaudeMCPToolUseBlock new serverName: 'example'; serverName)
  >>> 'example'


"
Class {
	#name : 'ClaudeMCPToolUseBlock',
	#superclass : 'ClaudeContentBlock',
	#instVars : [
		'id',
		'name',
		'serverName',
		'input'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeMCPToolUseBlock class >> fromJson: aDictionary [
	"input is required by the wire — when the dict has no input key OR the value
	is nil (STONJSON maps wire null to nil), default to an empty Dictionary so
	asJson cannot emit nullish input. Anthropic rejects null for the required
	input field. The input: setter is the authoritative invariant — it normalizes
	nil to an empty Dictionary, so no post-assignment guard is needed."
	^ self new
		id: (aDictionary at: 'id' ifAbsent: [ nil ]);
		name: (aDictionary at: 'name' ifAbsent: [ nil ]);
		serverName: (aDictionary at: 'server_name' ifAbsent: [ nil ]);
		input: (aDictionary at: 'input' ifAbsent: [ Dictionary new ]);
		yourself
]

{ #category : 'json' }
ClaudeMCPToolUseBlock class >> jsonKeyMap [
	^ {
		#serverName -> 'server_name'
	} asDictionary
]

{ #category : 'streaming' }
ClaudeMCPToolUseBlock >> applyDelta: aDeltaDict [
	"Accumulate a streamed input_json_delta into the input string. Mirrors
	ClaudeToolUseBlock>>applyDelta: the Anthropic API streams MCP tool input
	as partial_json fragments via content_block_delta events with type
	input_json_delta. Without this, the streamed arguments would be silently
	dropped on the floor and the post-stream input would still be the empty
	Dictionary set by initialize. finalizeAfterStreaming parses the
	accumulated string into a Dictionary at content_block_stop."
	| current |
	(aDeltaDict at: 'type') = 'input_json_delta' ifFalse: [ ^ self ].
	current := input.
	(current isNil or: [ current isString not ]) ifTrue: [ current := '' ].
	input := current , (aDeltaDict at: 'partial_json') 
]

{ #category : 'json' }
ClaudeMCPToolUseBlock >> asJson [
	| dict |
	dict := OrderedDictionary new.
	dict at: 'type' put: 'mcp_tool_use'.
	dict at: 'id' put: id.
	dict at: 'name' put: name.
	dict at: 'server_name' put: serverName.
	dict at: 'input' put: input.
	^ dict
]

{ #category : 'streaming' }
ClaudeMCPToolUseBlock >> finalizeAfterStreaming [
	"Parse accumulated input_json_delta string into a Dictionary. Empty string
	normalizes to empty Dictionary so asJson cannot emit nullish input.
	Mirrors ClaudeToolUseBlock>>finalizeAfterStreaming; intentional duplication
	for polymorphic evolvability — each block type may evolve its finalization
	independently as the wire protocol grows."
	input isString ifFalse: [ ^ self ].
	input isEmpty
		ifTrue: [ input := Dictionary new ]
		ifFalse: [ input := STONJSON fromString: input ]
]

{ #category : 'accessing' }
ClaudeMCPToolUseBlock >> id [
	^ id
]

{ #category : 'accessing' }
ClaudeMCPToolUseBlock >> id: aString [
	id := aString
]

{ #category : 'initialization' }
ClaudeMCPToolUseBlock >> initialize [
	super initialize.
	type := 'mcp_tool_use'.
	input := Dictionary new
]

{ #category : 'accessing' }
ClaudeMCPToolUseBlock >> input [
	^ input
]

{ #category : 'accessing' }
ClaudeMCPToolUseBlock >> input: anObject [
	"Normalize nil to empty Dictionary. The Anthropic API requires the input
	field on mcp_tool_use blocks and rejects null. The default-init and
	fromJson: paths already guard this invariant; the setter pins it on
	post-construction mutation. Strings are accepted because applyDelta:
	accumulates partial_json fragments as a String before
	finalizeAfterStreaming parses them into a Dictionary."
	input := anObject ifNil: [ Dictionary new ] 
]

{ #category : 'testing' }
ClaudeMCPToolUseBlock >> isMCPToolUseBlock [
	^ true
]

{ #category : 'accessing' }
ClaudeMCPToolUseBlock >> name [
	^ name
]

{ #category : 'accessing' }
ClaudeMCPToolUseBlock >> name: aString [
	name := aString
]

{ #category : 'accessing' }
ClaudeMCPToolUseBlock >> serverName [
	^ serverName
]

{ #category : 'accessing' }
ClaudeMCPToolUseBlock >> serverName: aString [
	serverName := aString
]
