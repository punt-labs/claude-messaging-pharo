"
Signaled when the API returns HTTP 404 — unknown model or endpoint.

### Examples

```
(ClaudeApiError fromStatusCode: 404 json: '{}' requestId: 'r1') class
>>> ClaudeNotFoundError
```

"
Class {
	#name : 'ClaudeNotFoundError',
	#superclass : 'ClaudeApiError',
	#category : 'Claude-Messaging-Errors',
	#package : 'Claude-Messaging-Errors'
}
