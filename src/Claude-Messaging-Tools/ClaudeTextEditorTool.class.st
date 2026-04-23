"
A server-side text editor tool for the Claude Messages API. Enables Claude to view and edit files using str_replace operations on Anthropic servers during a conversation turn.

Tool-specific config: maxCharacters (optional integer limiting file content size).

  ClaudeTextEditorTool new asJson at: 'type'
  >>> 'text_editor_20250728'

  ClaudeTextEditorTool new asJson at: 'name'
  >>> 'str_replace_based_edit_tool'

  | tool |
  tool := ClaudeTextEditorTool new.
  tool maxCharacters: 50000.
  (tool asJson at: 'max_characters')
  >>> 50000

"
Class {
	#name : 'ClaudeTextEditorTool',
	#superclass : 'ClaudeServerTool',
	#instVars : [
		'maxCharacters'
	],
	#category : 'Claude-Messaging-Tools',
	#package : 'Claude-Messaging-Tools'
}

{ #category : 'class initialization' }
ClaudeTextEditorTool class >> defaultName [
  ^ 'str_replace_based_edit_tool'
]

{ #category : 'class initialization' }
ClaudeTextEditorTool class >> defaultType [
  ^ 'text_editor_20250728'
]

{ #category : 'class initialization' }
ClaudeTextEditorTool class >> initialize [
  "Register in the server tool type registry."
  ClaudeServerTool registerType: 'str_replace_based_edit_tool' forClass: self
]

{ #category : 'json' }
ClaudeTextEditorTool class >> jsonKeyMap [
  ^ super jsonKeyMap , {
    #maxCharacters -> 'max_characters'
  } asDictionary
]

{ #category : 'json - private' }
ClaudeTextEditorTool >> addConfigFieldsTo: dict [
  "Add text-editor-specific config fields. Skips nil values."
  super addConfigFieldsTo: dict.
  maxCharacters ifNotNil: [ dict at: 'max_characters' put: maxCharacters ]
]

{ #category : 'accessing' }
ClaudeTextEditorTool >> maxCharacters [
  ^ maxCharacters
]

{ #category : 'accessing' }
ClaudeTextEditorTool >> maxCharacters: anInteger [
  maxCharacters := anInteger
]

{ #category : 'json' }
ClaudeTextEditorTool >> populateFromJson: aDictionary [
  "Restore text-editor-specific state from a JSON dictionary."
  super populateFromJson: aDictionary.
  maxCharacters := aDictionary at: 'max_characters' ifAbsent: [ nil ]
]
