defmodule ParserTest do
  use ExUnit.Case
  doctest Parser

  alias Parser.LetStatement

  test "let statements work correctly" do
    input = ~s{
   let x = 5;
   let y = 10;
   let foobar = 838383;
    }

    lexer = %Lexer{input: input}
    parser = %Parser{lexer: lexer}
    initialized_parser = Parser.advance_token(parser)
    %Parser{statements: statements} = Parser.parse(initialized_parser)

    expected_identifiers = ["x", "y", "foobar"]
    assert(length(statements) == 3)

    statements
    |> Enum.with_index()
    |> Enum.each(fn {%LetStatement{token: token, name: name}, idx} ->
      assert(token == :let)
      assert(el = Enum.at(expected_identifiers, idx))
    end)
  end
end
