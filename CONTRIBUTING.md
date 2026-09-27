# Contributing

Focused bug fixes, client/server contract corrections, accessibility improvements,
tests, and documentation changes are welcome. Discuss substantial features,
dependencies, integrations, or public-interface changes before implementation.
The server is maintained in a separate
[repository](https://github.com/davisbuilds/agentmonitor); coordinate server
contract changes there rather than assuming this client owns them.

Agent-assisted work is welcome. The submitter should understand the change's
purpose, important behavior, tradeoffs, and verification limits. A prompting
diary or human rewrite is not required.

Start with [README.md](README.md) for setup. Keep PRs focused, describe what
changed and what you checked, and note checks you could not run. The existing
tests cover model decoding only; [AGENTS.md](AGENTS.md) and
[TEST_STRATEGY.md](docs/TEST_STRATEGY.md) explain the current and target test
surfaces. The [history policy](docs/project/GIT_HISTORY_POLICY.md) preserves
individual commits: tidy WIP commits before submitting a PR. A maintainer merges
after applicable checks and review.
