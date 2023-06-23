defmodule ParserTest do
  use ExUnit.Case
  doctest Parser

  alias Parser.{ExpressionStatement, LetStatement}

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
      assert(name == Enum.at(expected_identifiers, idx))
    end)
  end

  test "incorrect let statements throw errors" do
    no_equal_input = ~s{
   let x 5;
    }
    no_ident_input = ~s{
   let = 5;
    }
    just_value_input = ~s{
   let 5;
    }
    inputs = [no_equal_input, no_ident_input, just_value_input]

    Enum.each(inputs, fn input ->
      lexer = %Lexer{input: input}
      parser = %Parser{lexer: lexer}
      initialized_parser = Parser.advance_token(parser)
      assert_raise MatchError, fn -> Parser.parse(initialized_parser) end
    end)
  end

  test "return statements work correctly" do
    input = ~s{
   return x;
   return 10;
   return "res";
    }

    lexer = %Lexer{input: input}
    parser = %Parser{lexer: lexer}
    initialized_parser = Parser.advance_token(parser)
    %Parser{statements: statements} = Parser.parse(initialized_parser)

    assert(length(statements) == 3)

    statements
    |> Enum.each(fn el ->
      assert(el.token == :return)
    end)
  end

  test "expressions work" do
    input = ~s{
      var_name;
      15;
    }

    lexer = %Lexer{input: input}
    parser = %Parser{lexer: lexer}
    initialized_parser = Parser.advance_token(parser)
    %Parser{statements: [first_statement, second_statement]} = Parser.parse(initialized_parser)
    assert first_statement == %ExpressionStatement{token: :identifier, value: "var_name"}
    assert second_statement == %ExpressionStatement{token: :number, value: 15}
  end
end
