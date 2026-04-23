"
Tests for the ClaudeServiceTier wire-identifier catalog. One test per class-side selector pins each wire String. testAllKnownSize and testAllKnownOrder pin the catalog contract so new entries surface as a focused failure, not silent drift.
"
Class {
	#name : 'ClaudeServiceTierTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Types-Tests',
	#package : 'Claude-Messaging-Types-Tests'
}

{ #category : 'tests' }
ClaudeServiceTierTest >> testAllKnownOrder [
  "allKnown returns identifiers in documentation order."
  self assert: ClaudeServiceTier allKnown asArray equals: #('auto' 'standard_only')
]

{ #category : 'tests' }
ClaudeServiceTierTest >> testAllKnownSize [
  "The catalog ships exactly 2 known identifiers."
  self assert: ClaudeServiceTier allKnown size equals: 2
]

{ #category : 'tests' }
ClaudeServiceTierTest >> testAuto [
  self assert: ClaudeServiceTier auto equals: 'auto'
]

{ #category : 'tests' }
ClaudeServiceTierTest >> testRequestOptionsAcceptsCatalogValue [
  "ClaudeRequestOptions>>serviceTier: accepts the typed catalog
   constants as plain Strings without complaint --- backward compat
   with callers passing raw Strings."
  | opts |
  opts := ClaudeRequestOptions new.
  opts serviceTier: ClaudeServiceTier auto.
  self assert: opts serviceTier equals: 'auto'
]

{ #category : 'tests' }
ClaudeServiceTierTest >> testRequestOptionsAcceptsRawString [
  "Setter still accepts an arbitrary String --- catalog is discovery,
   not enforcement, so unknown wire values still flow through."
  | opts |
  opts := ClaudeRequestOptions new.
  opts serviceTier: 'future_tier_2027'.
  self assert: opts serviceTier equals: 'future_tier_2027'
]

{ #category : 'tests' }
ClaudeServiceTierTest >> testStandardOnly [
  self assert: ClaudeServiceTier standardOnly equals: 'standard_only'
]
