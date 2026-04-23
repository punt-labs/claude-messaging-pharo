"
A server-side web fetch tool for the Claude Messages API. Enables Claude to fetch web page content during a conversation turn.

Configure optional params (maxUses, allowedDomains, blockedDomains, maxContentTokens, useCache, citations) before adding to a request. citations is a plain Dictionary serialized directly.

  ClaudeWebFetchTool new asJson at: 'type'
  >>> 'web_fetch_20250910'

  ClaudeWebFetchTool new asJson at: 'name'
  >>> 'web_fetch'

  | tool |
  tool := ClaudeWebFetchTool new.
  tool maxUses: 3.
  tool maxContentTokens: 10000.
  tool asJson size
  >>> 4

"
Class {
	#name : 'ClaudeWebFetchTool',
	#superclass : 'ClaudeServerTool',
	#instVars : [
		'maxContentTokens',
		'useCache'
	],
	#category : 'Claude-Messaging-Tools',
	#package : 'Claude-Messaging-Tools'
}

{ #category : 'class initialization' }
ClaudeWebFetchTool class >> defaultName [
  ^ 'web_fetch'
]

{ #category : 'class initialization' }
ClaudeWebFetchTool class >> defaultType [
  ^ 'web_fetch_20250910'
]

{ #category : 'class initialization' }
ClaudeWebFetchTool class >> initialize [
  "Register in the server tool type registry."
  ClaudeServerTool registerType: 'web_fetch' forClass: self
]

{ #category : 'json' }
ClaudeWebFetchTool class >> jsonKeyMap [
  ^ super jsonKeyMap , {
    #maxContentTokens -> 'max_content_tokens'.
    #useCache -> 'use_cache'
  } asDictionary
]

{ #category : 'json - private' }
ClaudeWebFetchTool >> addConfigFieldsTo: dict [
  "Add web-fetch-specific config fields. Skips nil values."
  super addConfigFieldsTo: dict.
  maxContentTokens ifNotNil: [ dict at: 'max_content_tokens' put: maxContentTokens ].
  useCache ifNotNil: [ dict at: 'use_cache' put: useCache ]
]

{ #category : 'accessing' }
ClaudeWebFetchTool >> maxContentTokens [ ^ maxContentTokens
]

{ #category : 'accessing' }
ClaudeWebFetchTool >> maxContentTokens: anInteger [
  maxContentTokens := anInteger
]

{ #category : 'json' }
ClaudeWebFetchTool >> populateFromJson: aDictionary [
  "Restore web-fetch-specific state from a JSON dictionary."
  super populateFromJson: aDictionary.
  maxContentTokens := aDictionary at: 'max_content_tokens' ifAbsent: [ nil ].
  useCache := aDictionary at: 'use_cache' ifAbsent: [ nil ]
]

{ #category : 'accessing' }
ClaudeWebFetchTool >> useCache [ ^ useCache
]

{ #category : 'accessing' }
ClaudeWebFetchTool >> useCache: aBoolean [
  useCache := aBoolean
]
