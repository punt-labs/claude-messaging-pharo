# Changelog

All notable changes to the Claude SDK for Pharo are documented
here. The format follows
[Keep a Changelog](https://keepachangelog.com/) and the project adheres
to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added

- **Typed beta-header catalog** (`ClaudeBetaHeader`). Replaces raw string
  beta-header manipulation with a typed enumeration covering MCP client,
  prompt tools, skills, and other beta features.
- **Skills API** — upload, list, retrieve, and delete reusable tool
  packages via `ClaudeClient`. Types in `Claude-Messaging-Skills`:
  `ClaudeSkill`, `ClaudeSkillVersion`, `ClaudeDeletedSkill`,
  `ClaudeDeletedSkillVersion`, `ClaudeSkillPage`,
  `ClaudeSkillVersionPage`, `ClaudeSkillListParams`,
  `ClaudeSkillVersionListParams`.
- **MCP connector** — request-side MCP server definitions and tool
  configurations in `Claude-Messaging-MCP`
  (`ClaudeMCPServerDefinition`, `ClaudeMCPToolConfiguration`). Response
  content blocks (`ClaudeMCPToolUseBlock`,
  `ClaudeMCPToolResultBlock`) live in `Claude-Messaging-Types`.
- **Files API** — upload, list, download, delete in
  `Claude-Messaging-Files` (`ClaudeFileMetadata`, `ClaudeFilePage`,
  `ClaudeDeletedFile`, `ClaudeFileListParams`).
- **ClaudeImageBlock URL-casing alias** — accept both `url:` and `URL:`
  selectors; byte-size validation on inline image attachment.
- **ClaudeDocumentBlock URL-casing alias** — accept both `url:` and
  `URL:`; `tokensPerPageRange` accessor for page-budgeting.
- **Typed citations toggle** on `ClaudeDocumentBlock`.
  `enableCitations`/`disableCitations` control the `citations` slot;
  `disableCitations` clears it entirely (ADR-39).
- **Live-integration CI workflow** (`.github/workflows/slow-suite.yml`).
  Label-gated nightly run of the full Messaging suite against the real
  Anthropic API.
- **ClaudeAbstractTestSuite + ClaudeMessagingTestSuite** — per-product
  test suite factory (ADR-36). `ClaudeAbstractTestSuite` holds the
  shared filter machinery; `ClaudeMessagingTestSuite` aggregates the 9
  Messaging test packages plus `PharoKeyring-Tests`. `make test` runs
  the Messaging suite only.

### Changed

- **Uniform `ClaudeMessage`** — every message is an instance of
  `ClaudeMessage`, never a raw `Dictionary`. Content blocks are typed
  (`ClaudeContentBlock` hierarchy), not dictionary payloads (ADR-32).
- **`ClaudeMessageParams` renamed to `ClaudeMessageRequest`** —
  consistent with the Messages API wire name and the Go SDK's
  `MessageRequest` type (ADR-33).
- **`ClaudeImageBlock fromForm:`** — a live Pharo `Form` can be attached
  directly as an image block; the SDK serializes it as a base64 PNG
  (ADR-34).
- **Retry budget bumped on `ClaudeClient`**; `Retry-After` clamping so
  server-suggested delays cannot exceed the configured cap.

### Fixed

- **`NetworkError` escaping `executeWithRetry:`** — TCP-level failures
  during a request body read now raise `ClaudeApiError` subclasses
  like HTTP-level failures, so a single retry path handles both.
- **Skills upload wire format** — corrected multipart boundary
  assembly for skill package uploads.
- **`ClaudeMessage>>textContent` and `toolUseBlocks` nil-guard** —
  returns empty string / empty collection for messages with no content
  blocks, instead of raising `DoesNotUnderstand`.
- **`ClaudeApiError fromSseErrorData:`** — correctly dispatches SSE
  error events to the right `ClaudeApiError` subclass based on
  `error.type`.
- **`isRetryable` nil-guard** on `ClaudeApiError` — treats absent
  `error.type` as non-retryable rather than raising.

### Documentation

- SDK specification (`docs/specifications/claude-sdk-specification.tex`)
  tracks the Skills API, MCP connector, files API, beta-header
  catalog, and streaming semantics.
- Pharo implementation notes
  (`docs/specifications/claude-sdk-specification-pharo-notes.tex`)
  cover LF/CR normalization, STONJSON conventions, and the Metacello
  baseline.
- Cascade-yourself audit of the SDK specification
  (completeness review vs the live Go SDK).

### Project

- Initial extraction from `claude-agent-sdk-smalltalk@74b77d2`. This
  repo ships the Claude SDK for Pharo as a standalone product; the
  Agent SDK, Agent Workbench, and Pharo Agent Bridge remain in the
  `claude-agent-sdk-smalltalk` repo.
- Ethos mission adoption — all delegation via ethos mission
  contracts with typed write-sets, success criteria, budgets, and
  evaluators.
