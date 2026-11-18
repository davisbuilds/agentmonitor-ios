# AGENTS.md

Native SwiftUI companion app for [AgentMonitor](https://github.com/davisbuilds/agentmonitor)
(iPhone, iPad, and Mac) that monitors AI agent activity from an AgentMonitor
server (default `http://127.0.0.1:3141`); the app does nothing without one running.

## Documentation Map

- `README.md` — introduction and setup; `CONTRIBUTING.md` — contribution scope.
- `docs/ARCHITECTURE.md` — system design and module map.
- `docs/DESIGN_DECISIONS.md` — rationale for each major technical choice.
- `docs/API_CONTRACT.md` — the server API the app consumes.
- `docs/TEST_STRATEGY.md` — intended test pyramid (target state, not what exists).
- `docs/project/ROADMAP.md`, `docs/project/BACKLOG.md`.
- `docs/project/GIT_HISTORY_POLICY.md` — merge strategy and local quality gates.

## Implementation Guardrails

- `AgentMonitor.xcodeproj` is generated from `project.yml` and gitignored. Run
  `xcodegen generate` after adding or removing files; edit `project.yml`, not the
  project.
- No third-party dependencies: everything builds on Apple frameworks
  (`docs/DESIGN_DECISIONS.md`). Adding one is the maintainer's decision.
- Models are pure Swift (no SwiftUI imports), `Codable` + `Sendable`; ViewModels
  are `@Observable @MainActor` classes.
- Enums decoded from the server carry an `.unknown(String)` case so a new server
  value never fails decoding.

## Testing

- **Local gate:** `xcodegen generate && xcodebuild test -scheme AgentMonitor -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`
  (builds the app, then runs the tests), plus `python3 scripts/check_publication_hygiene.py`.
  The Mac app compiles the same sources, so for any code change also run
  `xcodebuild test -scheme AgentMonitorMac -destination 'platform=macOS'`.
- **CI does not build or test.** The only workflow runs the publication-hygiene
  scan, so a green PR proves nothing about the app. Record the gate command, the
  head it ran on, and its result in the PR body; a PR without that record is not
  ready to merge.
- Tests use Swift Testing (`@Test`, `#expect`), not XCTest; match
  `AgentMonitorTests/`.
- Only model decoding is tested; services and ViewModels have no tests yet (see
  `docs/project/BACKLOG.md`). A `Codable` model is not "code with no behavior to
  assert": decoding is the contract with the server, so new models get a decoding
  test against a fixture.

## Working Agreement

- **Clarify before building** when a request is vague, contradictory, or skips a
  key decision; clear, well-scoped requests need no interview.
- **Fix small issues now; backlog the rest.** Fix simple, quick, or blocking
  issues in this repo as part of the current change and call them out. Record in
  `docs/project/BACKLOG.md` only what can't be finished now or needs the
  maintainer's decision; don't open a branch or PR just for a backlog entry.
- **Keep docs current** when a change makes a documented contract, boundary,
  procedure, or direction stale.
- **Plan and preserve continuity proportionately.** Reuse clear task context.
  Save planning docs when decisions, acceptance, or coordination need
  persistence, and leave a brief handoff only when needed to resume unfinished
  work. Commit shared docs and keep their status current. `docs/archive/` is
  gitignored and local-only: before moving a doc there, preserve lasting
  decisions and open work in maintained docs and repair links. Keep tracked docs suitable for public readers and private
  evidence local.
- **TDD:** red/green for features, major refactors and large changes; the red
  test must fail on the behavior, not on a missing symbol. For smaller edits, run
  the relevant existing checks.
- **Commit and push.** Commit coherent chunks, staging by explicit path. Push
  your task branch and open a PR once the work is complete and the local gate
  passes; don't push directly to `main`.
- **Merge** only under the standing merge authority in the maintainer's workspace
  instructions, or when the maintainer asks. Without those instructions in
  context, leave the PR for the maintainer.
- **History and releases.** Squash is disabled: merge commit by default, rebase
  only when the branch's commits are already clean. A merge ships nothing: there
  is no release or distribution automation.
- **Re-ground after compaction** in source, this file, the owning docs, and
  recent commits. A summary and your own earlier proposals are not user approval.
