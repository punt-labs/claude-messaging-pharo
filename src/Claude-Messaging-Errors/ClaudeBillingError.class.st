"
Signaled when the API returns HTTP 402 — billing issue with the account.

### Examples

```
(ClaudeApiError fromStatusCode: 402 json: '{}' requestId: 'r1') class
>>> ClaudeBillingError
```

"
Class {
	#name : 'ClaudeBillingError',
	#superclass : 'ClaudeApiError',
	#category : 'Claude-Messaging-Errors',
	#package : 'Claude-Messaging-Errors'
}
