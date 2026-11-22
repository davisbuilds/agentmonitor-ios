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

### A discovered server connects to its Bonjour service name and an assumed port

- **What**: `ServerDiscovery.updateServers` builds each `DiscoveredServer` with
  `host` set to the Bonjour service instance name and `port` fixed at 3141.
  `SettingsViewModel.connectToDiscovered` then connects to
  `http://<service name>:3141`. Nothing resolves the service to a host and
  port, although the comments at those lines say resolution happens on connect.
- **Why or evidence**: a service instance name is a display label, not a DNS
  hostname, and a server advertising another port is never reached. Picking a
  discovered server likely fails unless the name happens to resolve
  (**hypothesis, unmeasured**; found 2026-11-21 in the comment sweep, not run
  against a live server).
- **Next**: resolve the `NWBrowser.Result` endpoint (an `NWConnection` to the
  service endpoint, or a `NetService` resolve) to a host and port before
  building the URL, then delete the comments in `updateServers`.

### Session messages show only a plain-text preview

- **What**: `MessageBlockView` shows `contentPreview`, the text and tool-use
  names from the message's JSON content blocks, cut to 500 characters and 10
  lines. Thinking blocks, tool inputs and results, and the rest of long
  messages are not shown.
- **Why or evidence**: the session browser cannot show a full message. A
  removed comment called this a stopgap until rich rendering of content blocks.
- **Next**: decode `Message.content` into typed content blocks and render each
  kind, with long text expandable.

### Session list refresh and pagination failures leave no visible trace

- **What**: `SessionsViewModel.loadMore` catches a failed page fetch and only
  prints it in DEBUG builds. The `sessionUpdate` handler in
  `MonitorViewModel.handle` refetches with `try?` and silently keeps the stale
  list.
- **Why or evidence**: a dropped connection mid-scroll or a failed refresh looks
  like the end of the list or an up-to-date list. `SessionsView` shows `error`
  only when the list is empty, so setting it would not replace loaded rows.
- **Next**: set `error` in `loadMore`'s catch and show a non-destructive retry
  row when rows are already loaded; decide whether the live refresh should
  surface its failure the same way.
