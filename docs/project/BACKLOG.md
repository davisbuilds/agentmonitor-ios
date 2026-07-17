# Backlog

Future-only friction points, tech debt, and better-tool-for-the-job ideas noticed during
implementation. Not a changelog — completed work graduates to `docs/project/ROADMAP.md`.

Each entry: what / why / tradeoff / recommendation / status.

## Test coverage is model-decoding only; TEST_STRATEGY.md describes a pyramid that doesn't exist

- **What**: `AgentMonitorTests/ModelDecodingTests.swift` is the only test file — 6 Swift Testing
  cases over decoding and unknown-enum handling. `docs/TEST_STRATEGY.md` describes a unit /
  integration / UI pyramid ("bulk of tests" at the unit layer, opt-in integration against a real
  server, UI tests on critical paths). None of the Services, ViewModels, or UI layers are tested.
- **Why it matters**: the doc reads as a description of current state, so an agent (or a future
  reader) can conclude coverage exists where it doesn't. `SSEClient`, `APIClient`, and
  `ServerConnection` hold the reconnect/parse logic most likely to regress silently.
- **Tradeoff**: the app is a read-only client over a local server — a decode bug surfaces
  immediately in the UI, so the practical cost of thin coverage has been low so far. Building the
  integration tier means either a live server dependency or a fixture server.
- **Recommendation**: cover `SSEClient` event parsing and `APIClient` error paths first (both are
  pure enough to test off-simulator); leave the UI tier aspirational. Either mark the unbuilt
  layers in `TEST_STRATEGY.md` as target-state or trim them to what's real.
- **Status**: open. Noted 2026-07-16 during the portfolio TDD-guidance pass; `AGENTS.md` Testing
  section now states the real coverage and flags the doc as target-state.
