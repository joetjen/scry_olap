defmodule Scry.Olap do
  @moduledoc """
  The `olap` kind for Scry -- a **degenerate kind**, the same shape as
  [`scry_relational`](https://github.com/joetjen/scry_relational):
  `olap` has no EP1/EP2 vocabulary of its own. This is by design:
  *"`relational` and `olap` are core-only kinds today -- no
  grammar-contributing variant, because nothing beyond core's shared
  vocabulary has been needed for them."*

  Concretely, not just by assertion: the classic OLAP analytical
  constructs -- `GROUP BY ROLLUP(...)`/`GROUP BY CUBE(...)`, subtotal
  rows per hierarchy level or per field combination -- are already
  core-level grammar, available to *any* kind's query, not gated
  behind an `olap` tag at all. There is nothing distinctly "OLAP" left
  for this package's own grammar to add; core's shared vocabulary
  already covers it.

  `scry_core` itself already fully supports a `type Foo: olap`
  declaration with zero code from this package (`Scry.Core.TypeCheck`'s
  own `@degenerate_kinds ["relational", "olap"]`). So what does this
  package add? Two real things: a canonical dependency name an
  analytical application declares (`{:scry_olap, "~> 0.1"}`), and
  `Scry.Olap.parse/1`, which mirrors every other `scry_<kind>`'s own
  `<Kind>.parse/1` entry point -- a direct, permanent delegation to
  `Scry.Core.parse/1`, not a placeholder for grammar work that hasn't
  landed.

  **No `Scry.Olap.Executor`, `.Actions`, or `.Grammar` modules exist
  here**, unlike `scry_time_series` -- there is nothing for any of them
  to do. An OLAP-shaped query (`ROLLUP`/`CUBE` included) needs no AST
  rewriting before execution; use `Scry.Core.Executor.run/3,4` directly
  against the query this module's `parse/1` returns.

  **No `scry_test_olap` package either** -- `scry_test_core` already
  exercises exactly this grammar (core's own baseline, byte-identical
  to olap's own), so a second, duplicate fixture package would add
  nothing genuinely new to test against.
  """

  alias Scry.Core.{CombinedQuery, Query}

  @doc """
  Parses `source` (Scry query text) into a `%Scry.Core.Query{}` (or a
  `%Scry.Core.CombinedQuery{}`, per `Scry.Core.parse/1`'s own combinator
  handling) -- a direct, permanent delegation, not a temporary shim:
  olap has no grammar fragment to compose in, so there is nothing for
  this function to do beyond calling straight through.
  """
  @spec parse(String.t()) :: {:ok, Query.t() | CombinedQuery.t()} | {:error, term()}
  def parse(source) when is_binary(source) do
    Scry.Core.parse(source)
  end
end
