# Backlog

Future-only gaps and opportunities worth revisiting. Capture recurring friction,
meaningful risk or cost, unresolved decisions, or concrete revisit triggers.
Fix simple, quick, or blocking issues inline when within the active task's scope.

## Conventions

- **Entry:** state **What** and **Why or evidence**. Add **Next** (a useful first
  action) or **Revisit when** (a concrete gate) where helpful; no fixed template
  is required.
- **Evidence:** date and source volatile claims. Support causal or performance
  claims with measurements, or label them **hypothesis, unmeasured**.
- **Delegation:** agents can execute entries directly. Recording a candidate does
  not expand the active task or select a roadmap priority. Use an issue when
  persistent discussion or coordination helps; no mandatory graduation step.
- **Ownership:** keep cross-repository work with the capability-owning repository.
  If an issue owns the details, retain only a useful linked summary here; avoid
  parallel checklists. Keep private evidence out of public entries and issues.
- **Closure:** reconcile affected entries as work lands. Remove resolved concerns,
  retain unresolved remainders, and preserve durable rationale in its owning
  reference. Roadmap records selected direction; Git and PRs hold routine shipped
  history. Revisit the broader list during prioritization or when stale entries
  impede work.

## Open

### Test coverage is model-decoding only; TEST_STRATEGY.md describes a pyramid that doesn't exist

- **What**: `AgentMonitorTests/ModelDecodingTests.swift` is the only test file — 6 Swift Testing
  cases over decoding and unknown-enum handling. `docs/TEST_STRATEGY.md` describes a unit /
  integration / UI pyramid ("bulk of tests" at the unit layer, opt-in integration against a real
  server, UI tests on critical paths). None of the Services, ViewModels, or UI layers are tested.
- **Why or evidence**: the doc reads as a description of current state, so an agent (or a future
  reader) can conclude coverage exists where it doesn't. `SSEClient`, `APIClient`, and
  `ServerConnection` hold the reconnect/parse logic most likely to regress silently. The app is a
  read-only client over a local server, so the practical cost has been low; the integration tier
  needs either a live-server dependency or a fixture server.
- **Next**: cover `SSEClient` event parsing and `APIClient` error paths first (both are
  pure enough to test off-simulator); leave the UI tier aspirational. Either mark the unbuilt
  layers in `TEST_STRATEGY.md` as target-state or trim them to what's real.
- Noted 2026-07-16 during the portfolio TDD-guidance pass; `AGENTS.md` Testing section
  now states the real coverage and flags the doc as target-state.

### A fresh clone cannot build: `Preview Content` is untracked

- **What**: `project.yml` names `AgentMonitor/Resources/Preview Content` as a
  resource and in `DEVELOPMENT_ASSET_PATHS`, but the directory is empty and Git
  does not track empty directories, so a fresh clone or worktree lacks it.
  `xcodebuild` then fails `ValidateDevelopmentAssets` ("One of the paths in
  DEVELOPMENT_ASSET_PATHS does not exist") before any test runs.
- **Why or evidence**: 2026-11-17, a fresh worktree of `main` failed the documented
  gate with exit 65; after `mkdir -p "AgentMonitor/Resources/Preview Content"` the
  same command built and passed all 6 tests. CI does not build, so nothing caught it.
- **Next**: track a placeholder (for example a preview asset catalog) or drop the
  path from `project.yml`; then remove the `mkdir -p` step from the `AGENTS.md` gate.
