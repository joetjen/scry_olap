# Changelog

## [Unreleased]

### Added

- Initial project scaffold: `mix.exs` (app `:scry_olap`, `{:scry_core, path: "../scry_core"}` a real, unscoped dependency until `scry_core` is published to Hex), `.credo.exs`/`.formatter.exs`/`.tool-versions`, `AGENTS.md`/`CLAUDE.md`.
- `Scry.Olap.parse/1` -- a direct, permanent delegation to `Scry.Core.parse/1`. `olap` is a degenerate kind ("`relational` and `olap` are core-only kinds today -- no grammar-contributing variant"), the same shape as `scry_relational`: confirmed against `scry_core` itself, which already hardcodes `@degenerate_kinds ["relational", "olap"]` in its own `Scry.Core.TypeCheck` -- `type Foo: olap` type-checks correctly with zero code from this package. Concretely, the classic OLAP analytical constructs (`GROUP BY ROLLUP(...)`/`GROUP BY CUBE(...)`) are already core-level grammar, available to any kind, not gated behind an `olap` tag -- nothing distinctly "OLAP" is left for this package's own grammar to add. What this package adds instead: the canonical dependency name an analytical application declares (`{:scry_olap, "~> 0.1"}`), and a `<Kind>.parse/1` entry point matching every other `scry_<kind>` package's own convention. No `Scry.Olap.Executor`/`.Actions`/`.Grammar` module exists -- there is nothing for any of them to do; use `Scry.Core.Executor.run/3,4` directly. `test/scry/olap_test.exs` (a `StreamData` property test asserting `parse/1 == Scry.Core.parse/1` for any input, plus concrete examples including `ROLLUP`/`CUBE`).
