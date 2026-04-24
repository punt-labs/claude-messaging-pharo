# Claude Messaging SDK for Pharo

A Smalltalk client for [Anthropic's Claude Messages API](https://docs.anthropic.com/en/api/messages).
Send messages, stream responses, use tools, upload files, and access the
full Claude API surface — all from a live Pharo 12 image.

## Install

Load via Metacello:

```smalltalk
Metacello new
  baseline: 'ClaudeMessaging';
  repository: 'github://punt-labs/anthropic-sdk-pharo:v1.0.0/src';
  load.
```

Requires Pharo 12 (x86\_64 or arm64). No external dependencies beyond
Pharo's built-in Zinc HTTP and STONJSON.

## Quick start

```smalltalk
| client response |
client := ClaudeClient apiKey: 'sk-ant-api03-...'.
response := client sendMessage: (ClaudeMessageRequest new
  model: ClaudeModel sonnet45;
  maxTokens: 1024;
  addUserMessage: 'Write a haiku about Smalltalk.';
  yourself).
Transcript show: response textContent; cr.
```

For scripts and examples, use `ClaudeSDKExampleSupport resolveClient` — it
reads from the OS keyring, then the `ANTHROPIC_API_KEY` environment variable,
then prompts. Never hard-code a key.

## Streaming

```smalltalk
| client request |
client := ClaudeSDKExampleSupport resolveClient.
request := ClaudeMessageRequest new
  model: ClaudeModel sonnet45;
  maxTokens: 512;
  addUserMessage: 'Count to five.';
  yourself.
client streamMessage: request do: [ :event |
  (event at: 'event') = 'content_block_delta' ifTrue: [
    Transcript show: ((event at: 'data') at: 'delta') at: 'text' ] ].
```

## Tool use

```smalltalk
| request |
request := ClaudeMessageRequest new
  model: ClaudeModel sonnet45;
  maxTokens: 1024;
  addTool: (ClaudeTool
    name: 'get_weather'
    description: 'Get current weather for a city.'
    inputSchema: (ClaudeToolInputSchema object
      required: #('city')
      properties: { 'city' -> (ClaudeToolInputSchema string description: 'City name') }));
  addUserMessage: 'What is the weather in Paris?';
  yourself.
```

## Server tools (Anthropic-hosted)

```smalltalk
"Enable web search and bash (Anthropic runs these — no local execution)"
request addWebSearch; addBash.
```

## Files API

```smalltalk
| client meta |
client := ClaudeSDKExampleSupport resolveClient.
meta := client uploadFile: '/path/to/report.pdf' filename: 'report.pdf' mimeType: 'application/pdf'.
Transcript show: 'File ID: ', meta fileId; cr.
```

## MCP connector

```smalltalk
request mcpServers: {
  ClaudeMCPServerDefinition name: 'my-server' url: 'https://mcp.example.com/sse' }.
request betas: { ClaudeBetaHeader mcpClient }.
```

## Packages

| Package | Contents |
|---|---|
| `Claude-Messaging-Types` | Domain hierarchy: messages, content blocks, tools, models |
| `Claude-Messaging-Errors` | `ClaudeApiError` hierarchy keyed on HTTP status |
| `Claude-Messaging-Streaming` | SSE decoder + raw TLS socket streaming |
| `Claude-Messaging-Client` | `ClaudeClient` — entry point for all API calls |
| `Claude-Messaging-Tools` | Server-side tool definitions (Anthropic-side execution) |
| `Claude-Messaging-Files` | Files API — upload, download, list, delete |
| `Claude-Messaging-MCP` | MCP connector — request-side server definitions |
| `Claude-Messaging-Skills` | Skills API — upload reusable tool packages |
| `Claude-Messaging-Examples` | Runnable usage examples |
| `PharoKeyring` | Cross-platform OS keyring for API key storage |

## Development

```bash
git clone git@github.com:punt-labs/anthropic-sdk-pharo.git claude-messaging-pharo
cd claude-messaging-pharo
make setup   # download Pharo 12 + load packages
make start   # start eval server on port 8422
make test    # run test suite
make lint    # zero findings required
```

See [CONTRIBUTING.md](CONTRIBUTING.md) and [CLAUDE.md](CLAUDE.md).

## Specification

Full API specification: [messaging-specification.pdf](docs/specifications/messaging-specification.pdf)
(also available as a GitHub Release asset).

## License

MIT. See [LICENSE](LICENSE).
