# Roadmap

The Claude SDK for Pharo follows semantic versioning with deliberate
small increments. Each minor release (v0.X.0) ships a major piece of
Anthropic API surface. v1.0.0 marks feature parity with the official
[anthropic-sdk-python](https://github.com/anthropics/anthropic-sdk-python).

## Released

### v0.5.0 — current

Messages API plus Messages-adjacent resources. About half the surface
of `anthropic-sdk-python`.

- **Messages API**: `sendMessage:`, `streamMessage:do:`, `countTokens:`,
  multi-turn conversations, prompt caching, citations, extended
  thinking, interleaved thinking
- **Files API**: upload, list, get-metadata, download, delete
  (`files-api-2025-04-14` beta)
- **Skills API**: CRUD on reusable tool packages
  (`skills-2025-10-02` beta)
- **Server tools** (Anthropic-hosted): web search, bash, code
  execution, text editor, memory, computer use
- **MCP connectors** via the `mcp_servers` field on Messages requests
  (`mcp-client-2025-04-04` beta)
- **Typed model catalog**: opus47, opus46, opus45, sonnet46, sonnet45,
  haiku45, haiku35
- **Typed beta-header catalog** (`ClaudeBetaHeader`)
- **Typed response metadata** (rate-limit and service-tier)
- **Streaming**: SSE decoder plus raw TLS socket variants
- 770 unit tests, integration tests against the live Anthropic API

## Planned increments

Each minor release adds one major API surface. Order reflects
dependency: shared primitives before consumers.

### v0.6.0 — Batches API

Async Messages submission. Submit a batch of message requests, poll
for completion, retrieve results. Same request shape as Messages on a
different endpoint family.

### v0.7.0 — Sessions (beta)

Server-side stateful conversation primitive. Used standalone for
long-running chats and as a building block for Managed Agents.

### v0.8.0 — Memory Stores (beta)

Persistent memory resource. Standalone for retrieval-augmented
workflows; consumed by Managed Agents.

### v0.9.0 — Agents (beta)

Claude-Managed Agents — the agentic runtime hosted by Anthropic.
Composes sessions, memory stores, skills, and tools. Depends on v0.7
and v0.8 having shipped.

### v0.10.0 — Environments (beta)

Execution environments for Managed Agents: sandbox configuration,
container settings, network policy.

### v0.11.0 — User Profiles + Vaults (beta)

`user_profiles` (per-user identity for agents) and `vaults` (secret
storage). Smaller resources paired into one release.

## v1.0.0

Feature parity with `anthropic-sdk-python`. All beta resources above
shipped. Stability promise: no breaking changes within v1.x unless
Anthropic deprecates the underlying endpoint.

## Out-of-line work (no minor bump)

Patch releases (v0.X.Y) cover:

- Bug fixes
- Performance and throughput
- Pharo-native ergonomics (typed accessors, content-block hierarchy
  refinements)
- Documentation
- Test coverage
- CI tooling

Major non-API additions — for example, a Workbench split-off or
high-level agentic conveniences not in `anthropic-sdk-python` — are
considered for inclusion via separate ADRs.
