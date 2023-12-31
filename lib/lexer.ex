defmodule Lexer do
  defstruct [:input, position: 0, read_position: 0]

  @keywords %{
    "fn" => :function,
    "let" => :let,
    "return" => :return,
    "true" => true,
    "false" => false,
    "if" => :if,
    "else" => :else
  }

  @type token :: atom | integer | String.t()

  @spec next_char(%Lexer{}) :: %{char: String.t() | nil, lexer: %Lexer{}}
  defp next_char(initial = %Lexer{}) do
    char =
      if initial.read_position >= String.length(initial.input) do
        nil
      else
        String.at(initial.input, initial.read_position)
      end

    %{
      char: char,
      lexer: %Lexer{
        input: initial.input,
        position: initial.read_position,
        read_position: initial.read_position + 1
      }
    }
  end

  @spec read_identifier(%Lexer{}) :: {%Lexer{}, String.t()}
  defp read_identifier(initial = %Lexer{}) do
    %{char: char, lexer: advanced_lexer} = next_char(initial)

    if(is_letter(char)) do
      {next_lexer, str} = read_identifier(advanced_lexer)
      {next_lexer, char <> str}
    else
      {initial, ""}
    end
  end

  def is_letter(nil) do
    false
  end

  def is_letter(num) when is_integer(num) do
    false
  end

  @spec is_letter(String.t()) :: boolean
  def is_letter(c) do
    [c | _] = String.to_charlist(c)
    (?a <= c and c <= ?z) or (?A <= c and c <= ?Z) or c == ?_
  end

  def _is_number(c) do
    Regex.match?(~r/\d+/, c)
  end

  defp read_number(input = %Lexer{}) do
    %{char: char, lexer: advanced_lexer} = next_char(input)

    if(_is_number(char)) do
      {next_lexer, str} = read_number(advanced_lexer)
      {next_lexer, char <> str}
    else
      {input, ""}
    end
  end

  @spec skip_whitespace(%Lexer{}) :: %Lexer{}
  defp skip_whitespace(input = %Lexer{}) do
    %{char: c, lexer: advanced_lexer} = next_char(input)

    if not is_nil(c) and Regex.match?(~r(\s), c) do
      skip_whitespace(advanced_lexer)
    else
      input
    end
  end

  @spec next_token(%Lexer{}) :: {%Lexer{}, any()}
  def next_token(input = %Lexer{}) do
    no_whitespace_lexer = skip_whitespace(input)
    %{char: c, lexer: advanced_lexer} = next_char(no_whitespace_lexer)

    {token, final_lexer} =
      case c do
        "=" ->
          %{char: c, lexer: lex} = next_char(advanced_lexer)

          if c == "=" do
            {:equal, lex}
          else
            {:assign, advanced_lexer}
          end

        ";" ->
          {:semicolon, advanced_lexer}

        "(" ->
          {:left_paren, advanced_lexer}

        ")" ->
          {:right_paren, advanced_lexer}

        "," ->
          {:comma, advanced_lexer}

        "+" ->
          {:plus, advanced_lexer}

        "-" ->
          {:minus, advanced_lexer}

        "*" ->
          {:asterisk, advanced_lexer}

        "!" ->
          %{char: c, lexer: lex} = next_char(advanced_lexer)

          if c == "=" do
            {:not_equal, lex}
          else
            {:bang, advanced_lexer}
          end

        "/" ->
          {:slash, advanced_lexer}

        ">" ->
          {:gt, advanced_lexer}

        "<" ->
          {:lt, advanced_lexer}

        "{" ->
          {:left_brace, advanced_lexer}

        "}" ->
          {:right_brace, advanced_lexer}

        nil ->
          {nil, advanced_lexer}

        ident ->
          cond do
            is_letter(c) ->
              {full_word_lexer, str} = read_identifier(advanced_lexer)
              word = ident <> str

              if word in Map.keys(@keywords) do
                {Map.get(@keywords, word), full_word_lexer}
              else
                {word, full_word_lexer}
              end

            _is_number(c) ->
              {full_num_lexer, rest_of_num} = read_number(advanced_lexer)
              number = String.to_integer(ident <> rest_of_num)
              {number, full_num_lexer}

            true ->
              {:illegal, advanced_lexer}
          end
      end

    {final_lexer, token}
  end

  @spec lex(String.t()) :: %Lexer{} | list(token)
  def lex(input) when is_binary(input) do
    lexer = %Lexer{input: input}
    lex(lexer, [])
  end

  @spec lex(%Lexer{}, list(token)) :: %Lexer{} | list(token)
  def lex(lexer = %Lexer{}, tokens) do
    {lexer, token} = next_token(lexer)

    if is_nil(token) do
      Enum.reverse(tokens)
    else
      lex(lexer, [token | tokens])
    end
  end
end
