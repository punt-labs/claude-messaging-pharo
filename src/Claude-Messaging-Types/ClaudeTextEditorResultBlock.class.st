"
A ``text_editor_code_execution_tool_result`` content block -- the result of a server-side text-editor operation appearing in ``response content`` after Claude invokes it.

### When you see it

When a request enables the server-side text-editor tool (``server_tool text_editor``) and Claude chooses to view, create, or edit a file during generation, the response content stream includes a ``ClaudeServerToolUseBlock`` (the call) followed by a ``ClaudeTextEditorResultBlock`` (the result). Sibling of ``ClaudeBashResultBlock`` (bash tool) and ``ClaudeCodeExecutionResultBlock`` (code interpreter) -- each is the result leg for a different server-executed tool.

### Accessors

- ``type`` -- always ``'text_editor_code_execution_tool_result'``
- ``toolUseId`` -- the id of the matching ``ClaudeServerToolUseBlock`` so you can pair call with result
- ``rawJson`` -- the full server payload, including a ``content`` sub-dictionary whose shape depends on the editor command (``view`` returns file contents, ``create`` / ``str_replace`` returns success metadata). Read it off ``rawJson`` when you need the specific command output.

### Example

```
ClaudeTextEditorResultBlock new type
>>> 'text_editor_code_execution_tool_result'
```

```
| block |
block := ClaudeTextEditorResultBlock fromJson: (Dictionary newFromPairs: {
    'type'. 'text_editor_code_execution_tool_result'.
    'tool_use_id'. 'toolu_abc' }).
block toolUseId
>>> 'toolu_abc'
```

### See also

``ClaudeServerToolIntegrationTest >> testTextEditorEditsFileSonnet`` -- live end-to-end guard that asserts both the call and the result block survive a round-trip.

"
Class {
	#name : 'ClaudeTextEditorResultBlock',
	#superclass : 'ClaudeContentBlock',
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeTextEditorResultBlock class >> fromJson: aDictionary [
  ^ self new
    type: (aDictionary at: 'type' ifAbsent: [ 'text_editor_code_execution_tool_result' ]);
    rawJson: aDictionary copy;
    yourself
]

{ #category : 'persistence' }
ClaudeTextEditorResultBlock class >> fromSton: stonReader [
  | dict raw |
  dict := Dictionary new.
  stonReader parseMapDo: [ :key :value | dict at: key put: value ].
  raw := dict at: #rawJson ifAbsent: [ Dictionary new ].
  ^ self fromJson: raw
]

{ #category : 'json' }
ClaudeTextEditorResultBlock >> asJson [
  ^ rawJson ifNil: [
    OrderedDictionary new
      at: 'type' put: 'text_editor_code_execution_tool_result';
      yourself ]
]

{ #category : 'initialization' }
ClaudeTextEditorResultBlock >> initialize [
  super initialize.
  type := 'text_editor_code_execution_tool_result'
]

{ #category : 'persistence' }
ClaudeTextEditorResultBlock >> stonOn: aStonWriter [
  aStonWriter writeObject: self streamMap: [ :map |
    map at: #rawJson put: rawJson ]
]

{ #category : 'accessing' }
ClaudeTextEditorResultBlock >> toolUseId [
  ^ rawJson at: 'tool_use_id' ifAbsent: [ nil ]
]
