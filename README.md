# scry_olap

The `olap` kind for [Scry](https://github.com/joetjen/scry)
(lang_spec.md §2/§7) — a `scry_<kind>` package (impl_spec.md §2), but a
**degenerate** one, the same shape as
[`scry_relational`](https://github.com/joetjen/scry_relational): `olap`
has no EP1/EP2 vocabulary of its own. lang_spec.md says so directly:
*"`relational` and `olap` are core-only kinds today — no
grammar-contributing variant, because nothing beyond core's shared
vocabulary has been needed for them."*

Concretely, not just by assertion: the classic OLAP analytical
constructs — `GROUP BY ROLLUP(...)`/`GROUP BY CUBE(...)`, subtotal rows
per hierarchy level or per field combination — are already core-level
grammar, available to *any* kind's query, not gated behind an `olap`
tag at all. There is nothing distinctly "OLAP" left for this package's
own grammar to add — no `Scry.Olap.Grammar`/`.Actions`/`.Executor`
module exists here the way `scry_time_series` has its own.

`scry_core` itself already fully supports a `type Foo: olap`
declaration with zero code from this package (`Scry.Core.TypeCheck`'s
own `@degenerate_kinds ["relational", "olap"]`). So what does this
package add? Two real things: a canonical dependency name an
analytical application declares (`{:scry_olap, "~> 0.1"}`, matching
impl_spec.md §5's own consumption model), and `Scry.Olap.parse/1`,
which mirrors every other `scry_<kind>`'s own `<Kind>.parse/1` entry
point — a direct, permanent delegation to `Scry.Core.parse/1`, not a
placeholder for grammar work that hasn't landed.

No `scry_test_olap` package exists either —
[`scry_test_core`](https://github.com/joetjen/scry_test_core) already
exercises exactly this grammar (core's own baseline, byte-identical to
olap's own, `ROLLUP`/`CUBE` included), so a second, duplicate fixture
package would add nothing genuinely new to test against.

Source: <https://github.com/joetjen/scry_olap>. Specs live in the
separate [`scry`](https://github.com/joetjen/scry) repository; the
grammar/type-check machinery this delegates to lives in
[`scry_core`](https://github.com/joetjen/scry_core).

## Usage

```elixir
{:ok, %Scry.Core.Query{} = query} =
  Scry.Olap.parse(~s(SELECT sales GROUP BY ROLLUP(region, quarter) { region, quarter, total: sum(amount) }))

{:ok, cursor} = Scry.Core.Executor.run(query, MyEngine, conn)
rows = Scry.Core.Cursor.to_list(cursor)
```

There is no `Scry.Olap.Executor` — unlike a kind with real grammar
extensions (`scry_time_series`'s own `LAST`, say, which its own
`Executor.run/5` has to lower into an ordinary predicate first), an
OLAP-shaped query needs no rewriting before execution. Use
`Scry.Core.Executor.run/3,4` directly against whatever `Scry.Olap.
parse/1` returns.

## Installation

```elixir
def deps do
  [
    {:scry_olap, "~> 0.1.0"}
  ]
end
```

## Documentation

Documentation is generated with [ExDoc](https://github.com/elixir-lang/ex_doc):

- Released versions are published to [HexDocs](https://hexdocs.pm) once the
  package ships, at <https://hexdocs.pm/scry_olap>.
- Latest `main` is built and deployed automatically by
  [`.github/workflows/docs.yml`](.github/workflows/docs.yml) to
  [GitHub Pages](https://joetjen.github.io/scry_olap/) on every push to `main`.
