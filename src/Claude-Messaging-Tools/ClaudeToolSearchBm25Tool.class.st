"
A server-side BM25 tool search tool for the Claude Messages API. Enables Claude to search available tools by relevance using BM25 ranking when the tool list is large.

Tool-specific config: maxResults (optional integer limiting the number of search results returned).

  ClaudeToolSearchBm25Tool new asJson at: 'type'
  >>> 'tool_search_tool_bm25_20251119'

  ClaudeToolSearchBm25Tool new asJson at: 'name'
  >>> 'tool_search_tool_bm25'

  | tool |
  tool := ClaudeToolSearchBm25Tool new.
  tool maxResults: 10.
  (tool asJson at: 'max_results')
  >>> 10

"
Class {
	#name : 'ClaudeToolSearchBm25Tool',
	#superclass : 'ClaudeServerTool',
	#instVars : [
		'maxResults'
	],
	#category : 'Claude-Messaging-Tools',
	#package : 'Claude-Messaging-Tools'
}

{ #category : 'class initialization' }
ClaudeToolSearchBm25Tool class >> defaultName [
  ^ 'tool_search_tool_bm25'
]

{ #category : 'class initialization' }
ClaudeToolSearchBm25Tool class >> defaultType [
  ^ 'tool_search_tool_bm25_20251119'
]

{ #category : 'class initialization' }
ClaudeToolSearchBm25Tool class >> initialize [
  "Register in the server tool type registry."
  ClaudeServerTool registerType: 'tool_search_tool_bm25' forClass: self
]

{ #category : 'json' }
ClaudeToolSearchBm25Tool class >> jsonKeyMap [
  ^ super jsonKeyMap , {
    #maxResults -> 'max_results'
  } asDictionary
]

{ #category : 'json - private' }
ClaudeToolSearchBm25Tool >> addConfigFieldsTo: dict [
  "Add tool-search-specific config fields. Skips nil values."
  super addConfigFieldsTo: dict.
  maxResults ifNotNil: [ dict at: 'max_results' put: maxResults ]
]

{ #category : 'accessing' }
ClaudeToolSearchBm25Tool >> maxResults [
  ^ maxResults
]

{ #category : 'accessing' }
ClaudeToolSearchBm25Tool >> maxResults: anInteger [
  maxResults := anInteger
]

{ #category : 'json' }
ClaudeToolSearchBm25Tool >> populateFromJson: aDictionary [
  "Restore tool-search-specific state from a JSON dictionary."
  super populateFromJson: aDictionary.
  maxResults := aDictionary at: 'max_results' ifAbsent: [ nil ]
]
