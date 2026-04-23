"
Query parameters for ``ClaudeClient >> listFiles:``. Cursor-based pagination: set ``afterId`` (or ``beforeId``) to a cursor you got back from the previous ``ClaudeFilePage >> lastId`` (or ``firstId``), and optionally set ``limit`` to cap the page size.

### When you touch it

When the default ``listFiles`` page (no params) is not what you want. Typical cases: walking multiple pages (pass the previous ``lastId`` as ``afterId``), paging backward from a known id (``beforeId``), or capping page size with ``limit``.

```
| client params page |
client := ClaudeSDKExampleSupport resolveClient.
params := ClaudeFileListParams new
    afterId: 'file-abc';
    limit: 50;
    yourself.
page := client listFiles: params.
```

Sibling of ``ClaudeSkillListParams`` and ``ClaudeSkillVersionListParams``, which use page-token pagination (``page:``) instead of cursor IDs. The Files API and the Skills API deliberately differ here.

### Accessors and defaults

- ``afterId`` -- cursor id; fetch entries after this id (forward pagination). Default nil (no cursor).
- ``beforeId`` -- cursor id; fetch entries before this id (backward pagination). Default nil.
- ``limit`` -- page size (Integer). Default nil (server-side default applies, currently 20; capped at 100). Enforced server-side.

### Example

```
(ClaudeFileListParams new afterId: 'file-abc'; limit: 50; yourself) asQueryParams size
>>> 2
```

### See also

``ClaudeFilePage >> lastId`` / ``firstId`` -- where the next cursor comes from. ``ClaudeClient >> listFiles:`` -- the API entry that consumes this.

"
Class {
	#name : 'ClaudeFileListParams',
	#superclass : 'Object',
	#instVars : [
		'afterId',
		'beforeId',
		'limit'
	],
	#category : 'Claude-Messaging-Files',
	#package : 'Claude-Messaging-Files'
}

{ #category : 'json' }
ClaudeFileListParams class >> jsonKeyMap [
	^ {
		#afterId -> 'after_id'.
		#beforeId -> 'before_id'
	} asDictionary
]

{ #category : 'accessing' }
ClaudeFileListParams >> afterId [
	^ afterId
]

{ #category : 'accessing' }
ClaudeFileListParams >> afterId: aString [
	afterId := aString
]

{ #category : 'converting' }
ClaudeFileListParams >> asQueryParams [
	| params |
	params := Dictionary new.
	afterId ifNotNil: [ params at: 'after_id' put: afterId ].
	beforeId ifNotNil: [ params at: 'before_id' put: beforeId ].
	limit ifNotNil: [ params at: 'limit' put: limit printString ].
	^ params
]

{ #category : 'accessing' }
ClaudeFileListParams >> beforeId [
	^ beforeId
]

{ #category : 'accessing' }
ClaudeFileListParams >> beforeId: aString [
	beforeId := aString
]

{ #category : 'accessing' }
ClaudeFileListParams >> limit [
	^ limit
]

{ #category : 'accessing' }
ClaudeFileListParams >> limit: anInteger [
	limit := anInteger
]

{ #category : 'printing' }
ClaudeFileListParams >> printOn: aStream [
	aStream
		nextPutAll: 'ClaudeFileListParams('.
	afterId ifNotNil: [ aStream nextPutAll: 'after: '; nextPutAll: afterId; nextPut: $  ].
	beforeId ifNotNil: [ aStream nextPutAll: 'before: '; nextPutAll: beforeId; nextPut: $  ].
	limit ifNotNil: [ aStream nextPutAll: 'limit: '; print: limit ].
	aStream nextPut: $)
]
