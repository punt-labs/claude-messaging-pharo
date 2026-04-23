"
Demonstrate citations on user-supplied documents. Builds a
ClaudeMessageRequest whose user turn carries a ClaudeDocumentBlock
with `citations: { #enabled -> true } asDictionary` and a
ClaudeTextBlock asking a question that can only be answered from
the document. The response carries ClaudeTextBlock instances whose
`citations` collection references spans of the document by index
and character range.

Citations are uniquely well-suited to live integration tests because
every citation field is server-computed from the raw document we
sent. The client cannot fabricate `citedText`, `documentIndex`,
`startCharIndex`, or `endCharIndex`: the server extracts the cited
excerpt and records the character offsets in our input.

**Wire format.** A citation-enabled user turn carries two content
blocks: a `document`-type block with a text source, a title, and
`citations: {enabled: true}`, and a `text`-type block with the
question. Only documents with `citations.enabled = true` are eligible
for citation; asking about a plain text block produces no citations
even when the answer is quoted verbatim.

**Prompt design.** The question asks about a specific quoted claim
from the document so the model has a clear target to cite. An open-
ended prompt (e.g., ''what does the document say?'') often yields a
summary without explicit citations because the model has no anchor
phrase to reference.

  ClaudeMessagingCitationsExample buildRequest model
  >>> 'claude-sonnet-4-6'

  ClaudeMessagingCitationsExample buildRequest maxTokens
  >>> 1024

  ClaudeMessagingCitationsExample buildRequest messages first content first type
  >>> 'document'

  ClaudeMessagingCitationsExample buildRequest messages first content size
  >>> 2

"
Class {
	#name : 'ClaudeMessagingCitationsExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'building' }
ClaudeMessagingCitationsExample class >> buildRequest [
	"Build a ClaudeMessageRequest that attaches a citations-enabled
	 text document to the user turn and asks a question anchored on a
	 specific quoted claim. The response carries ClaudeTextBlock
	 instances whose `citations` collection references spans of the
	 document by index and character range."
	| req documentBlock textBlock |
	req := ClaudeMessageRequest new.
	req model: ClaudeModel sonnet46.
	req maxTokens: 1024.
	documentBlock := ClaudeDocumentBlock fromText: self researchDocumentText.
	documentBlock title: 'Research Memo on Pharo Image Discipline'.
	documentBlock citations: { #enabled -> true } asDictionary.
	textBlock := ClaudeTextBlock
		text: 'According to the document, what is the preferred recovery path when a saved image restores with stale socket state? Quote the document.'.
	req addUserContent: { documentBlock. textBlock }.
	^ req
]

{ #category : 'building' }
ClaudeMessagingCitationsExample class >> researchDocumentText [
	"Deterministic research-memo text long enough to give the model
	 concrete claims to cite and short enough to stay well below
	 Anthropic's token limit for a single document. Contains one
	 explicit, unambiguous claim about image-restore recovery so the
	 citation test has a clear anchor to reach for."
	^ 'Pharo Image Discipline (Internal Memo)

The Pharo image is a snapshot of the live object graph including
compiled code, open windows, and open network sockets. Saving an
image captures the state of every running process and every
connected socket at the instant of the save.

Restoring a saved image re-materializes all of those processes and
sockets. Sockets that were connected at save time are not
reconnected on restore; they arrive as half-open descriptors that
error on first read or write. Processes that held those sockets
enter error states that cascade to the debugger.

The preferred recovery path is to rebuild the image from clean
Tonel source rather than attempt to repair a restored image. A full
rebuild discards the stale socket state entirely and reloads every
package from source, guaranteeing a consistent runtime from a known
starting point. Point fixes that patch individual sockets leave the
object graph in an unverified state and are not recommended.

Rebuild uses the project Makefile target `make rebuild`, which
downloads a clean Pharo 12 VM, boots a fresh image, and loads the
project packages in dependency order. The rebuild completes in under
two minutes on a typical laptop and is the standard recovery path
for any image that fails to start cleanly.'
]

{ #category : 'private' }
ClaudeMessagingCitationsExample class >> resolveClient [
	^ ClaudeSDKExampleSupport resolveClient
]

{ #category : 'examples' }
ClaudeMessagingCitationsExample class >> run [
	"Send the example citations-enabled request and return the response."
	^ self runOn: self resolveClient
]

{ #category : 'examples' }
ClaudeMessagingCitationsExample class >> runOn: aClient [
	"Send the citations-enabled request using the given client and return
	 the response. The response text blocks carry server-generated
	 citations referencing spans of the input document."
	^ aClient sendMessage: self buildRequest
]
