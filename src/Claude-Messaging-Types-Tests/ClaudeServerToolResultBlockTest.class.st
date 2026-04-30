"
Tests for the 5 server-tool response block types added to ClaudeContentBlock: ClaudeBashResultBlock, ClaudeTextEditorResultBlock, ClaudeToolSearchResultBlock, ClaudeContainerUploadBlock, and ClaudeCompactionBlock.

### Examples

```
ClaudeServerToolResultBlockTest buildSuite run
>>> 7 run, 7 passed, 0 skipped, 0 expected failures, 0 failures, 0 errors
```

"
Class {
	#name : 'ClaudeServerToolResultBlockTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeServerToolResultBlockTest >> testBashResultBlockFromJson [
  | json block |
  json := Dictionary new.
  json at: 'type' put: 'bash_code_execution_tool_result'.
  json at: 'tool_use_id' put: 'tu_bash_123'.
  json at: 'content' put: (Dictionary new
    at: 'stdout' put: 'hello world';
    at: 'stderr' put: 'warning: something';
    at: 'return_code' put: 0;
    yourself).
  block := ClaudeContentBlock fromJson: json.
  self assert: block class equals: ClaudeBashResultBlock.
  self assert: block type equals: 'bash_code_execution_tool_result'.
  self assert: block toolUseId equals: 'tu_bash_123'.
  self assert: block stdout equals: 'hello world'.
  self assert: block stderr equals: 'warning: something'.
  self assert: block returnCode equals: 0
]

{ #category : 'tests' }
ClaudeServerToolResultBlockTest >> testCompactionBlockFromJson [
  | json block |
  json := Dictionary new.
  json at: 'type' put: 'compaction'.
  json at: 'content' put: 'Summary of prior conversation'.
  block := ClaudeContentBlock fromJson: json.
  self assert: block class equals: ClaudeCompactionBlock.
  self assert: block type equals: 'compaction'.
  self assert: block content equals: 'Summary of prior conversation'
]

{ #category : 'tests' }
ClaudeServerToolResultBlockTest >> testContainerUploadBlockFromJson [
  | json block |
  json := Dictionary new.
  json at: 'type' put: 'container_upload'.
  json at: 'file_id' put: 'file_abc123'.
  block := ClaudeContentBlock fromJson: json.
  self assert: block class equals: ClaudeContainerUploadBlock.
  self assert: block type equals: 'container_upload'.
  self assert: block fileId equals: 'file_abc123'
]

{ #category : 'tests' }
ClaudeServerToolResultBlockTest >> testTextEditorResultBlockFromJson [
  | json block |
  json := Dictionary new.
  json at: 'type' put: 'text_editor_code_execution_tool_result'.
  json at: 'tool_use_id' put: 'tu_editor_456'.
  block := ClaudeContentBlock fromJson: json.
  self assert: block class equals: ClaudeTextEditorResultBlock.
  self assert: block type equals: 'text_editor_code_execution_tool_result'.
  self assert: block toolUseId equals: 'tu_editor_456'
]

{ #category : 'tests' }
ClaudeServerToolResultBlockTest >> testToolSearchResultBlockFromJson [
  | json block |
  json := Dictionary new.
  json at: 'type' put: 'tool_search_tool_result'.
  json at: 'tool_use_id' put: 'tu_search_789'.
  json at: 'content' put: (Dictionary new
    at: 'tool_references' put: {
      Dictionary new at: 'name' put: 'get_weather'; yourself.
      Dictionary new at: 'name' put: 'get_time'; yourself };
    yourself).
  block := ClaudeContentBlock fromJson: json.
  self assert: block class equals: ClaudeToolSearchResultBlock.
  self assert: block type equals: 'tool_search_tool_result'.
  self assert: block toolUseId equals: 'tu_search_789'.
  self assert: block toolReferences size equals: 2.
  self assert: ((block toolReferences first) at: 'name') equals: 'get_weather'
]

{ #category : 'tests' }
ClaudeServerToolResultBlockTest >> testTypeRegistryContainsAllNewTypes [
	| registry newTypes |
	registry := ClaudeContentBlock typeRegistry.
	newTypes := #(
		'bash_code_execution_tool_result'
		'text_editor_code_execution_tool_result'
		'tool_search_tool_result'
		'container_upload'
		'compaction' ).
	newTypes do: [ :typeName |
		self
			assert: (registry includesKey: typeName)
			description: (String streamContents: [ :s |
				s nextPutAll: 'TypeRegistry missing: '.
				s nextPutAll: typeName ]) ]
]

{ #category : 'tests' }
ClaudeServerToolResultBlockTest >> testUnknownTypeReturnsGenericBlock [
  | json block |
  json := Dictionary new.
  json at: 'type' put: 'some_future_server_tool_result'.
  json at: 'data' put: 'payload'.
  block := ClaudeContentBlock fromJson: json.
  self assert: block class equals: ClaudeContentBlock.
  self assert: block type equals: 'some_future_server_tool_result'.
  self assert: (block rawJson at: 'data') equals: 'payload'
]
