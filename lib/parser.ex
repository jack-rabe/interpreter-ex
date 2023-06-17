defmodule Parser do
  defstruct [:lexer, :cur_token, :next_token, statements: []]

  defmodule LetStatement do
    defstruct [:token, :name, :value]
  end

  # @spec parse(%Parser{}) :: list(%put_statement{})
  def parse(parser = %Parser{next_token: nil}) do
    parser
  end

  def parse(parser = %Parser{}) do
    advanced_parser = parse_statement(parser)

    advance_token(advanced_parser)
    |> parse()
  end

  @spec parse_statement(%Parser{}) :: term
  def parse_statement(parser = %Parser{}) do
    case parser.cur_token do
      :let ->
        parse_let_statement(parser)

      _ ->
        nil
    end
  end

  @spec advance_token(%Parser{}) :: %Parser{}
  def advance_token(parser = %Parser{}) do
    lexer = Lexer.next_token(parser.lexer)
    advanced_lexer = Lexer.next_token(lexer)
    cur_token = List.first(lexer.tokens)
    next_token = List.first(advanced_lexer.tokens)

    %Parser{
      lexer: lexer,
      cur_token: cur_token,
      next_token: next_token,
      statements: parser.statements
    }
  end

  @spec parse_let_statement(%Parser{}) :: %Parser{}
  defp parse_let_statement(parser = %Parser{}) do
    %{cur_token: ident, next_token: :assign} = ident_parser = advance_token(parser)
    assign_parser = advance_token(ident_parser)

    find_semicolon(assign_parser)
    |> put_statement(%LetStatement{token: :let, name: ident})
  end

  @spec put_statement(%Parser{}, term) :: %Parser{}
  def put_statement(parser = %Parser{}, statement) do
    %Parser{
      statements: [statement | parser.statements],
      cur_token: parser.cur_token,
      next_token: parser.next_token,
      lexer: parser.lexer
    }
  end

  @spec find_semicolon(%Parser{}) :: %Parser{}
  def find_semicolon(parser = %Parser{}) do
    next_parser = advance_token(parser)

    if next_parser.cur_token == :semicolon do
      next_parser
    else
      find_semicolon(next_parser)
    end
  end
end
