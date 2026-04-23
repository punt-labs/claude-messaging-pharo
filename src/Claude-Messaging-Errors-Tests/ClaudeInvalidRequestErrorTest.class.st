"
Tests for ClaudeInvalidRequestError (HTTP 400) — status code, registry wiring, and retryability.
"
Class {
	#name : 'ClaudeInvalidRequestErrorTest',
	#superclass : 'TestCase',
	#category : 'Claude-Messaging-Errors-Tests',
	#package : 'Claude-Messaging-Errors-Tests'
}

{ #category : 'testing' }
ClaudeInvalidRequestErrorTest >> testErrorTypeRegistry [
	"Test that invalid_request_error maps to ClaudeInvalidRequestError"
	| registry |
	registry := ClaudeApiError errorTypeRegistry.
	self assert: (registry at: 'invalid_request_error') equals: ClaudeInvalidRequestError
]

{ #category : 'testing' }
ClaudeInvalidRequestErrorTest >> testStatusCode [
	"Test that ClaudeInvalidRequestError returns status code 400"
	| error |
	error := ClaudeInvalidRequestError new.
	self assert: error statusCode equals: 400
]

{ #category : 'testing' }
ClaudeInvalidRequestErrorTest >> testStatusRegistry [
	"Test that status code 400 maps to ClaudeInvalidRequestError"
	| registry |
	registry := ClaudeApiError statusRegistry.
	self assert: (registry at: 400) equals: ClaudeInvalidRequestError
]
