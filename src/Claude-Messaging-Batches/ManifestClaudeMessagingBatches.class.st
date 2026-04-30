"
Renraku manifest for the ``Claude-Messaging-Batches`` package. Carries per-package lint rule metadata: false-positive declarations and similar instructions Renraku reads when walking the package.

### Why it is not in a Manifest package tag

Pharo's default is to place manifest classes in a ``Manifest`` package tag. This manifest is installed without a tag so the Batches package keeps a single ``PackageTag`` (``#Uncategorized``), mirroring the ``ManifestClaudeMessagingTypes`` and ``ManifestClaudeMessagingClient`` layouts.

### Current suppressions

- ``ruleExcessiveVariablesRuleV1FalsePositive`` -- ``ClaudeBatch`` has 10 instance variables, every one wire-mandated by the Anthropic Message Batches API resource shape (``id``, ``processing_status``, ``request_counts``, ``created_at``, ``expires_at``, ``ended_at``, ``cancel_initiated_at``, ``archived_at``, ``results_url``, ``type``). The fields are not optional or accidental -- splitting them would invent an artificial sub-object that the API does not have.

### Example

```
ManifestClaudeMessagingBatches ruleExcessiveVariablesRuleV1FalsePositive size
>>> 1
```

### See also

``ManifestClaudeMessagingClient`` and ``ManifestClaudeMessagingTypes`` -- sibling manifests for the other Messaging-SDK packages. ``ClaudeBatch`` -- the wire-shape class whose variable count is declared a false positive here.
"
Class {
	#name : 'ManifestClaudeMessagingBatches',
	#superclass : 'PackageManifest',
	#category : 'Claude-Messaging-Batches',
	#package : 'Claude-Messaging-Batches'
}

{ #category : 'code-critics' }
ManifestClaudeMessagingBatches class >> ruleExcessiveVariablesRuleV1FalsePositive [
	"ClaudeBatch carries 10 instance variables (id, processingStatus, requestCounts,
	 createdAt, expiresAt, endedAt, cancelInitiatedAt, archivedAt, resultsUrl, type)
	 because the Anthropic Message Batches API resource has those 10 fields.
	 Splitting them would invent an artificial sub-object that the wire shape does
	 not have."
	^ #(
		#(#(#RGClassDefinition #(#ClaudeBatch)) #'2026-04-23T00:00:00+00:00')
	)
]

{ #category : 'code-critics' }
ManifestClaudeMessagingBatches class >> ruleRePackageManifestShouldBePackagedInManifestTagRuleV1FalsePositive [
	"This manifest is intentionally NOT in a Manifest package tag, mirroring the existing
	 ManifestClaudeMessagingTypes / ManifestClaudeMessagingClient pattern. The Manifest
	 tag would only contain this one class and would force-tag classes out of Uncategorized."
	^ #(
		#(#(#RGClassDefinition #(#ManifestClaudeMessagingBatches)) #'2026-04-23T00:00:00+00:00')
	)
]
