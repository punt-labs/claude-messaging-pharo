# Messaging Specification — Gap Analysis (Phase 2 Input)

## Purpose

This document enumerates every section in Anthropic's published Messages
API documentation and records the Pharo SDK's current coverage against
it. It is the input artifact for **Phase 2** of the docs-alignment work
(bead `p4iz`): Phase 2 fills the gaps identified here by expanding the
restructured spec's `Gap (Phase 2): ...` stubs into full sections.

Reference: the Anthropic TOC this is scored against lives at
`docs/research/anthropic-messaging-api-docs-toc.md`. The Pharo spec it
maps to is `docs/specifications/claude-sdk-specification.tex`.

## How to Read this Table

- **Anthropic Section** — a page or page-group in Anthropic's docs.
- **URL** — the canonical doc URL.
- **Our Status** — one of four values:
  - `Have` — the Pharo spec covers the section with equivalent depth to
    Anthropic's docs.
  - `Partial-doc` — the SDK code already implements the feature; the
    gap is pure prose work (worked examples, monitoring headers,
    beta-header detail, handler patterns). Phase 2 writes prose; no new
    classes or methods are required.
  - `Partial-code` — the SDK partially covers the surface but requires
    a new class, method, or slot to close the gap (e.g., a typed
    `ClaudeContextManagement`, a `serviceTier` slot on `ClaudeUsage`,
    a new `ClaudeSearchResultBlock` in the content-block registry).
    Phase 2 adds code before prose.
  - `Missing` — the Pharo spec has no coverage; the restructured spec
    carries a `Gap (Phase 2): ...` stub referencing Anthropic's page.
- **Phase 2 Priority** — one of:
  - **P0** — must-have for v1.0. Blocks a credible "feature parity with
    Anthropic's published surface" claim.
  - **P1** — should-have. Strengthens the spec but does not block v1.0.
  - **P2** — nice-to-have. Reference material, administrative surface,
    or doc-only guide prose with no Pharo implementation impact.
- **Scope Hint** — a one-line description of the work Phase 2 should
  do for this gap.

## Part I — API Reference

| Anthropic Section | URL | Our Status | Phase 2 Priority | Scope Hint |
|---|---|---|---|---|
| Messages API reference | <https://docs.claude.com/en/api/messages> | Have | — | Covered in §2 Messages API |
| Messages examples | <https://docs.claude.com/en/api/messages-examples> | Partial-doc | P1 | doc-only: add paired `>>>` examples for prefill, vision, tool use, JSON mode, computer use (SDK types already shipped) |
| Count Tokens | <https://docs.claude.com/en/api/messages-count-tokens> | Have | — | Covered in §4 Count Tokens |
| List Models | <https://docs.claude.com/en/api/models-list> | Have | — | Covered in §5 |
| Get a Model | <https://docs.claude.com/en/api/models> | Have | — | Covered in §6 |
| Handling stop reasons | <https://docs.claude.com/en/api/handling-stop-reasons> | Partial-doc | P1 | doc-only: add Smalltalk handler patterns per stop-reason value (retry on pause_turn, append tool results on tool_use, escalate on refusal) |
| Errors | <https://docs.claude.com/en/api/errors> | Have | — | Covered in §8 Errors |
| API versions | <https://docs.claude.com/en/api/versioning> | Have | — | Covered in §9 |
| Beta headers | <https://docs.claude.com/en/api/beta-headers> | Partial-code | P1 | requires new `ClaudeBetaHeader` class — typed catalog matching Anthropic's published list |
| Rate limits | <https://docs.claude.com/en/api/rate-limits> | Partial-doc | P1 | doc-only: add RPM/ITPM/OTPM bucket taxonomy, monitoring-header prose, priority-tier interactions (SDK already surfaces `ClaudeRateLimitError` and Agent-layer `ClaudeRateLimiter`) |
| Service tiers | <https://docs.claude.com/en/api/service-tiers> | Partial-code | P1 | requires new slot: add `serviceTier` to `ClaudeUsage` and typed accessors for priority-tier monitoring response headers |
| Client SDKs | <https://docs.claude.com/en/api/client-sdks> | Have | — | Covered in §13 (Pharo is the client SDK) |
| API Overview | <https://docs.claude.com/en/api/overview> | Have | — | Covered across §1 and §2 |
| Supported regions | <https://docs.claude.com/en/api/supported-regions> | Missing | P2 | Reference material only; link from §9 or §12 |
| IP addresses | <https://docs.claude.com/en/api/ip-addresses> | Missing | P2 | Reference material only; link from §1 |
| OpenAI SDK compatibility | <https://docs.claude.com/en/api/openai-sdk> | Missing | P2 | Not in v1 scope; note as out-of-scope |
| Migration guide (Text Completions → Messages) | <https://docs.claude.com/en/api/migrating-from-text-completions-to-messages> | Missing | P2 | Not in v1 scope; Pharo SDK never shipped Text Completions |
| Create Batch | <https://docs.claude.com/en/api/creating-message-batches> | Missing | P1 | Add `ClaudeBatchService` with create (up to 100k requests / 256 MB) |
| Retrieve Batch | <https://docs.claude.com/en/api/retrieving-message-batches> | Missing | P1 | Part of Batches endpoint group |
| Retrieve Batch Results | <https://docs.claude.com/en/api/retrieving-message-batch-results> | Missing | P1 | Stream `.jsonl` results from `results_url` |
| List Batches | <https://docs.claude.com/en/api/listing-message-batches> | Missing | P1 | `before_id`/`after_id` pagination |
| Cancel Batch | <https://docs.claude.com/en/api/canceling-message-batches> | Missing | P1 | Part of Batches endpoint group |
| Delete Batch | <https://docs.claude.com/en/api/deleting-message-batches> | Missing | P1 | Part of Batches endpoint group |
| Batches examples | <https://docs.claude.com/en/api/messages-batch-examples> | Missing | P1 | Paired examples once Batches API lands |
| Create a File | <https://docs.claude.com/en/api/files-create> | Have | — | Covered in §15 Files API |
| List Files | <https://docs.claude.com/en/api/files-list> | Have | — | Covered in §15 |
| Get File Metadata | <https://docs.claude.com/en/api/files-metadata> | Have | — | Covered in §15 |
| Download a File | <https://docs.claude.com/en/api/files-content> | Have | — | Covered in §15 |
| Delete a File | <https://docs.claude.com/en/api/files-delete> | Have | — | Covered in §15 |
| Using Agent Skills with the API | <https://docs.claude.com/en/api/skills-guide> | Have | — | Covered in §16 Skills API |
| Generate a prompt | <https://docs.claude.com/en/api/prompt-tools-generate> | Missing | P2 | Experimental endpoint; defer until GA |
| Templatize a prompt | <https://docs.claude.com/en/api/prompt-tools-templatize> | Missing | P2 | Experimental endpoint; defer until GA |
| Improve a prompt | <https://docs.claude.com/en/api/prompt-tools-improve> | Missing | P2 | Experimental endpoint; defer until GA |
| Admin API overview | <https://docs.claude.com/en/api/administration-api> | Missing | P2 | Requires Admin API key; separate operator surface |
| Add Workspace Member | <https://docs.claude.com/en/api/admin-api/workspace_members/create-workspace-member> | Missing | P2 | Admin API subset |
| Get API Key | <https://docs.claude.com/en/api/admin-api/apikeys/get-api-key> | Missing | P2 | Admin API subset |
| Usage and Cost API | <https://docs.claude.com/en/api/usage-cost-api> | Missing | P2 | Admin API subset; billing reporting |
| Claude Code Analytics API | <https://docs.claude.com/en/api/claude-code-analytics-api> | Missing | P2 | Adjacent product; not Messaging SDK |

## Part II — Build with Claude (feature guides)

| Anthropic Section | URL | Our Status | Phase 2 Priority | Scope Hint |
|---|---|---|---|---|
| Features overview | <https://docs.claude.com/en/docs/build-with-claude/overview> | Missing | P2 | Index page only; no Pharo-side content |
| Using the Messages API | <https://docs.claude.com/en/docs/build-with-claude/working-with-messages> | Partial-doc | P1 | doc-only: overlaps with §2; add common-patterns subsection |
| Streaming Messages | <https://docs.claude.com/en/docs/build-with-claude/streaming> | Have | — | Covered in §19 Streaming Messages |
| Prompt caching | <https://docs.claude.com/en/docs/build-with-claude/prompt-caching> | Have | — | Covered in §20 |
| Extended thinking | <https://docs.claude.com/en/docs/build-with-claude/extended-thinking> | Partial-doc | P1 | doc-only: add interleaved-thinking beta and signature-verification workflow (`ClaudeThinkingParams` already shipped) |
| Context editing | <https://docs.claude.com/en/docs/build-with-claude/context-editing> | Partial-code | P0 | requires new `ClaudeContextManagement` class and `ClaudeRequestOptions >> contextManagement:` slot; enumerate strategies (`clear_tool_uses_20250919`, `clear_thinking_20251015`) |
| Context windows | <https://docs.claude.com/en/docs/build-with-claude/context-windows> | Missing | P1 | 200K / 500K / 1M context tables; premium pricing above 200K |
| Token counting | <https://docs.claude.com/en/docs/build-with-claude/token-counting> | Partial-doc | P1 | doc-only: add context-window sizing tables and per-model cost worksheets (`countTokens:` already shipped) |
| Vision | <https://docs.claude.com/en/docs/build-with-claude/vision> | Partial-doc | P0 | doc-only: expand §23 with supported formats, size / dimension limits, multi-image patterns, cost per image (`ClaudeImageBlock` already shipped) |
| PDF support | <https://docs.claude.com/en/docs/build-with-claude/pdf-support> | Partial-doc | P1 | doc-only: add page-count limits, total-document-size caps, PDF + citations integration (`ClaudeDocumentBlock` already shipped) |
| Citations | <https://docs.claude.com/en/docs/build-with-claude/citations> | Partial-doc | P0 | doc-only: document chunking strategies, `cited_text` field, multi-document RAG example (`ClaudeCitation` already shipped) |
| Search results | <https://docs.claude.com/en/docs/build-with-claude/search-results> | Partial-code | P1 | requires new `ClaudeSearchResultBlock` class and `search_result` TypeRegistry entry — distinct from `ClaudeWebSearchResultBlock` (which is the web_search server-tool result) |
| Structured outputs | <https://docs.claude.com/en/docs/build-with-claude/structured-outputs> | Have | — | Covered in §26 Structured Outputs via `ClaudeOutputConfig` + `ClaudeJsonSchemaOutputFormat` + `structured-outputs-2025-11-13` beta |
| Files API guide | <https://docs.claude.com/en/docs/build-with-claude/files> | Partial-doc | P1 | doc-only: prose companion to §15 Files API |
| Batch processing | <https://docs.claude.com/en/docs/build-with-claude/batch-processing> | Missing | P1 | Paired with Batches API (§14); when-to-use guidance |

## Part III — Agents and Tools

| Anthropic Section | URL | Our Status | Phase 2 Priority | Scope Hint |
|---|---|---|---|---|
| Tool use with Claude (overview) | <https://docs.claude.com/en/docs/agents-and-tools/tool-use/overview> | Have | — | Covered in §30 Tool Use |
| How to implement tool use | <https://docs.claude.com/en/docs/agents-and-tools/tool-use/implement-tool-use> | Partial-doc | P1 | doc-only: document `tool_choice` modes end-to-end, `disable_parallel_tool_use` (`ClaudeToolParams` already shipped) |
| Fine-grained tool streaming | <https://docs.claude.com/en/docs/agents-and-tools/tool-use/fine-grained-tool-streaming> | Missing | P1 | Unbuffered tool-parameter streaming; GA |
| Token-efficient tool use | <https://docs.claude.com/en/docs/agents-and-tools/tool-use/token-efficient-tool-use> | Missing | P2 | `token-efficient-tools-2025-02-19` beta; 3.7-only, default on 4+ |
| Web search tool | <https://docs.claude.com/en/docs/agents-and-tools/tool-use/web-search-tool> | Have | — | Covered in §31 Server Tools |
| Web fetch tool | <https://docs.claude.com/en/docs/agents-and-tools/tool-use/web-fetch-tool> | Have | — | Covered in §31 |
| Code execution tool | <https://docs.claude.com/en/docs/agents-and-tools/tool-use/code-execution-tool> | Have | — | Covered in §31 |
| Bash tool | <https://docs.claude.com/en/docs/agents-and-tools/tool-use/bash-tool> | Have | — | Covered in §31 |
| Text editor tool | <https://docs.claude.com/en/docs/agents-and-tools/tool-use/text-editor-tool> | Have | — | Covered in §31 |
| Computer use tool | <https://docs.claude.com/en/docs/agents-and-tools/tool-use/computer-use-tool> | Missing | P1 | `computer_20250124`; beta `computer-use-2025-01-24`; screenshot + mouse/keyboard |
| Memory tool | <https://docs.claude.com/en/docs/agents-and-tools/tool-use/> (sidebar) | Have | — | Covered in §31 as `ClaudeMemoryTool` |
| Advisor tool | <https://docs.claude.com/en/docs/agents-and-tools/tool-use/> (sidebar) | Missing | P2 | New sidebar entry; evaluate scope |
| Tool search tool | (referenced in release notes) | Have | — | Covered in §31 as `ClaudeToolSearchBm25Tool` / `ClaudeToolSearchRegexTool` |
| Programmatic tool calling | (referenced in release notes) | Missing | P1 | Tool calls issued from within code execution; GA |
| MCP connector | <https://docs.claude.com/en/docs/agents-and-tools/mcp-connector> | Have | — | Covered in §32 MCP Connector |
| Remote MCP servers | <https://docs.claude.com/en/docs/agents-and-tools/remote-mcp-servers> | Missing | P2 | Directory of pre-configured remote MCP servers (Square, Cloudinary, invideo, etc.); reference-only |
| What is MCP? | <https://docs.claude.com/en/docs/mcp> | Missing | P2 | Conceptual overview; reference-only |
| Agent Skills overview | <https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview> | Partial-doc | P1 | doc-only: API surface in §16 + §33 is complete; add pre-built skill catalog reference and authoring guidance |
| Skill authoring best practices | <https://docs.claude.com/en/docs/agents-and-tools/agent-skills/best-practices> | Missing | P1 | Author-focused; add in §33 |
| Get started with Agent Skills | <https://docs.claude.com/en/docs/agents-and-tools/agent-skills/quickstart> | Missing | P1 | Worked end-to-end example showing a Smalltalk-authored skill |

## Summary

- **P0 gaps** (3): Context Editing (requires `ClaudeContextManagement` class — `Partial-code`), Vision expansion (`Partial-doc`), Citations chunking + RAG example (`Partial-doc`). Structured Outputs moved to `Have` after the 2026-04-21 fact-check discovered `ClaudeOutputConfig` + `ClaudeJsonSchemaOutputFormat` had already shipped.
- **P1 gaps** (20): Messages examples pairings (`Partial-doc`), stop-reason handler patterns (`Partial-doc`), beta header catalog (`Partial-code` — new `ClaudeBetaHeader`), rate-limits taxonomy (`Partial-doc`), service-tier monitoring headers (`Partial-code` — new `ClaudeUsage serviceTier` slot + typed header accessors), full Batches endpoint group + examples (`Missing`), Using-the-Messages-API prose (`Partial-doc`), Extended-thinking interleaved/signature (`Partial-doc`), context windows (`Missing`), token-counting feature-guide prose (`Partial-doc`), PDF expansion (`Partial-doc`), Search Results wire shape (`Partial-code` — new `ClaudeSearchResultBlock`), Files API prose (`Partial-doc`), Batch processing prose (`Missing`), `tool_choice` full coverage (`Partial-doc`), fine-grained tool streaming (`Missing`), Computer use tool (`Missing`), programmatic tool calling (`Missing`), Agent Skills pre-built catalog (`Partial-doc`), Skills authoring best practices + quickstart (`Missing`).
- **P2 gaps** (15): Supported regions, IP addresses, OpenAI SDK compat, Text Completions migration, Prompt Tools API (3 endpoints), Admin API overview + members + API-key + Usage-and-Cost + Claude Code Analytics, Build-with-Claude features overview, token-efficient tool use, Advisor tool, Remote MCP servers directory, What is MCP conceptual overview.

### Partial-doc vs Partial-code split

- **Partial-doc** rows (14): Messages examples, stop-reason handler
  patterns, rate limits, Using the Messages API, Extended thinking,
  Token counting, Vision, PDF support, Citations, Files API guide,
  How to implement tool use, Agent Skills overview. Phase 2 is pure
  prose work on these sections — the SDK types already exist.
- **Partial-code** rows (4): Beta headers, Service tiers, Context
  editing, Search results. Phase 2 needs a new class, slot, or
  TypeRegistry entry before prose work can begin.
