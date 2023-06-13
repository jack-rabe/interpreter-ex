defmodule Lexer do
  defstruct [:input, tokens: [], position: 0, read_position: 0]
  @keywords %{"fn" => :function, "let" => :let}

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

  def read_identifier(lexer = %Lexer{}) do
    %{char: char, lexer: l} = next_char(lexer)

    if(is_letter(char)) do
      {l, str} = read_identifier(l)
      {l, char <> str}
    else
      {lexer, ""}
    end
  end

  def is_letter(nil) do
    false
  end

  def is_letter(c) do
    [c | _] = String.to_charlist(c)
    (?a <= c and c <= ?z) or (?A <= c and c <= ?Z) or c == ?_
  end

  def _is_number(c) do
    c in ~w{0 1 2 3 4 5 6 7 8 9}
  end

  def read_number(lexer = %Lexer{}) do
    %{char: char, lexer: l} = next_char(lexer)

    if(_is_number(char)) do
      {l, str} = read_number(l)
      {l, char <> str}
    else
      {lexer, ""}
    end
  end

  def skip_whitespace(lexer = %Lexer{}) do
    %{char: c, lexer: l} = next_char(lexer)

    if not is_nil(c) and Regex.match?(~r(\s), c) do
      skip_whitespace(l)
    else
      lexer
    end
  end

  def next_token(lexer = %Lexer{}) do
    lexer = skip_whitespace(lexer)
    %{char: c, lexer: l} = next_char(lexer)

    {token, l} =
      case c do
        "=" ->
          {:assign, l}

        ";" ->
          {:semicolon, l}

        "(" ->
          {:left_paren, l}

        ")" ->
          {:right_paren, l}

        "," ->
          {:comma, l}

        "+" ->
          {:plus, l}

        "{" ->
          {:left_brace, l}

        "}" ->
          {:right_brace, l}

        nil ->
          {nil, l}

        ident ->
          cond do
            is_letter(c) ->
              {l, str} = read_identifier(l)
              word = ident <> str

              if word in Map.keys(@keywords) do
                {Map.get(@keywords, word), l}
              else
                {word, l}
              end

            _is_number(c) ->
              {l, str} = read_number(l)
              {ident <> str, l}

            true ->
              {:illegal, l}
          end
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
