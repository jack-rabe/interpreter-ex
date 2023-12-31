defmodule LexerTest do
  use ExUnit.Case
  doctest Lexer

  test "tests that the correct tokens are returned" do
    input = "%<>==,=!+(){!=}"
    tokens = Lexer.lex(input)

    assert tokens == [
             :illegal,
             :lt,
             :gt,
             :equal,
             :comma,
             :assign,
             :bang,
             :plus,
             :left_paren,
             :right_paren,
             :left_brace,
             :not_equal,
             :right_brace
           ]
  end

  test "tests that the correct tokens are returned (includes identifiers)" do
    input = ~s[let five = 5;
    let ten = 10;
    let add = fn(x, y){
      x + y;
    };
    let result = add(five, ten);
    return 5;
    let val = 3 * 5;
    let bool = true;
    ]
    tokens = Lexer.lex(input)

    assert tokens ==
             [
               :let,
               "five",
               :assign,
               5,
               :semicolon,
               :let,
               "ten",
               :assign,
               10,
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
               :semicolon,
               :return,
               5,
               :semicolon,
               :let,
               "val",
               :assign,
               3,
               :asterisk,
               5,
               :semicolon,
               :let,
               "bool",
               :assign,
               true,
               :semicolon
             ]
  end
end
