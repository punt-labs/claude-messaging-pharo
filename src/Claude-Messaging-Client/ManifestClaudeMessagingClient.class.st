"
Renraku manifest for the ``Claude-Messaging-Client`` package. A ``PackageManifest`` is Pharo's convention for per-package lint rule metadata: Renraku walks the manifest class to learn which rules are muted, which findings are declared false positives, and so on. This class collects those declarations for the Client layer.

### Why it is not in a Manifest package tag

Pharo's default is to place manifest classes in a ``Manifest`` package tag. This manifest is installed **without** a tag so the Client package keeps a single ``PackageTag`` (``#Uncategorized``), mirroring the ``ManifestClaudeMessagingTypes`` layout. The Manifest tag would only contain this one class and would force-tag ``ClaudeClient`` out of Uncategorized, which is its current home.

### Current suppressions

- ``ruleExcessiveMethodsRuleV1FalsePositive`` -- declares ``ClaudeClient`` as a false positive for the excessive-methods rule. ``ClaudeClient`` is the unified front door for Messages, Files, and Skills APIs; its method count tracks three API surfaces. A per-API facade split (``ClaudeFilesAPI``, ``ClaudeSkillsAPI``) is a tracked follow-up; until then the breadth is the design intent.
- ``ruleRePackageManifestShouldBePackagedInManifestTagRuleV1FalsePositive`` -- self-declaration that the no-tag placement is intentional.

### Example

```
ManifestClaudeMessagingClient ruleExcessiveMethodsRuleV1FalsePositive size
>>> 1
```

### See also

``ManifestClaudeMessagingTypes`` and ``ManifestClaudeMessagingErrors`` -- sibling manifests for the other Messaging-SDK packages. ``ClaudeClient`` -- the class whose method count is declared a false positive here.

"
Class {
	#name : 'ManifestClaudeMessagingClient',
	#superclass : 'PackageManifest',
	#category : 'Claude-Messaging-Client',
	#package : 'Claude-Messaging-Client'
}

{ #category : 'code-critics' }
ManifestClaudeMessagingClient class >> ruleExcessiveMethodsRuleV1FalsePositive [
	"ClaudeClient is the unified front door for the Anthropic API: Messages
	(sendMessage:, streamMessage:do:, countTokens:, listModels, getModel:),
	Files (uploadFile:..., listFiles, getFileMetadata:, downloadFile:,
	deleteFile:), and Skills (uploadDirectory:displayTitle:, getSkill:,
	listSkills, listSkills:, deleteSkill:, uploadVersionFor:fromDirectory:,
	getVersion:for:, listVersionsFor:, listVersionsFor:params:,
	deleteVersion:for:). Each API surface is a separate protocol and the
	count is the cost of being the single client constructor users learn
	first. Decomposing into per-API facades (ClaudeFilesAPI, ClaudeSkillsAPI)
	is a tracked follow-up; until then the breadth is the design intent."
	^ #(
		#(#(#RGClassDefinition #(#ClaudeClient)) #'2026-04-19T00:00:00+00:00')
	)
]

{ #category : 'code-critics' }
ManifestClaudeMessagingClient class >> ruleRePackageManifestShouldBePackagedInManifestTagRuleV1FalsePositive [
	"This manifest is intentionally NOT in a Manifest package tag, mirroring the existing
	 ManifestClaudeMessagingTypes / ManifestClaudeAgentExchange pattern. The Manifest tag
	 would only contain this one class and would also force-tag the ClaudeClient class out
	 of Uncategorized, which is its current home."
	^ #(
		#(#(#RGClassDefinition #(#ManifestClaudeMessagingClient)) #'2026-04-19T00:00:00+00:00')
	)
]

{ #category : 'code-critics' }
ManifestClaudeMessagingClient class >> ruleSentNotImplementedRuleV1FalsePositive [
	"ClaudeClient>>executeWithRetry: sends `rl acquire` to its rateLimiter slot.
	 The ClaudeRateLimiter class lives in the upstream Claude-Agent-Exchange
	 package (claude-agent-sdk-smalltalk repo) and is not loaded by the
	 Messaging SDK alone. The slot is intentionally pluggable so the Agent
	 SDK can inject a token-bucket limiter over the SDK-shared API key.
	 No implementor of #acquire exists in this image; declared as a false
	 positive until the rate-limiter abstraction migrates into the
	 Messaging SDK proper (tracked separately)."
	^ #(
		#(#(#RGMethodDefinition #(#ClaudeClient #executeWithRetry: #false)) #'2026-04-30T00:00:00+00:00')
	)
]
