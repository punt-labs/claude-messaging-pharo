"
A server-side regex tool search tool for the Claude Messages API. Enables Claude to search available tools by regex pattern matching when the tool list is large.

Tool-specific config: maxResults (optional integer limiting the number of search results returned).

  ClaudeToolSearchRegexTool new asJson at: 'type'
  >>> 'tool_search_tool_regex_20251119'

  ClaudeToolSearchRegexTool new asJson at: 'name'
  >>> 'tool_search_tool_regex'

  | tool |
  tool := ClaudeToolSearchRegexTool new.
  tool maxResults: 10.
  (tool asJson at: 'max_results')
  >>> 10

"
Class {
	#name : 'ClaudeToolSearchRegexTool',
	#superclass : 'ClaudeServerTool',
	#instVars : [
		'maxResults'
	],
	#category : 'Claude-Messaging-Tools',
	#package : 'Claude-Messaging-Tools'
}

{ #category : 'class initialization' }
ClaudeToolSearchRegexTool class >> defaultName [
  ^ 'tool_search_tool_regex'
]

{ #category : 'class initialization' }
ClaudeToolSearchRegexTool class >> defaultType [
  ^ 'tool_search_tool_regex_20251119'
]

{ #category : 'class initialization' }
ClaudeToolSearchRegexTool class >> initialize [
  "Register in the server tool type registry."
  ClaudeServerTool registerType: 'tool_search_tool_regex' forClass: self
]

{ #category : 'json' }
ClaudeToolSearchRegexTool class >> jsonKeyMap [
  ^ super jsonKeyMap , {
    #maxResults -> 'max_results'
  } asDictionary
]

{ #category : 'json - private' }
ClaudeToolSearchRegexTool >> addConfigFieldsTo: dict [
  "Add tool-search-specific config fields. Skips nil values."
  super addConfigFieldsTo: dict.
  maxResults ifNotNil: [ dict at: 'max_results' put: maxResults ]
]

{ #category : 'accessing' }
ClaudeToolSearchRegexTool >> maxResults [
  ^ maxResults
]

{ #category : 'accessing' }
ClaudeToolSearchRegexTool >> maxResults: anInteger [
  maxResults := anInteger
]

{ #category : 'json' }
ClaudeToolSearchRegexTool >> populateFromJson: aDictionary [
  "Restore tool-search-specific state from a JSON dictionary."
  super populateFromJson: aDictionary.
  maxResults := aDictionary at: 'max_results' ifAbsent: [ nil ]
]
