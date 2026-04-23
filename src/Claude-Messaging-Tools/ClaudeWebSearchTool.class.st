"
A server-side web search tool for the Claude Messages API. Enables Claude to search the web during a conversation turn.

Configure optional params (maxUses, allowedDomains, blockedDomains, userLocation, citations) before adding to a request. userLocation and citations are plain Dictionaries serialized directly.

  ClaudeWebSearchTool new asJson at: 'type'
  >>> 'web_search_20250305'

  ClaudeWebSearchTool new asJson at: 'name'
  >>> 'web_search'

  | tool |
  tool := ClaudeWebSearchTool new.
  tool maxUses: 5.
  tool allowedDomains: #('example.com').
  tool asJson size
  >>> 4

"
Class {
	#name : 'ClaudeWebSearchTool',
	#superclass : 'ClaudeServerTool',
	#instVars : [
		'userLocation'
	],
	#category : 'Claude-Messaging-Tools',
	#package : 'Claude-Messaging-Tools'
}

{ #category : 'class initialization' }
ClaudeWebSearchTool class >> defaultName [
  ^ 'web_search'
]

{ #category : 'class initialization' }
ClaudeWebSearchTool class >> defaultType [
  ^ 'web_search_20250305'
]

{ #category : 'class initialization' }
ClaudeWebSearchTool class >> initialize [
  "Register in the server tool type registry."
  ClaudeServerTool registerType: 'web_search' forClass: self
]

{ #category : 'json' }
ClaudeWebSearchTool class >> jsonKeyMap [
  ^ super jsonKeyMap , {
    #userLocation -> 'user_location'
  } asDictionary
]

{ #category : 'json - private' }
ClaudeWebSearchTool >> addConfigFieldsTo: dict [
  "Add web-search-specific config fields. Skips nil values."
  super addConfigFieldsTo: dict.
  userLocation ifNotNil: [ dict at: 'user_location' put: userLocation ]
]

{ #category : 'json' }
ClaudeWebSearchTool >> populateFromJson: aDictionary [
  "Restore web-search-specific state from a JSON dictionary."
  super populateFromJson: aDictionary.
  userLocation := aDictionary at: 'user_location' ifAbsent: [ nil ]
]

{ #category : 'accessing' }
ClaudeWebSearchTool >> userLocation [ ^ userLocation
]

{ #category : 'accessing' }
ClaudeWebSearchTool >> userLocation: aDictionary [
  userLocation := aDictionary
]
