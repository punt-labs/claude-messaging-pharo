"
Renraku manifest for the ``Claude-Messaging-Types`` package. A ``PackageManifest`` is Pharo's convention for per-package lint rule metadata: Renraku walks the manifest class to learn which rules are muted, which findings are declared false positives, and so on. This class collects those declarations for Types.

### Why it is not in a Manifest package tag

Pharo's default is to place manifest classes in a ``Manifest`` package tag. This manifest is installed **without** a tag so the package keeps a single ``PackageTag`` (``#Uncategorized``) -- otherwise ``ReClassNotCategorizedRule`` would fire on every other class in the package. The no-tag choice is the cheapest fix.

### Current suppressions

- ``ruleExcessiveMethodsRuleV1FalsePositive`` -- declares ``ClaudeMessageRequest`` (the Messages API builder) as a false positive for the excessive-methods rule. Its method count tracks the breadth of the API request surface.
- ``ruleExcessiveVariablesRuleV1FalsePositive`` -- declares ``ClaudeRequestOptions`` AND ``ClaudeResponseMetadata`` as false positives for the excessive-variables rule. Each slot on each class maps 1:1 to a distinct optional field on the Messages API request body or to a documented response header.
- ``ruleRePackageManifestShouldBePackagedInManifestTagRuleV1FalsePositive`` -- self-declaration that the no-tag placement is intentional, not drift.

### Example

  ManifestClaudeMessagingTypes ruleExcessiveMethodsRuleV1FalsePositive size
  >>> 1

  ManifestClaudeMessagingTypes ruleExcessiveVariablesRuleV1FalsePositive size
  >>> 2

### See also

``ManifestClaudeMessagingClient`` and ``ManifestClaudeMessagingErrors`` -- sibling manifests for the other Messaging-SDK packages, same no-tag layout. ``make lint`` -- the canonical lint gate that reads these manifests.

"
Class {
	#name : 'ManifestClaudeMessagingTypes',
	#superclass : 'PackageManifest',
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'code-critics' }
ManifestClaudeMessagingTypes class >> ruleExcessiveMethodsRuleV1FalsePositive [
	"ClaudeMessageRequest is the public Messages API request builder: it owns the
	core request slots (model, maxTokens, messages, system, sampling, toolParams,
	thinkingParams, requestOptions, outputConfig) plus a delegating accessor for
	every grouped field — temperature, topK, topP, stopSequences (sampling),
	tools, toolChoice (toolParams), thinking (thinkingParams), metadata,
	cacheControl, serviceTier, container, speed, betas, stream, inferenceGeo,
	mcpServers (requestOptions), and outputFormat (outputConfig). Each delegating
	method is one line and exists so callers do not have to navigate the inner
	objects. The count is the cost of being the single front door for the request
	surface."
	^ #(
		#(#(#RGClassDefinition #(#ClaudeMessageRequest)) #'2026-04-19T00:00:00+00:00')
	)
]

{ #category : 'code-critics' }
ManifestClaudeMessagingTypes class >> ruleExcessiveVariablesRuleV1FalsePositive [
  "Two value objects with intentional one-slot-per-wire-field shape:
   ClaudeRequestOptions is the per-request controls aggregator
   (metadata, cacheControl, serviceTier, eagerInputStreaming, betas,
   stream, inferenceGeo, container, speed, mcpServers --- each slot
   maps to a distinct optional field on the Messages API request body).
   ClaudeResponseMetadata is the response-header aggregator added in
   mission yvyt+pch2: requestId plus the nine anthropic-ratelimit-*
   counters plus retryAfter --- 11 slots, each pinned to a documented
   wire header. Grouping the rate-limit slots by axis would obscure
   the 1:1 wire mapping and force every accessor to delegate twice.
   The slot counts on both classes track the API surface, which grows
   whenever Anthropic adds a request-level option or response header."
  ^ #(
    #(#(#RGClassDefinition #(#ClaudeRequestOptions)) #'2026-04-19T00:00:00+00:00')
    #(#(#RGClassDefinition #(#ClaudeResponseMetadata)) #'2026-04-22T00:00:00+00:00')
  )
]

{ #category : 'code-critics' }
ManifestClaudeMessagingTypes class >> ruleRePackageManifestShouldBePackagedInManifestTagRuleV1FalsePositive [
	"This manifest is intentionally NOT in a Manifest package tag — see the class comment for the rationale."
	^ #(
		#(#(#RGClassDefinition #(#ManifestClaudeMessagingTypes)) #'2026-04-19T00:00:00+00:00')
	)
]
