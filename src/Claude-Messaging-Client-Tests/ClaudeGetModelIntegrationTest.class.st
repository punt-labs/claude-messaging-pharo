"
Live end-to-end integration test for ``ClaudeClient >> getModel:``. Fetches model metadata for ``claude-sonnet-4-6`` from api.anthropic.com and asserts the typed return is a ``ClaudeModelInfo`` whose ``id``, ``displayName``, and ``createdAt`` are populated from the real server body.

This test exists because ``listModels`` is already covered by ``ClaudeIntegrationTest >> testListModels``, but ``getModel:`` — the single-id lookup variant — has no live coverage. Both endpoints share the same response type (``ClaudeModelInfo``), but different transport paths, so a silent regression in one would not be caught by the other.

**Preconditions.** Requires an Anthropic API key, resolved by ``ClaudeSDKExampleSupport resolveClient``. When no key is present the test skips via ``self skip`` — it does not fail on a key-less image. The default suite excludes this class by protocol; only ``integrationSuite`` includes it.

**Server-computed assertions.**

- return is a ``ClaudeModelInfo`` (typed parse succeeded)
- ``info id = 'claude-sonnet-4-6'`` (server echoes the requested id)
- ``info displayName isNotEmpty`` (server-computed friendly name)
- ``info createdAt isNotNil`` (server-computed timestamp)

**No cleanup.** The models endpoint creates no server-side resources.

  ClaudeGetModelIntegrationTest buildSuite
  >>> a TestSuite

"
Class {
	#name : 'ClaudeGetModelIntegrationTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Client-Tests',
	#package : 'Claude-Messaging-Client-Tests'
}

{ #category : 'accessing' }
ClaudeGetModelIntegrationTest >> defaultTimeLimit [
	"One live round-trip to api.anthropic.com — the /v1/models endpoint
	 is quick but the default 10 s test timeout is still too tight for
	 healthy-but-slow network conditions."
	^ 2 minutes
]

{ #category : 'tests-integration' }
ClaudeGetModelIntegrationTest >> testGetModelReturnsModelInfoForKnownId [
	"Drive a live /v1/models/:id call via ClaudeClient>>getModel: and
	 assert the typed return is a ClaudeModelInfo whose fields were
	 populated from the server body:
	  - id equals the requested id (server echo)
	  - displayName non-empty (server-computed friendly name)
	  - createdAt non-nil (server-computed timestamp)
	  - type equals 'model' (server-computed type discriminator;
	    caught by a typed-parse regression on the field)
	 listModels is already covered by ClaudeIntegrationTest >>
	 testListModels; this test closes the getModel: gap.
	 Uses ClaudeModel sonnet46 ('claude-sonnet-4-6') to stay in sync
	 with the rest of the examples.
	 Skips cleanly when no API key is present."
	| client modelId info |
	[ client := ClaudeSDKExampleSupport resolveClient ]
		on: Error do: [ :e | ^ self skip ].
	modelId := ClaudeModel sonnet46.
	info := client getModel: modelId.
	self
		assert: (info isKindOf: ClaudeModelInfo)
		description: 'getModel: must return a ClaudeModelInfo; got ' , info class name.
	self
		assert: info id = modelId
		description: 'model id must echo the request; got ' , info id printString , ' expected ' , modelId printString.
	self
		assert: info displayName isNotEmpty
		description: 'model displayName must be non-empty; got ' , info displayName printString.
	self
		assert: info createdAt isNotNil
		description: 'model createdAt must be non-nil'.
	self
		assert: info type = 'model'
		description: 'model type must be ''model'' (server-computed type field); got ' , info type printString
]
