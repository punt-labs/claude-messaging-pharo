"
Catalog of known Anthropic REQUEST-side service-tier identifiers — the
scheduling-policy values a caller may set on an outbound request to
influence which tier the scheduler will pick.

Two vocabularies, one wire field name. Anthropic's Messages API uses the
``service_tier`` key on BOTH the request and the response, but the value
sets do not overlap:

- REQUEST-side (what this class catalogs): the policy you ask for.
  Documented values are ``'auto'`` (let the scheduler pick the best tier
  available, including priority when capacity permits — the default) and
  ``'standard_only'`` (force standard even when priority capacity is
  available, typically for cost predictability).
- RESPONSE-side (NOT this class): the tier the scheduler actually
  applied. Documented values are ``'standard'``, ``'priority'``, and
  ``'batch'``. Read these via ``ClaudeUsage>>serviceTier`` on the
  returned message.

So a request with ``serviceTier: 'auto'`` may come back with
``usage serviceTier = 'priority'`` — different vocabulary, same wire
field name, same axis (which tier is in play) seen from opposite ends.
This class only catalogs the REQUEST-side identifiers; the response-side
strings flow through as plain Strings on ``ClaudeUsage`` without a
matching catalog because Anthropic's response taxonomy is informational
rather than something the caller hands back.

Class-side messages return the wire String identifier for each known
request-side tier. The catalog is a discovery surface, not a typed enum
--- pass the returned Strings to ``ClaudeRequestOptions>>serviceTier:``
or ``ClaudeMessageRequest>>serviceTier:`` to set the tier on a request.
Anthropic may add new wire values; the SDK keeps ``serviceTier:``
accepting plain Strings so unknown values still flow through.

Using class-side selectors helps catch typos earlier in normal development:
an unknown selector raises doesNotUnderstand: when the code is executed,
instead of sending an invalid wire String that surfaces as a server 400.

  ClaudeServiceTier auto
  >>> 'auto'

  ClaudeServiceTier standardOnly
  >>> 'standard_only'

  ClaudeServiceTier allKnown size
  >>> 2

Idiomatic per-request usage via ClaudeMessageRequest:

  | request |
  request := ClaudeMessageRequest new
    serviceTier: ClaudeServiceTier auto;
    yourself.
  request serviceTier
  >>> 'auto'


"
Class {
	#name : 'ClaudeServiceTier',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Types',
	#package : 'Claude-Messaging-Types'
}

{ #category : 'tiers' }
ClaudeServiceTier class >> allKnown [
  "Answer an OrderedCollection of all known tier wire identifiers in
   documentation order. Useful for docs generation, validation, and
   test parity."
  ^ OrderedCollection new
    add: self auto;
    add: self standardOnly;
    yourself
]

{ #category : 'tiers' }
ClaudeServiceTier class >> auto [
  "Wire identifier for the auto tier --- the scheduler picks the best
   tier available to the account, including priority when capacity
   permits. The default when serviceTier is not set on the request."
  ^ 'auto'
]

{ #category : 'tiers' }
ClaudeServiceTier class >> standardOnly [
  "Wire identifier for the standard-only tier --- forces the standard
   tier even when priority capacity is available, typically for
   cost-predictability."
  ^ 'standard_only'
]
