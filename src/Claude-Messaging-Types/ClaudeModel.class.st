"
Model ID constants for the Claude API. Class-side factory methods return model identifier strings.

haiku35 - Claude 3 Haiku (oldest, cheapest)
haiku45 - Claude 4.5 Haiku
sonnet45 / sonnet45v - Claude Sonnet 4.5 (versioned)
sonnet46 - Claude Sonnet 4.6 (latest Sonnet alias)
opus4 / opus4v - Claude Opus 4 (versioned)
opus46 / opus46v - Claude Opus 4.6
opus47 / opus47v - Claude Opus 4.7 (latest Opus alias)

Example:
  ClaudeModel opus47 ""=> claude-opus-4-7""

### Examples

```
ClaudeModel opus47
>>> 'claude-opus-4-7'

ClaudeModel opus46
>>> 'claude-opus-4-6'

ClaudeModel sonnet46
>>> 'claude-sonnet-4-6'

ClaudeModel haiku45
>>> 'claude-haiku-4-5-20251001'
```

"
Class {
	#name : 'ClaudeModel',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'models' }
ClaudeModel class >> haiku35 [
	"Claude 3 Haiku -- cheapest, fastest"
	^ 'claude-3-haiku-20240307'
]

{ #category : 'models' }
ClaudeModel class >> haiku45 [
	"Claude Haiku 4.5"
	^ 'claude-haiku-4-5-20251001'
]

{ #category : 'models' }
ClaudeModel class >> opus4 [
	"Claude Opus 4"
	^ 'claude-opus-4-20250514'
]

{ #category : 'models' }
ClaudeModel class >> opus46 [
	"Claude Opus 4.6"
	^ 'claude-opus-4-6'
]

{ #category : 'models' }
ClaudeModel class >> opus46v [
	"Claude Opus 4.6 (versioned -- same as alias until date-versioned ID is published)"
	^ 'claude-opus-4-6'
]

{ #category : 'models' }
ClaudeModel class >> opus47 [
	"Claude Opus 4.7 -- latest Opus"
	^ 'claude-opus-4-7'
]

{ #category : 'models' }
ClaudeModel class >> opus47v [
	"Claude Opus 4.7 (versioned -- same as alias until date-versioned ID is published)"
	^ 'claude-opus-4-7'
]

{ #category : 'models' }
ClaudeModel class >> opus4v [
	"Claude Opus 4 (versioned)"
	^ 'claude-opus-4-20250514'
]

{ #category : 'models' }
ClaudeModel class >> sonnet45 [
	"Claude Sonnet 4.5"
	^ 'claude-sonnet-4-5-20250929'
]

{ #category : 'models' }
ClaudeModel class >> sonnet45v [
	^ 'claude-sonnet-4-5-20250929'
]

{ #category : 'models' }
ClaudeModel class >> sonnet46 [
	"Claude Sonnet 4.6 -- latest Sonnet"
	^ 'claude-sonnet-4-6'
]
