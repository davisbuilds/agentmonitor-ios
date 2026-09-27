# Backlog

Future-only design gaps, tech debt, and better ways to do a thing noticed during normal
execution. Fix simple, quick, or blocking issues inline; capture only durable follow-ups
worth revisiting cold. Add an item only when it cannot be fixed inline and represents
recurring friction, meaningful risk or cost, an unresolved decision, or a concrete
trigger. This is not a changelog or implementation plan. Agents can work directly
from a clear entry; use an issue when persistent discussion or coordination helps.
Keep one detailed owner with short links where useful. Selected direction belongs
in `ROADMAP.md`; commits and pull requests hold routine shipped detail.

This repository is the canonical owner for its follow-ups; cross-repository work belongs
with the repository that owns the capability, with links from affected repositories only
when useful. Date and source volatile external or runtime claims, or label them a
hypothesis.

Each entry: **What** / **Why or evidence** / optional **Next** / optional **Revisit when**.
Use **Next** for the smallest action that makes an item actionable and **Revisit when**
only for an intentional external or measurable gate.

Reconcile an entry when work affects it: refresh its evidence, retain the unresolved
remainder, or remove it when resolved. Revisit the broader list during prioritization
or when stale entries impede work.

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
