"
Shared API-key resolution for every Messaging-SDK example. Walks a fixed set of sources, returns a fresh ``ClaudeClient`` bound to the first key it finds, or raises when none is available.

### When you use it

Every runnable example in ``Claude-Messaging-Examples`` calls ``resolveClient`` as its first line so a developer running an example by hand does not have to hand-hold an API key through every selector. Use it in your own scratch scripts for the same reason. Not meant for library code -- library entry points should take a ``ClaudeClient`` argument, and let the caller choose where the key lives.

### Resolution order

1. ``PharoKeyring default lookup: 'anthropic-api' account: 'default'`` -- OS keyring (Linux secret-tool, macOS Keychain, Windows Credential Manager)
2. ``Smalltalk os environment at: 'ANTHROPIC_API_KEY'`` -- process environment
3. Error signalled with a hint: ``secret-tool store --label='Anthropic API Key' service anthropic-api account default``

Keyring before env var is deliberate: the keyring is the more durable store, and teams tend to set the env var for short-lived sessions. Tests that need to guarantee keyring resolution can stage both.

### Lives in Layer 2

This class sits in ``Claude-Messaging-Examples`` deliberately. The Agent-layer example support (``ClaudeExampleSupport``) would pull in Agent dependencies; the Messaging SDK must not depend on them. Keep new Messaging examples on ``ClaudeSDKExampleSupport``.

### Example

```
ClaudeSDKExampleSupport resolveClient
>>> a ClaudeClient
```

```
| client |
client := ClaudeSDKExampleSupport resolveClient.
client baseUrl
>>> 'https://api.anthropic.com'
```

### See also

``ClaudeClient >> apiKey:`` -- the constructor that ``resolveClient`` wraps. ``PharoKeyring`` -- the cross-platform keyring facade. ``ClaudeSimpleMessageExample`` -- the simplest example that demonstrates the typical ``resolveClient`` pattern.

"
Class {
	#name : 'ClaudeSDKExampleSupport',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'accessing' }
ClaudeSDKExampleSupport class >> resolveClient [
	"Resolve a ClaudeClient using keyring or environment variable. Does not depend on ClaudeExampleSupport (Layer 3)."
	| key |
	key := [ PharoKeyring default lookup: 'anthropic-api' account: 'default' ]
		on: Error do: [ :e | nil ].
	key ifNotNil: [ ^ ClaudeClient apiKey: key ].
	key := Smalltalk os environment at: 'ANTHROPIC_API_KEY' ifAbsent: [ nil ].
	key ifNotNil: [ ^ ClaudeClient apiKey: key ].
	Error signal: 'No API key found. Store one via: secret-tool store --label=''Anthropic API Key'' service anthropic-api account default'
]
