defmodule LexerTest do
  use ExUnit.Case
  doctest Lexer

  test "tests that the correct tokens are returned" do
    lexer = %Lexer{input: "=,+(){}"}
    tokens = Lexer.parse(lexer)

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

  test "tests that the correct tokens are returned (includes identifiers)" do
    lexer = %Lexer{input: ~s[let five = 5;
    let ten = 10;
    let add = fn(x, y){
      x + y;
    };
    let result = add(five, ten);
    ]}
    tokens = Lexer.parse(lexer)

    assert tokens ==
             [
               :let,
               "five",
               :assign,
               "5",
               :semicolon,
               :let,
               "ten",
               :assign,
               "10",
               :semicolon,
               :let,
               "add",
               :assign,
               :function,
               :left_paren,
               "x",
               :comma,
               "y",
               :right_paren,
               :left_brace,
               "x",
               :plus,
               "y",
               :semicolon,
               :right_brace,
               :semicolon,
               :let,
               "result",
               :assign,
               "add",
               :left_paren,
               "five",
               :comma,
               "ten",
               :right_paren,
               :semicolon
             ]
  end
end
