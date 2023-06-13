defmodule LexerTest do
  use ExUnit.Case
  doctest Lexer

  test "tests that the correct tokens are returned" do
    lexer = %Lexer{input: "=,+(){}"}
    tokens = Lexer.parse(lexer)
    IO.inspect(tokens)

    assert tokens == [
             :assign,
             :comma,
             :plus,
             :left_paren,
             :right_paren,
             :left_brace,
             :right_brace
           ]
  end
end
