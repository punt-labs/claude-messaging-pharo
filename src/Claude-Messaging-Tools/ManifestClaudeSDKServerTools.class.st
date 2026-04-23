"
Package manifest for Claude-SDK-ServerTools. Registers false positives for Renraku lint rules.
"
Class {
	#name : 'ManifestClaudeSDKServerTools',
	#superclass : 'PackageManifest',
	#category : 'Claude-Messaging-Tools',
	#package : 'Claude-Messaging-Tools'
}

{ #category : 'false positives' }
ManifestClaudeSDKServerTools class >> ruleExcessiveVariablesRuleV1FalsePositive [
  "ClaudeServerTool aggregates base fields (type, name, cacheControl, etc.)
  plus shared config (maxUses, allowedDomains, blockedDomains, citations)
  pulled up from subclasses. Each slot maps 1:1 to an API JSON field;
  collapsing them into a dictionary would hide intent."
  ^ #(
    #(#(#RGClassDefinition #(#ClaudeServerTool)) #'2026-04-18T00:00:00+00:00')
  )
]

{ #category : 'false positives' }
ManifestClaudeSDKServerTools class >> ruleRePackageManifestShouldBePackagedInManifestTagRuleV1FalsePositive [
  ^ #(
    #(#(#RGClassDefinition #(#ManifestClaudeSDKServerTools)) #'2026-04-18T00:00:00+00:00')
  )
]
