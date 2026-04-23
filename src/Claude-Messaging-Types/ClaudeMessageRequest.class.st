"
A message request to the Claude Messages API. The complete specification of what you want Claude to do: model, max tokens, conversation messages, and optional parameters (system prompt, tools, temperature, MCP servers, etc.). Constructed via builder methods that add user, assistant, and tool result turns. Serialized via asJson for the API request body. Optional fields are omitted from JSON when nil.

### Examples

```
| req |
req := ClaudeMessageRequest new model: ClaudeModel sonnet46; maxTokens: 100.
req model
>>> 'claude-sonnet-4-6'

ClaudeMessageRequest new maxTokens: 256; maxTokens
>>> 256

| req |
req := ClaudeMessageRequest new.
req mcpServers: { ClaudeMCPServerDefinition name: 'example' url: 'https://mcp.example.com/sse' }.
req mcpServers size
>>> 1
```

"
Class {
	#name : 'ClaudeMessageRequest',
	#superclass : 'Object',
	#instVars : [
		'model',
		'maxTokens',
		'messages',
		'system',
		'sampling',
		'toolParams',
		'thinkingParams',
		'requestOptions',
		'outputConfig'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeMessageRequest class >> jsonKeyMap [
	^ {
		#maxTokens -> 'max_tokens'
	} asDictionary
]

{ #category : 'building' }
ClaudeMessageRequest >> addAssistantMessage: aString [
	messages add: (ClaudeMessage assistantMessage: aString)
]

{ #category : 'building' }
ClaudeMessageRequest >> addAssistantResponse: aClaudeMessage [
	messages add: aClaudeMessage
]

{ #category : 'json - private' }
ClaudeMessageRequest >> addRequiredFieldsTo: dict [
	dict at: 'model' put: model.
	dict at: 'max_tokens' put: maxTokens.
	dict at: 'messages' put: (messages collect: [ :m | m asParam ]) asArray
]

{ #category : 'building' }
ClaudeMessageRequest >> addToolResult: toolUseId content: aString [
	messages add: (ClaudeMessage toolResult: toolUseId content: aString)
]

{ #category : 'building' }
ClaudeMessageRequest >> addToolResult: toolUseId content: aString isError: aBoolean [
	messages add: (ClaudeMessage toolResult: toolUseId content: aString isError: aBoolean)
]

{ #category : 'building' }
ClaudeMessageRequest >> addUserContent: contentBlocks [
	"Add a user message with multiple content blocks (text, image, etc).
	contentBlocks is a collection of ClaudeContentBlock instances."
	messages add: (ClaudeMessage userContent: contentBlocks)
]

{ #category : 'building' }
ClaudeMessageRequest >> addUserMessage: aString [
	messages add: (ClaudeMessage userMessage: aString)
]

{ #category : 'building' }
ClaudeMessageRequest >> addUserMessage: aString withImage: aClaudeImageBlock [
	"Add a user message with text and an image."
	self addUserContent: {
		ClaudeTextBlock text: aString.
		aClaudeImageBlock }
]

{ #category : 'building' }
ClaudeMessageRequest >> addUserMessage: aString withImages: imageBlocks [
	"Add a user message with text and multiple images."
	self addUserContent: (
		{ ClaudeTextBlock text: aString }, imageBlocks asArray)
]

{ #category : 'json' }
ClaudeMessageRequest >> asJson [
  | dict composed |
  dict := OrderedDictionary new.
  self addRequiredFieldsTo: dict.
  sampling addFieldsTo: dict.
  toolParams addFieldsTo: dict.
  thinkingParams addFieldsTo: dict.
  outputConfig addFieldsTo: dict.
  composed := self composedSystem.
  composed ifNotNil: [
    dict at: 'system' put: (composed isString
      ifTrue: [ composed ]
      ifFalse: [ (composed collect: [ :b | b asJson ]) asArray ]) ].
  requestOptions addFieldsTo: dict.
  ^ dict
]

{ #category : 'configuring' }
ClaudeMessageRequest >> betas: anArray [
	"Set beta feature flags on the request options."
	requestOptions betas: anArray
]

{ #category : 'accessing' }
ClaudeMessageRequest >> cacheControl [
	^ requestOptions cacheControl
]

{ #category : 'accessing' }
ClaudeMessageRequest >> cacheControl: aDictionary [
	requestOptions cacheControl: aDictionary
]

{ #category : 'json - private' }
ClaudeMessageRequest >> composedSystem [
  "Return the system prompt with any output format suffix appended.
   Used by asJson instead of accessing system directly."
  | suffix |
  suffix := (outputConfig format notNil
    and: [ outputConfig format respondsTo: #systemPromptSuffix ])
      ifTrue: [ outputConfig format systemPromptSuffix ]
      ifFalse: [ nil ].
  (suffix isNil or: [ suffix isEmpty ]) ifTrue: [ ^ system ].
  system ifNil: [ ^ suffix ].
  system isString
    ifTrue: [ ^ system, String cr, String cr, suffix ].
  "Array of content blocks - append a ClaudeTextBlock"
  ^ system copyWith: (ClaudeTextBlock text: suffix)
]

{ #category : 'accessing' }
ClaudeMessageRequest >> container [
	^ requestOptions container
]

{ #category : 'accessing' }
ClaudeMessageRequest >> container: aString [
	requestOptions container: aString
]

{ #category : 'configuring' }
ClaudeMessageRequest >> effort: aString [
  "Set the output effort level."
  outputConfig effort: aString
]

{ #category : 'accessing' }
ClaudeMessageRequest >> inferenceGeo [
	^ requestOptions inferenceGeo
]

{ #category : 'accessing' }
ClaudeMessageRequest >> inferenceGeo: aString [
	requestOptions inferenceGeo: aString
]

{ #category : 'initialization' }
ClaudeMessageRequest >> initialize [
  messages := OrderedCollection new.
  sampling := ClaudeSamplingParams new.
  toolParams := ClaudeToolParams new.
  thinkingParams := ClaudeThinkingParams new.
  requestOptions := ClaudeRequestOptions new.
  outputConfig := ClaudeOutputConfig new
]

{ #category : 'configuring' }
ClaudeMessageRequest >> jsonSchema: aClaudeToolInputSchema [
  "Set the output format to JSON schema."
  outputConfig format: (ClaudeJsonSchemaOutputFormat schema: aClaudeToolInputSchema)
]

{ #category : 'accessing' }
ClaudeMessageRequest >> maxTokens [
	^ maxTokens
]

{ #category : 'accessing' }
ClaudeMessageRequest >> maxTokens: anInteger [
	maxTokens := anInteger
]

{ #category : 'accessing' }
ClaudeMessageRequest >> mcpServers [
	"Answer the collection of MCP server definitions, or nil."
	^ requestOptions mcpServers
]

{ #category : 'accessing' }
ClaudeMessageRequest >> mcpServers: aCollection [
	"Set the MCP server definitions on the request options."
	requestOptions mcpServers: aCollection
]

{ #category : 'accessing' }
ClaudeMessageRequest >> messages [
	^ messages
]

{ #category : 'accessing' }
ClaudeMessageRequest >> messages: anOrderedCollection [
	messages := anOrderedCollection
]

{ #category : 'accessing' }
ClaudeMessageRequest >> metadata [
	^ requestOptions metadata
]

{ #category : 'accessing' }
ClaudeMessageRequest >> metadata: aDictionary [
	requestOptions metadata: aDictionary
]

{ #category : 'accessing' }
ClaudeMessageRequest >> model [
	^ model
]

{ #category : 'accessing' }
ClaudeMessageRequest >> model: aString [
	model := aString
]

{ #category : 'accessing - groups' }
ClaudeMessageRequest >> outputConfig [
  ^ outputConfig
]

{ #category : 'accessing' }
ClaudeMessageRequest >> outputFormat [
	"Answer the output format from the output config, or nil."
	^ outputConfig format
]

{ #category : 'configuring' }
ClaudeMessageRequest >> outputFormat: anOutputFormat [
	"Set the output format on the output config."
	outputConfig format: anOutputFormat
]

{ #category : 'printing' }
ClaudeMessageRequest >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeMessageRequest(';
		nextPutAll: (model ifNil: [ '?' ]);
		nextPutAll: ' msgs: ';
		print: messages size;
		nextPut: $)
]

{ #category : 'accessing - groups' }
ClaudeMessageRequest >> requestOptions [
	^ requestOptions
]

{ #category : 'accessing - groups' }
ClaudeMessageRequest >> sampling [
	^ sampling
]

{ #category : 'accessing' }
ClaudeMessageRequest >> serviceTier [
	^ requestOptions serviceTier
]

{ #category : 'accessing' }
ClaudeMessageRequest >> serviceTier: aString [
	requestOptions serviceTier: aString
]

{ #category : 'accessing' }
ClaudeMessageRequest >> speed [
	^ requestOptions speed
]

{ #category : 'accessing' }
ClaudeMessageRequest >> speed: aString [
	requestOptions speed: aString
]

{ #category : 'accessing' }
ClaudeMessageRequest >> stopSequences [
	^ sampling stopSequences
]

{ #category : 'accessing' }
ClaudeMessageRequest >> stopSequences: anOrderedCollection [
	sampling stopSequences: anOrderedCollection
]

{ #category : 'accessing' }
ClaudeMessageRequest >> stream [
	^ requestOptions stream
]

{ #category : 'accessing' }
ClaudeMessageRequest >> stream: aBoolean [
	requestOptions stream: aBoolean
]

{ #category : 'accessing' }
ClaudeMessageRequest >> system [
	^ system
]

{ #category : 'accessing' }
ClaudeMessageRequest >> system: aString [
	system := aString
]

{ #category : 'building' }
ClaudeMessageRequest >> systemBlocks: aCollection [
	"Set structured system prompt as a collection of content blocks (e.g. ClaudeTextBlock instances with cache_control)."
	system := aCollection
]

{ #category : 'accessing' }
ClaudeMessageRequest >> temperature [
	^ sampling temperature
]

{ #category : 'accessing' }
ClaudeMessageRequest >> temperature: aFloat [
	sampling temperature: aFloat
]

{ #category : 'accessing' }
ClaudeMessageRequest >> thinking [
	^ thinkingParams asDictionary
]

{ #category : 'accessing' }
ClaudeMessageRequest >> thinking: aDictionaryOrNil [
	thinkingParams fromDictionary: aDictionaryOrNil
]

{ #category : 'accessing - groups' }
ClaudeMessageRequest >> thinkingParams [
	^ thinkingParams
]

{ #category : 'accessing' }
ClaudeMessageRequest >> toolChoice [
	^ toolParams toolChoice
]

{ #category : 'accessing' }
ClaudeMessageRequest >> toolChoice: aDictionary [
	toolParams toolChoice: aDictionary
]

{ #category : 'accessing - groups' }
ClaudeMessageRequest >> toolParams [
	^ toolParams
]

{ #category : 'accessing' }
ClaudeMessageRequest >> tools [
	^ toolParams tools
]

{ #category : 'accessing' }
ClaudeMessageRequest >> tools: anOrderedCollection [
	toolParams tools: anOrderedCollection
]

{ #category : 'accessing' }
ClaudeMessageRequest >> topK [
	^ sampling topK
]

{ #category : 'accessing' }
ClaudeMessageRequest >> topK: anInteger [
	sampling topK: anInteger
]

{ #category : 'accessing' }
ClaudeMessageRequest >> topP [
	^ sampling topP
]

{ #category : 'accessing' }
ClaudeMessageRequest >> topP: aFloat [
	sampling topP: aFloat
]
