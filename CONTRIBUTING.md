# Contributing to Claude Messaging SDK for Pharo

## Development Environment

### Prerequisites

- A machine that can run Pharo 12 (Linux x86_64 or macOS)
- `make`, `curl`
- An Anthropic API key (for integration tests)

### Setup

```bash
git clone git@github.com:punt-labs/claude-messaging-pharo.git
cd claude-messaging-pharo
make setup    # downloads Pharo 12 VM + image, loads all packages
make start    # launches Pharo with eval server on port 8422
```

`make rebuild` produces a fresh image from Tonel source files. It must always
succeed -- if it fails, source files are incomplete.

### Development Model

All development happens inside the running Pharo image via the eval server
(HTTP POST to `http://localhost:8422/repl`). The eval server provides
interactive class definition, method compilation, testing, and introspection.

- Define classes via eval server using Pharo 12 fluid syntax
- Compile methods via eval server using `compile:classified:`
- Run tests via eval server or `make test`
- Lint via `make lint` from CLI (the canonical gate — `m critiques` misses
  class-level rules)
- Persist code to disk via Iceberg (inside the VM), which writes Tonel
  `.class.st` files to `src/`

The image is disposable. `make stop` kills without saving. `make rebuild`
is the recovery path. Never commit the Pharo image or VM (`pharo/` is
gitignored).

## Package Layers

Code is organized in one layer plus a standalone package:

| Package | Purpose |
|---------|---------|
| `Claude-Messaging-Types` | Domain hierarchy: messages, content blocks, tools, models, request/response types |
| `Claude-Messaging-Errors` | `ClaudeApiError` hierarchy keyed on HTTP status |
| `Claude-Messaging-Streaming` | SSE decoder + raw streaming socket |
| `Claude-Messaging-Client` | `ClaudeClient` — the API client entry point |
| `Claude-Messaging-Tools` | Server-side tool definitions (Anthropic-side execution) |
| `Claude-Messaging-Files` | Files API — upload, download, list, delete |
| `Claude-Messaging-MCP` | MCP connector — request-side server definition |
| `Claude-Messaging-Skills` | Skills API — upload reusable tool packages |
| `Claude-Messaging-Examples` | Runnable usage examples |
| `PharoKeyring` | Cross-platform OS keyring wrapper (standalone) |

Each production package has a matching `-Tests` package.
`BaselineOfClaudeMessaging` is the Metacello entry point.

## Code Standards

### Class Definition

Use Pharo 12 fluid syntax. The old `subclass:instanceVariableNames:` form
is deprecated and must not be used.

```smalltalk
(Object << #MyClass
  slots: { #instVar1. #instVar2 };
  package: 'MyPackage') install.
```

### Method Compilation

Always use `compile:classified:` with an explicit protocol name. Never bare
`compile:`.

```smalltalk
MyClass compile: 'myMethod ^ 42' classified: 'accessing'.
```

Standard protocols: `accessing`, `json`, `tests`, `printing`, `models`,
`instance creation`, `converting`, `private`.

### Class Comments

Every production class must have a class comment that includes at least one
`>>>` doc example. `>>>` examples are live Pharo documentation -- the left
side is a Smalltalk expression, the right side is its printed result. The
System Browser can execute them.

```smalltalk
"ClaudeMessageRequest is the request body for a messages API call.

  ClaudeMessageRequest new model: ClaudeModel sonnet45; maxTokens: 1024.
  >>> a ClaudeMessageRequest
"
```

Current coverage: 100% of production classes.

### JSON Serialization

No reflection (`instVarNamed:`, `allInstVarNames`). Each class implements
`asJson` and `fromJson:` with explicit accessors. `jsonKeyMap` documents
the camelCase-to-snake_case mapping.

### Lint

`make lint` from CLI is the canonical lint gate. Zero findings required.
Pipe through `grep -v ': clean$' | grep -v '^$'` — if any line remains,
the lint is dirty.

```bash
make lint 2>&1 | grep -v ': clean$' | grep -v '^$'
# expected: nothing
```

Per-method `m critiques` is a debugging tool, not the gate — it misses
class-level rules like unused instance variables. The deprecated
`rule check:` form swallows errors and must not be used.

### Refactoring

Use the RB (Refactoring Browser) engine for renames, moves, and extractions.
`RBRenameClassRefactoring`, `RBRenameMethodRefactoring`, and friends update
all references atomically and register an undo step with the change manager.
Manual find-and-replace across files is not acceptable -- it misses senders,
implementors, and keyword selectors.

### Naming

- Packages: `Claude-Messaging-*` (e.g., `Claude-Messaging-Client`)
- Class names: `Claude` prefix for all SDK types
- Method names: intention-revealing (`sendMessage:` not
  `postToMessagesEndpoint:`)
- JSON keys: snake_case on wire, camelCase in Smalltalk

### Permissions

This SDK has no permission policy — it is a network client. Permission
management is an Agent SDK concern and lives in the separate
`claude-agent-sdk-smalltalk` repo.

## Testing

Run the SDK test suite:

```bash
make test
```

This runs `ClaudeMessagingTestSuite suite` — all
`Claude-Messaging-*-Tests` packages plus `PharoKeyring-Tests`. Never run
the full Pharo test suite -- it leaks watchdog processes and is not
relevant.

All new code must include tests. Bug fixes must include a regression test
that reproduces the original failure.

Run lint after changes:

```bash
make lint
```

Verify Iceberg working copy is clean before pushing:

```bash
make check
```

## Documentation

If you changed `docs/specifications/messaging-specification.tex` or
`messaging-specification-pharo-notes.tex`, rebuild the PDFs with
`make spec` (requires `pdflatex` installed). Commit both the `.tex` and
`.pdf` changes together — the PDF is the published artifact and must
stay in sync with the source.

## Image-Based Development Hazards

Live image development is faster than file-in, but it has failure modes
that do not exist in stateless build systems.

- **Runaway debuggers.** A background process that errors repeatedly can
  open debuggers faster than the user can dismiss them. If the cascade
  locks the image, stop immediately -- do not try to fix it from inside.
- **Contaminated image.** After a cascade or a bad `become:`, the image
  may hold stale class definitions or broken morphs. `make stop` followed
  by `make rebuild` is the recovery path. The image is disposable.
- **LibC is unsafe from inside the VM.** Never use `LibC` to call `make`,
  `curl localhost`, or any command that talks back to the running image.
  The VM is single-threaded for external calls -- shelling out to
  something that calls into the same image hangs the VM. See the LibC
  Safety section in `CLAUDE.md` for the full rule.
- **Stale working copy deletions.** Iceberg commits from a stale image
  can delete packages that exist on disk but not in the loaded image.
  Always sync with `make filein` before committing from a long-running
  image.

## Correction of Errors (COE)

When something breaks -- a production bug, a tooling mistake, a process
failure -- write a COE in `docs/coes/YYYY-MM-DD-short-name.md`. A COE
captures what happened, the impact, the root cause (provable, not
guessed), the fix, and the lessons that should change behavior going
forward. COEs are how the team learns from mistakes without repeating
them.

## Submitting Changes

1. Create a feature branch from `main` using conventional prefixes:
   `feat/`, `fix/`, `refactor/`, `docs/`, `chore/`.
2. Make your changes following the code standards above.
3. Run `make test` and `make lint`. Both must pass with zero failures
   and zero findings.
4. Run `make rebuild` to verify source files are complete.
5. Commit with conventional commit messages: `type(scope): description`.
6. Open a pull request against `main`.

## Architecture Reference

- [DESIGN.md](DESIGN.md) — Architecture Decision Records
- [CHANGELOG.md](CHANGELOG.md) — release history
- [docs/specifications/messaging-specification.pdf](docs/specifications/messaging-specification.pdf)
  — the full Messaging API specification
- [docs/specifications/messaging-specification-pharo-notes.pdf](docs/specifications/messaging-specification-pharo-notes.pdf)
  — Pharo-specific implementation notes
- [docs/specifications/bootstrapping-pharo.pdf](docs/specifications/bootstrapping-pharo.pdf)
  — bootstrap mechanism
