"
Signaled when the API returns HTTP 500 or any unrecognized 5xx status — internal server error.

### Examples

```
(ClaudeApiError fromStatusCode: 500 json: '{}' requestId: 'r1') class
>>> ClaudeServerError
```

"
Class {
	#name : 'ClaudeServerError',
	#superclass : 'ClaudeApiError',
	#category : 'Claude-Messaging-Errors',
	#package : 'Claude-Messaging-Errors'
}
