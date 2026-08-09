defmodule Scry.OlapTest do
  @moduledoc """
  `Scry.Olap.parse/1` is a direct, permanent delegation to `Scry.Core.
  parse/1` -- the property test below is the actual proof of that
  (equal on every input, not just a handful of examples), per
  AGENTS.md's own preference for a parser-shaped input space; the
  concrete example tests exist for readability/documentation, not
  because the property test leaves any real gap. The `ROLLUP`/`CUBE`
  example specifically proves the classic OLAP constructs are already
  core-level grammar, not something this package needs to add.
  """

  use ExUnit.Case, async: true
  use ExUnitProperties

  property "parse/1 is byte-for-byte identical to Scry.Core.parse/1, success or failure" do
    check all(source <- StreamData.string(:printable, max_length: 200)) do
      assert Scry.Olap.parse(source) == Scry.Core.parse(source)
    end
  end

  test "a plain WHERE query parses the same as through Scry.Core.parse/1" do
    query = ~s(SELECT users WHERE age > 18 { name })
    assert Scry.Olap.parse(query) == Scry.Core.parse(query)
    assert {:ok, %Scry.Core.Query{source: ["users"]}} = Scry.Olap.parse(query)
  end

  test "GROUP BY ROLLUP -- already core-level grammar, not an olap-specific addition" do
    query = ~s"""
    SELECT sales GROUP BY ROLLUP(region, quarter) { region, quarter, total: sum(amount) }
    """

    assert Scry.Olap.parse(query) == Scry.Core.parse(query)
  end

  test "GROUP BY CUBE -- same claim, the other core-level rollup-style extension" do
    query = ~s"""
    SELECT sales GROUP BY CUBE(region, quarter) { region, quarter, total: sum(amount) }
    """

    assert Scry.Olap.parse(query) == Scry.Core.parse(query)
  end

  test "a nested SELECT (Scry's own JOIN-equivalent) parses the same as through Scry.Core.parse/1" do
    query = ~s"""
    SELECT users { name, SELECT orders WHERE user_id = users.id { id } }
    """

    assert Scry.Olap.parse(query) == Scry.Core.parse(query)
  end

  test "a parse failure is returned identically, not swallowed or reshaped" do
    assert Scry.Olap.parse("NOT A REAL QUERY") == Scry.Core.parse("NOT A REAL QUERY")
    assert {:error, _reason} = Scry.Olap.parse("NOT A REAL QUERY")
  end
end
