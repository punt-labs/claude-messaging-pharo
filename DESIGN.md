# Design — Architecture Decision Records

This document records the architectural decisions for the Claude
Messaging SDK for Pharo. Each ADR captures a decision, the rejected
alternatives, and the consequences. ADRs in this repo cover only
Messaging-layer concerns; ADRs that applied to the Agent SDK or Agent
Workbench remain in the monorepo (`claude-agent-sdk-smalltalk`).

---

## ADR-1 — Eval server as primary development path

**Status:** SETTLED

**Decision:** All development happens inside a live Pharo 12 image via
the eval server. Classes are defined, methods are compiled, tests are
run, and lint is exercised through HTTP POSTs to
`http://localhost:${EVAL_PORT:-8422}/repl`. Tonel source files are
written to disk by Iceberg, not edited by hand.

**Rejected alternative:** Edit `.class.st` files directly and rely on
file-in. File-in loses interactive debugging, delays feedback, and
masks class-level lint findings that only fire when the class is
loaded in the image.

**Consequences:** Tight feedback loop. Requires a running image and
the Postern eval server. `make rebuild` must always succeed — if it
does not, the Tonel source is incomplete.

---

## ADR-2 — Disposable image, no save on stop

**Status:** SETTLED

**Decision:** `make stop` kills the Pharo process without saving the
image. The image on disk is a disposable workspace, not the source of
truth. The source of truth is Tonel under `src/`. `make rebuild` is
the recovery path.

**Rejected alternative:** Save the image on stop so that the next
`make start` resumes where we left off. Image saves capture socket
state that breaks on restore, and saved images drift from Tonel
invisibly.

**Consequences:** A fresh `make setup` must always produce a working
image. Saved context (open browsers, open inspectors) is not
preserved across restarts — intentionally.

---

## ADR-5 — No reflection in JSON serialization

**Status:** SETTLED

**Decision:** Each class implements `asJson` and `fromJson:` with
explicit per-field accessors. `jsonKeyMap` documents the camelCase ↔
snake_case wire mapping. We do not use `instVarNamed:` or
`allInstVarNames` to serialize.

**Rejected alternative:** A reflective serializer that walks
`allInstVarNames`. Reflection produces surprise-free behavior only
when every field in the Smalltalk class maps one-to-one with the wire
schema. The Messages API routinely adds optional fields, renames
camelCase to snake_case, and makes fields conditional on beta headers
— a reflective serializer silently corrupts data when that happens.

**Consequences:** Each new class requires explicit JSON methods.
Safer refactoring (rename a slot without silently changing the wire
format). New wire fields require an explicit accessor — they do not
"just work."

---

## ADR-6 — `critiques` API over `rule check:`

**Status:** SETTLED

**Decision:** Use `m critiques` (per-method) and `ReCriticEngine
critiquesOf: cls` (per-class) to inspect Renraku findings. The
deprecated `rule check:` form swallows errors and must not be used.
`make lint` runs the full Renraku rule set from CLI; per-method
`m critiques` is a debugging tool only.

**Rejected alternative:** `rule check: m`. Swallows exceptions during
rule evaluation, so a broken rule silently reports zero findings.

**Consequences:** `make lint` is the canonical gate. Per-method
probes are fine for diving into a specific finding but never for
gating a commit.

---

## ADR-7 — LF-to-CR normalization at eval server level

**Status:** SETTLED

**Decision:** `BootstrapEvalDelegate` normalizes LF to CR on every
eval server request body. Pharo compiles and stores methods with CR
line separators; external tools (HTTP clients, editors) default to
LF. Normalizing at the server boundary means every downstream caller
sees consistent CR-terminated source.

**Rejected alternative:** Normalize per-caller in each eval client.
Inconsistent — every new tool rediscovered the problem.

**Consequences:** Methods compiled via the eval server always have
CR line separators, regardless of client. `make filein` re-normalizes
any drift after a Tonel load.

---

## ADR-8 — Pharo 12 fluid class syntax mandatory

**Status:** SETTLED

**Decision:** New classes use the Pharo 12 fluid syntax:
`(Object << #MyClass slots: {...}; package: '...') install`. The
old `subclass:instanceVariableNames:classVariableNames:package:`
form is DEPRECATED.

**Consequences:** Consistency with the modern Pharo idiom. All new
code uses fluid syntax.

---

## ADR-9 — `compile:classified:` mandatory

**Status:** SETTLED

**Decision:** Always `compile:classified:` with an explicit
protocol. Never bare `compile:`. Unclassified methods show as "as
yet unclassified" in the System Browser.

**Consequences:** Every compiled method has a meaningful protocol.
Easier navigation in the browser.

---

## ADR-10 — Scoped test runs only

**Status:** SETTLED

**Decision:** Run `MyTest buildSuite run` or the package suite
(`ClaudeMessagingTestSuite suite run`), never the full Pharo test
suite. SUnit's watchdog opens a GUI window per failing test; running
the whole image's tests cascades morph windows and destroys the
taskbar.

**Consequences:** `make test` runs only Messaging tests. Workers
never run broad commands from inside the image.

---

## ADR-11 — Raw TLS socket for streaming

**Status:** SETTLED

**Decision:** `ClaudeStreamingSocket` opens a raw TLS socket
directly (not via `ZnClient`) to read SSE incrementally with
chunked transfer-encoding. This avoids `ZnClient`'s buffering
behavior, which reads the full response before yielding.

**Rejected alternative:** Use `ZnClient` with a custom entity
reader. `ZnClient` buffers the body internally — incompatible with
long-lived streaming sessions where the server holds the connection
open for tens of seconds.

**Consequences:** `ClaudeStreamingSocket` is more code but provides
true incremental streaming. The buffered `streamMessage:do:`
remains available for simple use cases.

---

## ADR-12 — MessageParams decomposition into parameter groups

**Status:** SETTLED

**Decision:** Separate parameter-object classes group related
request fields: `ClaudeSamplingParams` (temperature, top_p, top_k),
`ClaudeThinkingParams` (enabled/adaptive/disabled),
`ClaudeToolParams` (tools, tool_choice, parallel_tool_calls).
`ClaudeMessageRequest` composes these groups rather than flattening
every field.

**Rejected alternative:** One `ClaudeMessageRequest` class with
every field flat. Grows unboundedly as the API adds parameters;
gets hard to inspect and test.

**Consequences:** Parameter objects are reusable and testable in
isolation. JSON serialization flattens the structure on the wire.

---

## ADR-16 — Two-pass quality gate

**Status:** SETTLED

**Decision:** Every change goes through two review passes: the
author (kwb) runs `make lint` and `make test` after each logical
change; the reviewer (COO or the designated evaluator) runs the
same gates independently before merge. Both passes use `make lint`,
not the per-method probe.

**Consequences:** Lint findings caught once by the author, once by
the reviewer. Claims of "lint clean" are cross-checked.

---

## ADR-19 — Two-path git commit — Iceberg for Tonel, LibC for non-Tonel

**Status:** SETTLED

**Decision:** Tonel source (`src/*`) commits via Iceberg inside the
VM — it knows how to refresh dirty packages and write `.class.st`
files atomically. Non-Tonel files (docs, Makefile, CI YAML) commit
via `LibC resultOfCommand: 'git commit ...'` from inside the VM, or
via the Bash tool from the CLI — both paths are safe for
non-Tonel.

**Rejected alternative:** Commit everything via Iceberg. Iceberg
commits only the package files it knows about; docs changes go
unstaged.

**Consequences:** Two commit paths. Documented in CLAUDE.md LibC
Safety section.

---

## ADR-27 — Iceberg commit safety — package manifest and image state validation

**Status:** SETTLED

**Decision:** Before any programmatic Iceberg commit, refresh dirty
packages (`repo workingCopy refreshDirtyPackages`) and verify the
loaded package set matches what Tonel expects. Iceberg silently
deletes packages from Tonel if they are missing from the image at
commit time — so a stale image can destroy source files.

**Consequences:** `make check` verifies package completeness. Every
Iceberg commit is preceded by a refresh.

---

## ADR-32 — Uniform `ClaudeMessage` — no raw Dictionaries

**Status:** SETTLED

**Decision:** Every message returned by the API — whether from
`sendMessage:`, `streamMessage:do:`, or an SSE event — is an
instance of `ClaudeMessage`. Content blocks are typed
(`ClaudeContentBlock` hierarchy); they are never raw dictionaries.

**Rejected alternative:** Return raw `Dictionary` instances from
streaming events, because that is closer to the wire format. Forces
every caller to know the wire schema, duplicates parsing logic, and
makes the type system useless.

**Consequences:** All SDK surfaces return typed objects.
Polymorphism over conditionals for content-block dispatch.

---

## ADR-33 — `ClaudeMessageParams` renamed to `ClaudeMessageRequest`

**Status:** SETTLED

**Decision:** Rename `ClaudeMessageParams` →
`ClaudeMessageRequest`. Matches the Anthropic Messages API wire name
(`MessageCreateParams` in the OpenAPI spec is the body of a
`message_request`) and the Go SDK's `MessageRequest`.

**Consequences:** Downstream classes updated in the same PR via the
RB rename refactoring. Old selector aliases not kept — the monorepo
was the only consumer at the time.

---

## ADR-34 — `ClaudeImageBlock fromForm:` — live image attachment

**Status:** SETTLED

**Decision:** A live Pharo `Form` can be attached to a message as an
image content block via `ClaudeImageBlock fromForm:`. The SDK
serializes it as base64 PNG using `PNGReadWriter`.

**Rejected alternative:** Require the caller to encode the image to
a file first. Makes screenshot workflows awkward — the whole point
is "here is the current screen, describe it."

**Consequences:** Workbench and Agent SDK consumers can take
screenshots and attach them directly. Byte-size validation guards
against oversized forms.

---

## ADR-36 — Per-product test suite factories

**Status:** SETTLED

**Decision:** `ClaudeAbstractTestSuite` in
`Claude-Messaging-Client-Tests` holds the shared filter machinery
(filter `slow`, filter `integration`). `ClaudeMessagingTestSuite`
aggregates the 9 `Claude-Messaging-*-Tests` packages plus
`PharoKeyring-Tests`. `make test` runs the Messaging suite only.

In the monorepo, `ClaudeAgentTestSuite` extends the same pattern for
the Agent layer — but it is not part of this repo.

**Consequences:** The Messaging SDK can be tested in isolation,
without loading any Agent or Workbench classes. The shared filter
machinery stays in one place.

---

## ADR-37 — Typed beta-header catalog — `ClaudeBetaHeader`

**Status:** SETTLED

**Decision:** `ClaudeBetaHeader` is a typed enumeration of
Anthropic's beta-header strings (`mcp-client-2025-04-04`,
`prompt-tools-2024-01-15`, `skills-2025-04-04`, etc.). Callers pass
instances: `request betas: { ClaudeBetaHeader mcpClient }`.

**Rejected alternative:** Raw strings. Typos are silent and
surface as opaque 400 errors from the API.

**Consequences:** New beta headers require adding a class-side
method. The catalog becomes a canonical list of active beta
features.

---

## ADR-38 — Bidirectional casing aliases on content-block URL factories

**Status:** SETTLED

**Decision:** Factories like `ClaudeImageBlock url:` accept both
`url:` (camelCase) and `URL:` (legacy) selectors.
`ClaudeDocumentBlock` follows the same pattern. Added because
historical code used `URL:` and the aliases smooth the migration.

**Consequences:** Extra selector pairs. Documented in class comments
with a note that `url:` is preferred.

---

## ADR-39 — `disableCitations` clears the citations slot

**Status:** SETTLED

**Decision:** On `ClaudeDocumentBlock`, `disableCitations` clears
the `citations` slot entirely rather than setting a flag. The wire
format omits `citations` when it is nil, so clearing the slot is
the correct way to turn off citations.

**Rejected alternative:** Keep an `enabled` boolean separate from
the citations list. Two sources of truth; easy to get out of sync.

**Consequences:** `enableCitations` populates the slot;
`disableCitations` sets it to nil. JSON serialization naturally
omits the field when disabled.

---

## ADR-40 — Two package families: `Claude-Messaging-*` + `Claude-ManagedAgents-*`

**Status:** ACCEPTED

**Context:** anthropic-sdk-pharo's v0.5.0 ships only the Messages
API surface, organized under the `Claude-Messaging-*` package
prefix. The ROADMAP commits to adding Anthropic's Managed Agents
API beta resources — sessions, memory_stores, agents,
environments, user_profiles, vaults — on the path to v1.0 parity
with `anthropic-sdk-python` (which exposes them under
`beta/sessions/`, `beta/memory_stores/`, `beta/agents/`,
`beta/environments.py`, `beta/user_profiles.py`, `beta/vaults/`).
The question is whether those resources go under the existing
`Claude-Messaging-*` prefix or a new prefix.

**Decision:** Use a new prefix, `Claude-ManagedAgents-*`. The two
families remain in the same Pharo image and same Metacello
baseline; they are addressable as separate package surfaces.

**Rationale:** The existing `Claude-Messaging-*` packages are
legitimately Messages-API-specific or Messages-request-adjacent —
Files referenced via `file_id` in messages, Skills via `skill_id`,
MCP via the `mcp_servers` field, server tools via the `tools`
array. The Managed Agents resources are an orthogonal API
surface: their own request and response types, their own
endpoints, their own beta header. Forcing them under
`Claude-Messaging-*` would mean naming the Sessions package
`Claude-Messaging-Sessions`, which reads wrong (a session is not
a message) and conflates two distinct API families.

**Rejected alternatives:**

- **Single prefix `Claude-API-*` for everything**: would require
  renaming all nine existing `Claude-Messaging-*` packages. High
  mechanical cost; loses the Messages-specific signal in the
  existing prefix.
- **Single prefix `Claude-Messaging-*` extended**: would name the
  Sessions package `Claude-Messaging-Sessions`, which
  misrepresents what a session is.
- **Per-resource prefixes** (`Claude-Sessions-*`,
  `Claude-Agents-*`, `Claude-MemoryStores-*`): too fragmented;
  one resource per family obscures the relationship between
  resources that compose into the same API surface.

**Consequences:** Consumers loading the SDK via Metacello today
receive both families together — `BaselineOfClaudeMessaging`
ships no groups and no tiers. Selective loading via Metacello
groups (`messaging` for the v0.5/v0.6 surface, `managed-agents`
for the v0.7+ surface, `default` for everything) is planned for
the v0.7 baseline rename work tracked in bead
`claude-messaging-pharo-0cd`; when introduced, those groups will
partition the load surface so a consumer can pull in just the
Messaging family or just the Managed Agents family. Tests
organize the same way: `Claude-ManagedAgents-Sessions-Tests`,
`ClaudeManagedAgentsTestSuite`, etc.

---

## ADR-41 — `ManagedAgents` over `Agents` or `RemoteAgents`

**Status:** ACCEPTED

**Context:** Anthropic's documentation and Python SDK refer to
this resource family as "Managed Agents" in formal prose and
"agents" in path and code (`beta/agents/`). Punt Labs' monorepo
`claude-agent-sdk-smalltalk` already has `Claude-Agent-*`
packages — singular, no `-s` — for the IN-IMAGE local agent
runtime (`Claude-Agent-Exchange`, `Claude-Agent-Commands`, etc.).
The naming choice for the Anthropic-hosted resources affects
clarity for both readers and tooling.

**Decision:** Use `ManagedAgents` (CamelCase, single token) as
the package-name fragment and "Managed Agents" as the prose form.

**Rationale:** Aligns with Anthropic's formal vocabulary; clearly
distinguishes from the local `Claude-Agent-*` runtime in the
monorepo (which runs tools inside the user's image); the explicit
"Managed" qualifier communicates that these agents run on
Anthropic's infrastructure, not in the user's image.

**Rejected alternatives:**

- **`Agents`** (matches the Python SDK path): collides with the
  monorepo's `Claude-Agent-*` semantically — readers would
  conflate the two. Different concepts deserve different names.
- **`RemoteAgents`**: descriptively accurate but invents
  vocabulary that does not appear in Anthropic's docs. Inventing
  a synonym creates a translation layer between Anthropic's prose
  and ours.
- **`BetaAgents`**: tied to the beta status, which will change
  when the API graduates. Naming by stability is a moving target;
  every package would need a rename when the resource leaves
  beta.

**Consequences:** Every package in the new family carries the
`Claude-ManagedAgents-` prefix. CLAUDE.md and ROADMAP.md use the
term "Managed Agents" in prose; "ManagedAgents" in code
identifiers, package names, and class-name fragments.

---

## ADR-42 — `ClaudeClient` gateway with extension methods per family

**Status:** ACCEPTED

**Context:** `ClaudeClient` lives in `Claude-Messaging-Client`
and is the single gateway for every API call: `sendMessage:`,
`streamMessage:do:`, `countTokens:`, `uploadFile:`, `listSkills`,
and so on. v0.7+ adds Managed Agents methods (`createAgent:`,
`getSession:`, `createSession:`, `listSessions:`, etc.). The
question is whether `ClaudeClient` migrates to a new core
package, gets split into multiple client classes, or stays where
it is and grows via Pharo extension methods.

**Decision:** `ClaudeClient` stays in `Claude-Messaging-Client`.
New Managed-Agents methods are Pharo extension methods defined
in `Claude-ManagedAgents-*` packages. The method category
convention is `*Claude-ManagedAgents-Sessions` (the asterisk
prefix marks an extension whose defining package differs from
the host class's package).

**Rationale:** Single-gateway is the existing pattern and matches
`anthropic-sdk-python`'s `Anthropic` class, which exposes every
resource family. Pharo extension methods are first-class:
`BaselineOfClaudeMessaging` loads `Claude-Messaging-Client`
first, then any `Claude-ManagedAgents-*` package that needs to
extend `ClaudeClient` loads its extension methods on top. No
race, no inheritance hack. Selective loading still works — a
consumer who loads only the `messaging` group gets
`ClaudeClient` with only Messages methods; loading
`managed-agents` adds the agent methods.

**Rejected alternatives:**

- **Separate `ClaudeManagedAgentsClient` class**: would force
  consumers to instantiate two clients with the same API key.
  Unnatural and does not match `anthropic-sdk-python`. Doubles
  the configuration surface for no gain.
- **Move `ClaudeClient` to a new `Claude-Core-Client` package**:
  large rename for no semantic gain. `ClaudeClient`
  legitimately belongs to the Messaging family today; moving it
  would invent a "Core" layer that does not yet exist.
- **Subclassing**: `ClaudeManagedAgentsClient` as a subclass of
  `ClaudeClient`. Pharo's class hierarchy is per-image; a
  subclass adds nothing over extension methods and forces a
  choice at instantiation time that does not need to exist.

**Consequences:** The extension method category convention
enforces package-of-origin clarity — the System Browser shows
`*Claude-ManagedAgents-Sessions` so readers know the methods
come from a different package than the host class. Tests for
those extension methods live in the defining package's `-Tests`
package (`Claude-ManagedAgents-Sessions-Tests`), not in
`Claude-Messaging-Client-Tests`. The host class's package can
be loaded without the extensions; the extensions cannot be
loaded without the host class.
