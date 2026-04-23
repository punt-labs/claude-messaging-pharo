"
A ``bash_code_execution_tool_result`` content block -- the server-side Bash server tool's output appearing in ``response content`` after Claude invokes it.

### When you see it

When a request enables the server-side bash tool (``server_tool bash``) and Claude chooses to execute a command during generation, the response content stream includes a ``ClaudeServerToolUseBlock`` (the call) followed by a ``ClaudeBashResultBlock`` (the result). Sibling of ``ClaudeTextEditorResultBlock`` (text-editor tool) and ``ClaudeCodeExecutionResultBlock`` (code interpreter) -- each is the result leg for a different server-executed tool.

### Accessors

- ``type`` -- always ``'bash_code_execution_tool_result'``
- ``stdout`` -- command's standard output (String), or nil when absent
- ``stderr`` -- command's standard error (String), or nil
- ``returnCode`` -- exit status (Integer), or nil
- ``toolUseId`` -- the id of the matching ``ClaudeServerToolUseBlock`` so you can pair call with result

### Example

```
ClaudeBashResultBlock new type
>>> 'bash_code_execution_tool_result'
```

```
| block |
block := ClaudeBashResultBlock fromJson: (Dictionary newFromPairs: {
    'type'. 'bash_code_execution_tool_result'.
    'content'. (Dictionary newFromPairs: { 'stdout'. 'hi'. 'stderr'. ''. 'return_code'. 0 }).
    'tool_use_id'. 'toolu_abc' }).
block stdout
>>> 'hi'
```

### See also

``ClaudeServerToolIntegrationTest >> testBashExecutesCommandSonnet`` -- live end-to-end guard that asserts both the call and the result block survive a round-trip.

"
Class {
	#name : 'ClaudeBashResultBlock',
	#superclass : 'ClaudeContentBlock',
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'json' }
ClaudeBashResultBlock class >> fromJson: aDictionary [
  ^ self new
    type: (aDictionary at: 'type' ifAbsent: [ 'bash_code_execution_tool_result' ]);
    rawJson: aDictionary copy;
    yourself
]

{ #category : 'persistence' }
ClaudeBashResultBlock class >> fromSton: stonReader [
  | dict raw |
  dict := Dictionary new.
  stonReader parseMapDo: [ :key :value | dict at: key put: value ].
  raw := dict at: #rawJson ifAbsent: [ Dictionary new ].
  ^ self fromJson: raw
]

{ #category : 'json' }
ClaudeBashResultBlock >> asJson [
  ^ rawJson ifNil: [
    OrderedDictionary new
      at: 'type' put: 'bash_code_execution_tool_result';
      yourself ]
]

{ #category : 'initialization' }
ClaudeBashResultBlock >> initialize [
  super initialize.
  type := 'bash_code_execution_tool_result'
]

{ #category : 'accessing' }
ClaudeBashResultBlock >> returnCode [
  ^ (rawJson at: 'content' ifAbsent: [ ^ nil ])
      at: 'return_code' ifAbsent: [ nil ]
]

{ #category : 'accessing' }
ClaudeBashResultBlock >> stderr [
  ^ (rawJson at: 'content' ifAbsent: [ ^ nil ])
      at: 'stderr' ifAbsent: [ nil ]
]

{ #category : 'accessing' }
ClaudeBashResultBlock >> stdout [
  ^ (rawJson at: 'content' ifAbsent: [ ^ nil ])
      at: 'stdout' ifAbsent: [ nil ]
]

{ #category : 'persistence' }
ClaudeBashResultBlock >> stonOn: aStonWriter [
  aStonWriter writeObject: self streamMap: [ :map |
    map at: #rawJson put: rawJson ]
]

{ #category : 'accessing' }
ClaudeBashResultBlock >> toolUseId [
  ^ rawJson at: 'tool_use_id' ifAbsent: [ nil ]
]
