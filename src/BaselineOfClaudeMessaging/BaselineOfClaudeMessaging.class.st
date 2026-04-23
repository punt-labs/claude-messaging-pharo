"
Metacello baseline for the Claude Messaging SDK for Pharo. Loads all 9
production Messaging packages and PharoKeyring into a Pharo 12 image.
No groups, no tiers — one baseline:load loads everything.

### Loading from GitHub

  Metacello new
    baseline: 'ClaudeMessaging';
    repository: 'github://punt-labs/claude-messaging-pharo:main/src';
    load.

### Pinning to a release tag

  Metacello new
    baseline: 'ClaudeMessaging';
    repository: 'github://punt-labs/claude-messaging-pharo:v1.0.0/src';
    load.

### After loading

  ClaudeClient apiKey: 'sk-ant-api03-...'
  >>> a ClaudeClient(https://api.anthropic.com)

"
Class {
	#name : 'BaselineOfClaudeMessaging',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfClaudeMessaging',
	#package : 'BaselineOfClaudeMessaging'
}

{ #category : 'baselines' }
BaselineOfClaudeMessaging class >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [
			"Standalone dependencies (no inter-package deps)"
			spec
				package: 'PharoKeyring';
				package: 'PharoKeyring-Tests' with: [ spec requires: #('PharoKeyring') ].

			"Layer 1 — domain types (no Messaging deps)"
			spec
				package: 'Claude-Messaging-Types';
				package: 'Claude-Messaging-Types-Tests' with: [ spec requires: #('Claude-Messaging-Types') ].

			"Layer 2 — error hierarchy (depends on Types)"
			spec
				package: 'Claude-Messaging-Errors' with: [ spec requires: #('Claude-Messaging-Types') ];
				package: 'Claude-Messaging-Errors-Tests' with: [ spec requires: #('Claude-Messaging-Errors') ].

			"Layer 2 — streaming (depends on Types, Errors)"
			spec
				package: 'Claude-Messaging-Streaming' with: [
					spec requires: #('Claude-Messaging-Types' 'Claude-Messaging-Errors') ];
				package: 'Claude-Messaging-Streaming-Tests' with: [
					spec requires: #('Claude-Messaging-Streaming') ].

			"Layer 2 — resource types: Files, MCP, Skills (depend on Types)"
			spec
				package: 'Claude-Messaging-Files' with: [ spec requires: #('Claude-Messaging-Types') ];
				package: 'Claude-Messaging-Files-Tests' with: [ spec requires: #('Claude-Messaging-Files') ].
			spec
				package: 'Claude-Messaging-MCP' with: [ spec requires: #('Claude-Messaging-Types') ];
				package: 'Claude-Messaging-MCP-Tests' with: [ spec requires: #('Claude-Messaging-MCP') ].
			spec
				package: 'Claude-Messaging-Skills' with: [ spec requires: #('Claude-Messaging-Types') ];
				package: 'Claude-Messaging-Skills-Tests' with: [ spec requires: #('Claude-Messaging-Skills') ].

			"Layer 3 — API client (depends on all lower layers)"
			spec
				package: 'Claude-Messaging-Client' with: [
					spec requires: #(
						'Claude-Messaging-Types'
						'Claude-Messaging-Errors'
						'Claude-Messaging-Streaming'
						'Claude-Messaging-Files'
						'Claude-Messaging-MCP'
						'Claude-Messaging-Skills') ];
				package: 'Claude-Messaging-Client-Tests' with: [
					spec requires: #('Claude-Messaging-Client') ].

			"Layer 4 — server tool definitions (extend Types classes; require Client to be present first)"
			spec
				package: 'Claude-Messaging-Tools' with: [
					spec requires: #('Claude-Messaging-Types' 'Claude-Messaging-Client') ];
				package: 'Claude-Messaging-Tools-Tests' with: [
					spec requires: #('Claude-Messaging-Tools' 'Claude-Messaging-Client-Tests' 'PharoKeyring') ].

			"Layer 5 — examples (depend on everything + PharoKeyring)"
			spec
				package: 'Claude-Messaging-Examples' with: [
					spec requires: #(
						'Claude-Messaging-Client'
						'Claude-Messaging-Tools'
						'PharoKeyring') ];
				package: 'Claude-Messaging-Examples-Tests' with: [
					spec requires: #('Claude-Messaging-Examples') ] ]
]

{ #category : 'accessing' }
BaselineOfClaudeMessaging class >> projectClass [
	^ MetacelloCypressBaselineProject
]
