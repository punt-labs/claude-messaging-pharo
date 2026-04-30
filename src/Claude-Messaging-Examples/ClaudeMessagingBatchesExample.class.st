"
Demonstrate the Batches API: submit a small batch of Messages requests, poll until the batch ends, then stream the JSONL results and dispatch each entry polymorphically on its outcome (succeeded, errored, canceled, expired).

The build helper is pure and doctestable; the run helper takes a `ClaudeClient` and performs the full create -> poll -> stream loop, logging every result to the Transcript.

The streaming block uses `isSucceeded`, `isErrored`, `isCanceled`, and `isExpired` predicates instead of comparing `result type` strings -- that's the exact ergonomic this example exists to demonstrate. Adding a fifth outcome on the wire would never break this call site.

  ClaudeMessagingBatchesExample buildSampleCreateParams size
  >>> 2

  ClaudeMessagingBatchesExample buildSampleCreateParams requests first customId
  >>> 'r-1'

  ClaudeMessagingBatchesExample buildSampleCreateParams requests second customId
  >>> 'r-2'

  ClaudeMessagingBatchesExample buildSampleCreateParams requests first params model
  >>> 'claude-haiku-4-5-20251001'

  ClaudeMessagingBatchesExample buildSampleCreateParams requests first params maxTokens
  >>> 64

"
Class {
	#name : 'ClaudeMessagingBatchesExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'building' }
ClaudeMessagingBatchesExample class >> buildSampleCreateParams [
	"Build a sample ClaudeBatchCreateParams with two trivial Messages requests.
	 Each request uses Haiku with a tiny maxTokens to keep batch turnaround fast
	 when the example is run live. Pure -- no network call, safe to invoke in
	 doctests and unit tests."
	| params |
	params := ClaudeBatchCreateParams new.
	params addRequest: (ClaudeBatchRequest
		customId: 'r-1'
		params: (ClaudeMessageRequest new
			model: ClaudeModel haiku45;
			maxTokens: 64;
			addUserMessage: 'Say hello in one short sentence.';
			yourself)).
	params addRequest: (ClaudeBatchRequest
		customId: 'r-2'
		params: (ClaudeMessageRequest new
			model: ClaudeModel haiku45;
			maxTokens: 64;
			addUserMessage: 'Name one primary color in one word.';
			yourself)).
	^ params
]

{ #category : 'private' }
ClaudeMessagingBatchesExample class >> logCanceledOrExpired: anEntry [
	"Log a canceled or expired batch entry to the Transcript with the outcome type."
	| label |
	label := anEntry isCanceled ifTrue: [ 'CANCELED' ] ifFalse: [ 'EXPIRED' ].
	Transcript
		nextPutAll: anEntry customId;
		space;
		nextPutAll: label;
		cr
]

{ #category : 'private' }
ClaudeMessagingBatchesExample class >> logErrored: anEntry [
	"Log an errored batch entry to the Transcript with the inner error message."
	| err message |
	err := anEntry result error.
	message := err ifNil: [ '<no error payload>' ] ifNotNil: [ err message ifNil: [ '<no message>' ] ].
	Transcript
		nextPutAll: anEntry customId;
		nextPutAll: ' ERROR: ';
		nextPutAll: message;
		cr
]

{ #category : 'private' }
ClaudeMessagingBatchesExample class >> logSucceeded: anEntry [
	"Log a succeeded batch entry to the Transcript. Truncates the message text
	 to a leading slice so a noisy generation never spams the Transcript."
	| msg text snippet |
	msg := anEntry result message.
	text := msg ifNil: [ '' ] ifNotNil: [ msg textContent ifNil: [ '' ] ].
	snippet := text size > 60
		ifTrue: [ (text first: 60) , '...' ]
		ifFalse: [ text ].
	Transcript
		nextPutAll: anEntry customId;
		nextPutAll: ' OK: ';
		nextPutAll: snippet;
		cr
]

{ #category : 'examples' }
ClaudeMessagingBatchesExample class >> run [
	"Run the example using a client resolved from the keyring or env. Returns the
	 OrderedCollection of ClaudeBatchResults from the live API."
	^ self runOn: ClaudeSDKExampleSupport resolveClient
]

{ #category : 'running' }
ClaudeMessagingBatchesExample class >> runOn: aClaudeClient [
	"Drive the full Batches lifecycle against the given client:
	   1. Submit the sample batch via createBatch:
	   2. Poll every 2 seconds via pollBatch:untilEndedEvery: until the batch ends
	   3. Stream the JSONL results via streamBatchResults:do:
	      and dispatch each entry polymorphically on its outcome (no `type =` chains).

	 Returns the OrderedCollection of every ClaudeBatchResult yielded by the stream
	 in submission order, so callers can assert on the full set after the run.

	 Logs every entry to the Transcript so a developer running the example by hand
	 sees progress without an attached debugger."
	| created |
	created := aClaudeClient createBatch: self buildSampleCreateParams.
	Transcript
		nextPutAll: 'Created batch ';
		nextPutAll: created id;
		nextPutAll: ' (';
		nextPutAll: created processingStatus;
		nextPutAll: ')';
		cr.
	aClaudeClient pollBatch: created id untilEndedEvery: 2.
	Transcript
		nextPutAll: 'Batch ';
		nextPutAll: created id;
		nextPutAll: ' ended; streaming results...';
		cr.
	^ aClaudeClient
		streamBatchResults: created id
		do: [ :entry |
			entry isSucceeded ifTrue: [ self logSucceeded: entry ].
			entry isErrored ifTrue: [ self logErrored: entry ].
			(entry isCanceled or: [ entry isExpired ])
				ifTrue: [ self logCanceledOrExpired: entry ] ]
]
