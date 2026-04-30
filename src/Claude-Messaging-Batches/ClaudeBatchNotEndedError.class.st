"
Raised when `ClaudeClient >> streamBatchResults:do:` is called on a batch whose `processingStatus` has not yet reached `'ended'` — the batch object's `resultsUrl` is still nil, so there is nothing to fetch.

### When you see it

Always a client-side guard, never an HTTP error. Subclass of `ClaudeApiError` so callers who catch the base class catch this too.

### Recovery

Poll first via `getBatch:` until `isEnded`, or use the convenience helper `pollBatch:untilEndedEvery:`, then call `streamBatchResults:do:`.

```
| client |
client := ClaudeClient apiKey: 'sk-ant-...'.
client pollBatch: 'batch-abc' untilEndedEvery: 5.
client streamBatchResults: 'batch-abc' do: [ :entry | ... ].
```

### Example

```
[ ClaudeBatchNotEndedError signal ] on: ClaudeApiError do: [ :e | e class name ]
>>> #ClaudeBatchNotEndedError
```

### See also

`ClaudeApiError` — base class. `ClaudeClient >> streamBatchResults:do:` — the only call that raises this. `ClaudeClient >> pollBatch:untilEndedEvery:` — the helper that prevents it.
"
Class {
	#name : 'ClaudeBatchNotEndedError',
	#superclass : 'ClaudeApiError',
	#category : 'Claude-Messaging-Batches',
	#package : 'Claude-Messaging-Batches'
}

{ #category : 'instance creation' }
ClaudeBatchNotEndedError class >> signal [
	"Raise this error with a fixed default message describing the cause —
	 streamBatchResults:do: was called before the batch reached
	 processingStatus = 'ended'. Subclass uses the inherited statusCode/message
	 slots so callers catching ClaudeApiError see a meaningful printOn:."
	(self new
		statusCode: 0;
		message: 'Batch is not ended yet — resultsUrl is nil. Poll getBatch: until processingStatus = ''ended'' before requesting results.';
		yourself) signal
]
