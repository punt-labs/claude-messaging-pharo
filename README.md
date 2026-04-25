# Claude SDK for Pharo

[![License](https://img.shields.io/github/license/punt-labs/anthropic-sdk-pharo)](LICENSE)
[![Lint](https://img.shields.io/github/actions/workflow/status/punt-labs/anthropic-sdk-pharo/lint.yml?label=Lint)](https://github.com/punt-labs/anthropic-sdk-pharo/actions/workflows/lint.yml)
[![Test](https://img.shields.io/github/actions/workflow/status/punt-labs/anthropic-sdk-pharo/test.yml?label=Test)](https://github.com/punt-labs/anthropic-sdk-pharo/actions/workflows/test.yml)
[![Integration](https://img.shields.io/github/actions/workflow/status/punt-labs/anthropic-sdk-pharo/slow-suite.yml?label=Integration)](https://github.com/punt-labs/anthropic-sdk-pharo/actions/workflows/slow-suite.yml)
[![Docs](https://img.shields.io/github/actions/workflow/status/punt-labs/anthropic-sdk-pharo/docs.yml?label=Docs)](https://github.com/punt-labs/anthropic-sdk-pharo/actions/workflows/docs.yml)
[![Pharo 12](https://img.shields.io/badge/Pharo-12-%23aac9ff.svg)](https://pharo.org/download)

The Claude SDK for Pharo provides access to the [Claude API](https://docs.anthropic.com/en/api/) from Pharo applications.
Send messages, stream responses, use tools, upload files, and access the
full Claude API surface — all from a live Pharo 12 image.

## Install

Load via Metacello:

```smalltalk
Metacello new
  baseline: 'ClaudeMessaging';
  repository: 'github://punt-labs/anthropic-sdk-pharo:v0.5.0/src';
  load.
```

Requires Pharo 12 (x86\_64 or arm64). No external dependencies beyond
Pharo's built-in Zinc HTTP and STONJSON.

## Getting started

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

Full API specification: [claude-sdk-specification.pdf](docs/specifications/claude-sdk-specification.pdf)
(also available as a GitHub Release asset).

## Roadmap

Version increments and planned API surface: see [ROADMAP.md](docs/ROADMAP.md).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
