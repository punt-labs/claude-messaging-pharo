# Source — Tonel Format

This directory contains Smalltalk source in Tonel format. Each
subdirectory is a package, each `.class.st` file is a class.

## Editing Rules

- **Do not edit `.class.st` files with `sed` or `awk`.** Use the
  Pharo System Browser or Iceberg. Tonel has structure that text
  tools can break.
- **Do not create chunk-format `.st` files here.** All new code
  goes in Tonel packages.
- **Class definition changes** (adding instance variables,
  changing superclass) must be done in the System Browser, then
  committed via Iceberg.
- **Method changes** can be done in the System Browser or by
  editing the `.class.st` file directly — but always reload via
  Iceberg afterward.

## Package Layers

This repo ships one layer: the Messaging SDK. `PharoKeyring` is
standalone. The eval server (Postern) lives in the separate
`../postern/` repo and is loaded as a Metacello dependency, not as
a Tonel package in this tree.

For the canonical, per-package class inventory and dependency
contract, see the root `CLAUDE.md` Packages section and
`BaselineOfClaudeMessaging`. The summary below names the packages
and their purpose; the root file owns the detail.

### Layer — Claude Messaging SDK (API client)

| Package | Purpose |
|---------|---------|
| `Claude-Messaging-Types` | Domain hierarchy: messages, content blocks, tools, models, request/response types, container, citations, cache control, thinking, beta-header catalog |
| `Claude-Messaging-Errors` | `ClaudeApiError` hierarchy keyed on HTTP status |
| `Claude-Messaging-Streaming` | SSE decoder + raw streaming socket |
| `Claude-Messaging-Client` | `ClaudeClient` — Messages API, models API, token counting, files, MCP, skills, retry |
| `Claude-Messaging-Tools` | Server-side tool definitions (Anthropic-side execution) |
| `Claude-Messaging-Files` | Files API — upload, download, list, delete |
| `Claude-Messaging-MCP` | MCP connector — request-side server definition + tool config (response content blocks live in `Claude-Messaging-Types`) |
| `Claude-Messaging-Skills` | Skills API — upload reusable tool packages |
| `Claude-Messaging-Examples` | Runnable usage examples for the messaging surface |

### Baseline

| Package | Purpose |
|---------|---------|
| `BaselineOfClaudeMessaging` | Metacello baseline that loads all packages in dependency order |

### Standalone

| Package | Purpose |
|---------|---------|
| `PharoKeyring` | Cross-platform OS keyring wrapper |

## Smalltalk Idioms (Beck)

- **Composed method**: every method does one thing. If it's >10
  lines, decompose.
- **Intention revealing selector**: `sendMessage:` not
  `postToMessagesEndpoint:`.
- **Pluggable behavior**: use blocks for callbacks
  (`streamMessage:do:`).
- **Collecting parameter**: build results incrementally (message
  accumulator).
- **`jsonKeyMap`**: every type class implements this class-side
  method returning a Dictionary mapping camelCase instance
  variables to snake_case JSON keys.
- **Polymorphism over conditionals**: dispatch on type via
  subclass methods (`isTextBlock`, `applyDelta:`) instead of
  if/else on a type tag.
- **Examples in class comments**: every class comment includes
  runnable `>>>` doctest examples per Pharo's Doctests convention.
