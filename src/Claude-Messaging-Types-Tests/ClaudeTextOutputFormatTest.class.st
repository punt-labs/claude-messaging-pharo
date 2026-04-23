"
Tests for ClaudeTextOutputFormat encoding and markup slots, suffix generation, and convenience constructors.

  ClaudeTextOutputFormatTest buildSuite run
  >>> 11 ran, 11 passed, 0 skipped, 0 expected failures, 0 failures, 0 errors, 0 passed unexpected

"
Class {
	#name : 'ClaudeTextOutputFormatTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeTextOutputFormatTest >> testEncodingMarkupConstructor [
  | fmt |
  fmt := ClaudeTextOutputFormat encoding: #ascii markup: #json.
  self assert: fmt encoding equals: #ascii.
  self assert: fmt markup equals: #json.
  self assert: fmt type equals: 'text'
]

{ #category : 'tests' }
ClaudeTextOutputFormatTest >> testEncodingSuffixAscii [
  | fmt |
  fmt := ClaudeTextOutputFormat new encoding: #ascii.
  self assert: fmt encodingSuffix equals: 'Respond using only ASCII characters (U+0000-U+007F). No accented characters, no emoji, no Unicode.'
]

{ #category : 'tests' }
ClaudeTextOutputFormatTest >> testEncodingSuffixLatin1 [
  | fmt |
  fmt := ClaudeTextOutputFormat new encoding: #latin1.
  self assert: fmt encodingSuffix equals: 'Respond using only ASCII and Latin-1 characters (U+0000-U+00FF). No emoji, no Unicode beyond U+00FF.'
]

{ #category : 'tests' }
ClaudeTextOutputFormatTest >> testEncodingSuffixUtf8ReturnsNil [
  | fmt |
  fmt := ClaudeTextOutputFormat new encoding: #utf8.
  self assert: fmt encodingSuffix isNil
]

{ #category : 'tests' }
ClaudeTextOutputFormatTest >> testLatexDefault [
  | fmt |
  fmt := ClaudeTextOutputFormat latexDefault.
  self assert: fmt encoding equals: #latin1.
  self assert: fmt markup equals: #latex.
  self assert: fmt type equals: 'text'
]

{ #category : 'tests' }
ClaudeTextOutputFormatTest >> testLogDefault [
  | fmt |
  fmt := ClaudeTextOutputFormat logDefault.
  self assert: fmt encoding equals: #ascii.
  self assert: fmt markup equals: #plain.
  self assert: fmt type equals: 'text'
]

{ #category : 'tests' }
ClaudeTextOutputFormatTest >> testMarkupSuffixMicrodown [
  | fmt |
  fmt := ClaudeTextOutputFormat new markup: #microdown.
  self assert: (fmt markupSuffix beginsWith: 'Format using Microdown:').
  self assert: (fmt markupSuffix endsWith: 'No emoji in headers or bullets.')
]

{ #category : 'tests' }
ClaudeTextOutputFormatTest >> testMarkupSuffixPlain [
  | fmt |
  fmt := ClaudeTextOutputFormat new markup: #plain.
  self assert: fmt markupSuffix equals: 'No markup formatting. Plain text only.'
]

{ #category : 'tests' }
ClaudeTextOutputFormatTest >> testPharoDefault [
  | fmt |
  fmt := ClaudeTextOutputFormat pharoDefault.
  self assert: fmt encoding equals: #latin1.
  self assert: fmt markup equals: #microdown.
  self assert: fmt type equals: 'text'
]

{ #category : 'tests' }
ClaudeTextOutputFormatTest >> testSystemPromptSuffixCombinesBoth [
  | fmt suffix |
  fmt := ClaudeTextOutputFormat encoding: #latin1 markup: #microdown.
  suffix := fmt systemPromptSuffix.
  self assert: (suffix beginsWith: 'Respond using only ASCII and Latin-1').
  self assert: (suffix includesSubstring: ' Format using Microdown:').
  "Verify single space between encoding and markup suffixes"
  self assert: (suffix includesSubstring: 'U+00FF. Format')
]

{ #category : 'tests' }
ClaudeTextOutputFormatTest >> testTextOutputFormatAsJsonReturnsNil [
  "Text format is client-side only. It must not serialize to JSON for the wire."
  self assert: ClaudeTextOutputFormat pharoDefault asJson isNil
]

{ #category : 'tests' }
ClaudeTextOutputFormatTest >> testWebDefault [
  | fmt |
  fmt := ClaudeTextOutputFormat webDefault.
  self assert: fmt encoding equals: #utf8.
  self assert: fmt markup equals: #markdown.
  self assert: fmt type equals: 'text'
]
