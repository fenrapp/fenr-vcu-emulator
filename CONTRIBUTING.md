# Contributing

Bug reports, focused fixes and improvements to protocol compatibility are welcome.

## Set up and verify

Follow the requirements in README.md, fork this repository and create a topic branch. Run `scripts/check.sh` before opening a pull request. Generated Xcode projects and compiler output do not belong in commits.

Keep changes focused and describe the observed problem, resulting behavior and validation. Use small conventional commits such as `fix(ble): ...`, `feat(simulation): ...` or `docs: ...`. A pull request should build independently with no dependency on a local iOS checkout.

## Code conventions

- Keep App responsible for composition and a single session lifecycle.
- Keep feature UI isolated from protocol, Bluetooth, storage and domain types. Publish feature-owned presentation through injected mappers and view models.
- Inject replaceable collaborators. Own and cancel asynchronous tasks, reject stale session work and bound queues.
- Put English UI copy in the owning string catalog. The catalogs are maintained explicitly; source extraction is disabled to keep local and CI builds reproducible.
- Place tests with their module or feature: doubles in Tests/TestDoubles, factories in Tests/Support and immutable fixtures in Tests/Fixtures.
- Preserve configuration siblings and distinguish ATT acknowledgment, command result and fresh readback. Unsupported operations must fail explicitly.

See docs/architecture.md and AGENTS.md for the complete boundaries. Add a focused regression test for changed behavior and inspect native UI changes at small and normal window sizes.

## Reporting a bug

Open a GitHub issue with:

1. Emulator commit/version, macOS version and compatible FENR/iOS versions.
2. Scenario, fault profile and steps to reproduce.
3. Expected behavior and actual behavior.
4. A relevant Activity export and, where useful, a screenshot using only synthetic data.

Do not include real motorcycle identifiers, credentials, security payloads, private captures or signing files. Public screenshots in docs/images are deliberately reviewed synthetic examples. For a possible security vulnerability, use GitHub private vulnerability reporting if available; do not publish exploit credentials in an issue.

## Protocol and licensing

Retain third-party notices. Vendored sources are checked against Modules/ProtocolCore/UpstreamManifest.json; changes need an explicit provenance update. Prefer independent wire fixtures so shared client/emulator code cannot hide the same mistake on both sides.

Mark automatic, native visual and physical checks separately. Only claim hardware behavior actually observed; emulation alone does not establish motorcycle compatibility. By contributing, you agree that your contribution is licensed under this repository's MIT license.
