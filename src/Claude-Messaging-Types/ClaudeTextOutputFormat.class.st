"
Text output format for Claude API responses (the default). The API only accepts json_schema as a response_format type, so asJson returns nil -- text format is client-side only. Its effect is conveyed via system prompt injection (encoding and markup constraints).

Two optional axes control system prompt constraints:
- encoding (#ascii, #latin1, #utf8) -- character set constraint
- markup (#plain, #microdown, #markdown, #json, #html, #latex) -- formatting constraint

  ClaudeTextOutputFormat new asJson
  >>> nil

  ClaudeTextOutputFormat pharoDefault encoding
  >>> #latin1

  ClaudeTextOutputFormat pharoDefault markup
  >>> #microdown

  ClaudeTextOutputFormat logDefault systemPromptSuffix
  >>> 'Respond using only ASCII characters (U+0000-U+007F). No accented characters, no emoji, no Unicode. No markup formatting. Plain text only.'

"
Class {
	#name : 'ClaudeTextOutputFormat',
	#superclass : 'ClaudeOutputFormat',
	#instVars : [
		'encoding',
		'markup'
	],
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'instance creation' }
ClaudeTextOutputFormat class >> encoding: encodingSymbol markup: markupSymbol [
  ^ self new
    encoding: encodingSymbol;
    markup: markupSymbol;
    yourself
]

{ #category : 'instance creation' }
ClaudeTextOutputFormat class >> latexDefault [
  ^ self encoding: #latin1 markup: #latex
]

{ #category : 'instance creation' }
ClaudeTextOutputFormat class >> logDefault [
  ^ self encoding: #ascii markup: #plain
]

{ #category : 'instance creation' }
ClaudeTextOutputFormat class >> pharoDefault [
  ^ self encoding: #latin1 markup: #microdown
]

{ #category : 'instance creation' }
ClaudeTextOutputFormat class >> webDefault [
  ^ self encoding: #utf8 markup: #markdown
]

{ #category : 'json' }
ClaudeTextOutputFormat >> asJson [
  "Text output format is a client-side concept for system prompt injection only.
   It must not be serialized on the wire — the API only accepts json_schema as a format type.
   Return nil so addFieldsTo: skips the format key entirely."
  ^ nil
]

{ #category : 'accessing' }
ClaudeTextOutputFormat >> encoding [
  ^ encoding
]

{ #category : 'accessing' }
ClaudeTextOutputFormat >> encoding: aSymbol [
  encoding := aSymbol
]

{ #category : 'suffix' }
ClaudeTextOutputFormat >> encodingSuffix [
  "Return an encoding constraint string for the system prompt, or nil for utf8."
  encoding = #ascii ifTrue: [
    ^ 'Respond using only ASCII characters (U+0000-U+007F). No accented characters, no emoji, no Unicode.' ].
  encoding = #latin1 ifTrue: [
    ^ 'Respond using only ASCII and Latin-1 characters (U+0000-U+00FF). No emoji, no Unicode beyond U+00FF.' ].
  ^ nil
]

{ #category : 'initialization' }
ClaudeTextOutputFormat >> initialize [
  type := 'text'
]

{ #category : 'accessing' }
ClaudeTextOutputFormat >> markup [
  ^ markup
]

{ #category : 'accessing' }
ClaudeTextOutputFormat >> markup: aSymbol [
  markup := aSymbol
]

{ #category : 'suffix' }
ClaudeTextOutputFormat >> markupSuffix [
  "Return a markup constraint string for the system prompt, or nil."
  markup = #plain ifTrue: [
    ^ 'No markup formatting. Plain text only.' ].
  markup = #microdown ifTrue: [
    ^ 'Format using Microdown: # headers (1-6), **bold**, _italic_, `monospace`, ``` code blocks, - unordered lists, 1. ordered lists, > blockquotes, *** horizontal rules, | pipe tables, [text](url) links. No HTML tags. No task lists. No emoji in headers or bullets.' ].
  markup = #markdown ifTrue: [
    ^ 'Format using GitHub-flavored Markdown.' ].
  markup = #json ifTrue: [
    ^ 'Respond in JSON format.' ].
  markup = #html ifTrue: [
    ^ 'Format using HTML.' ].
  markup = #latex ifTrue: [
    ^ 'Format using LaTeX. Use \section, \subsection, \textbf, \textit, \begin{itemize}, \begin{verbatim}, \href for links. No Markdown, no HTML.' ].
  ^ nil
]

{ #category : 'accessing' }
ClaudeTextOutputFormat >> systemPromptSuffix [
  "Return the combined encoding and markup constraint string for system prompt injection."
  ^ String streamContents: [ :s |
    self encodingSuffix ifNotNil: [ :es | s nextPutAll: es ].
    self markupSuffix ifNotNil: [ :ms |
      s isEmpty ifFalse: [ s nextPut: Character space ].
      s nextPutAll: ms ] ]
]
