"
Demonstrate URL-source image input. Builds a ClaudeMessageRequest
whose user turn carries a ClaudeImageBlock with a URL-source pointing
at a stable public PNG, plus a ClaudeTextBlock asking the model to
describe the image. The response carries assistant text and a usage
record whose inputTokens count reflects the processed image.

URL-source image blocks are natively supported by the Messages API.
No beta header is required. The server fetches the image from the URL,
feeds it into the model, and charges inputTokens against both the text
and the image. For this prompt shape, a text-only equivalent is
~50-80 tokens; a processed image typically adds hundreds more,
exceeding the >200 assertion threshold by a wide margin. The delta is
the server-computed proof that the image reached the model's context.
(Hard numbers live in the test-artifact result log, not in docstrings,
so comments don't drift when token pricing or compression changes.)

**URL choice.** The default is a Wikimedia Commons PNG (""PNG
transparency demonstration"", the well-known translucent-dice image,
stable since 2008). Wikimedia Commons canonical URLs (the non-thumb
endpoint) are served without thumbnail-renderer rate limits. The
thumbnail endpoint is rate-limited against automated fetchers —
Anthropic's server-side fetcher receives HTTP 429 on the thumb URL
but 200 on the canonical URL. We use the canonical URL. See
`exampleImageUrl` for specifics.

**Prompt design.** The question asks for a single-sentence description
so the response is cheap and the stopReason is predictable (#end_turn
rather than #max_tokens). The content of the description is irrelevant
to the integration test: the test proves the server received and
processed the image, not that it described it correctly.

  ClaudeMessagingImageExample buildRequest model
  >>> 'claude-sonnet-4-6'

  ClaudeMessagingImageExample buildRequest maxTokens
  >>> 512

  ClaudeMessagingImageExample buildRequest messages first content first type
  >>> 'image'

  ClaudeMessagingImageExample buildRequest messages first content size
  >>> 2

"
Class {
	#name : 'ClaudeMessagingImageExample',
	#superclass : 'Object',
	#category : 'Claude-Messaging-Examples',
	#package : 'Claude-Messaging-Examples'
}

{ #category : 'building' }
ClaudeMessagingImageExample class >> buildRequest [
	"Build a ClaudeMessageRequest carrying a URL-source image block and a
	 one-line text prompt asking the model to describe the image. The server
	 fetches the image from the URL, feeds it into the model, and returns a
	 response whose inputTokens count proves the image was processed."

	| req imageBlock textBlock |
	req := ClaudeMessageRequest new.
	req model: ClaudeModel sonnet46.
	req maxTokens: 512.
	imageBlock := ClaudeImageBlock fromUrl: self exampleImageUrl.
	textBlock := ClaudeTextBlock
		text: 'Describe this image in one sentence.'.
	req addUserContent: { imageBlock. textBlock }.
	^ req
]

{ #category : 'building' }
ClaudeMessagingImageExample class >> exampleImageUrl [
	"Return the default image URL used by this example. Wikimedia Commons
	 hosts the 'PNG transparency demonstration' image (full-size
	 ~224 KB, recognizable translucent-dice scene, stable since 2008).
	 URL-source images are natively supported by the Messages API with
	 no beta header required. The server fetches the image and the model
	 downsamples it as needed.

	 NOTE: The thumbnail endpoint (upload.wikimedia.org/.../thumb/...) is
	 rate-limited against automated fetchers (observed HTTP 429 from
	 Anthropic's fetcher). The canonical (non-thumb) URL used here is
	 served directly without thumbnail-renderer rate limits.

	 If the URL breaks, that is a follow-up bead to update the URL, not
	 a test bug."
	^ 'https://upload.wikimedia.org/wikipedia/commons/4/47/PNG_transparency_demonstration_1.png'
]

{ #category : 'private' }
ClaudeMessagingImageExample class >> resolveClient [
	^ ClaudeSDKExampleSupport resolveClient
]

{ #category : 'examples' }
ClaudeMessagingImageExample class >> run [
	"Send the example image-input request and return the response."
	^ self runOn: self resolveClient
]

{ #category : 'examples' }
ClaudeMessagingImageExample class >> runOn: aClient [
	"Send the image-input request using the given client and return the
	 response. The response inputTokens will reflect the processed image:
	 a text-only equivalent of this prompt shape is ~50-80 tokens; a
	 processed image typically adds hundreds more, well above the >200
	 assertion threshold."
	^ aClient sendMessage: self buildRequest
]
