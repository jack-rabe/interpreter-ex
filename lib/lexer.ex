defmodule Lexer do
  defstruct [:input, tokens: [], position: 0, read_position: 0]

  def next_char(lexer = %Lexer{}) do
    char =
      if lexer.read_position >= String.length(lexer.input) do
        nil
      else
        String.at(lexer.input, lexer.read_position)
      end

    %{
      char: char,
      lexer: %Lexer{
        input: lexer.input,
        tokens: lexer.tokens,
        position: lexer.read_position,
        read_position: lexer.read_position + 1
      }
    }
  end

  def next_token(lexer = %Lexer{}) do
    %{char: c, lexer: l} = next_char(lexer)

    token =
      case c do
        "=" ->
          :assign

        ";" ->
          :semicolon

        "(" ->
          :left_paren

        ")" ->
          :right_paren

        "," ->
          :comma

        "+" ->
          :plus

        "{" ->
          :left_brace

        "}" ->
          :right_brace

        nil ->
          nil
      end

    %Lexer{
      input: l.input,
      tokens: [token | l.tokens],
      position: l.position,
      read_position: l.read_position
    }
  end

  def parse(lexer = %Lexer{}) do
    l = next_token(lexer)
    [last_token | _] = l.tokens

    if is_nil(last_token) do
      {nil, tokens} = List.pop_at(l.tokens, 0)
      Enum.reverse(tokens)
    else
      parse(l)
    end
  end
end
