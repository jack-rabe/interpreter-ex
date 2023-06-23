defmodule Parser do
  defstruct [:lexer, :cur_token, :next_token, statements: []]

  # operator precedence levels
  @lowest 1
  @equals 2
  @sum 3
  @less_greater 4
  @product 5
  @prefix 6
  @call 7

  defmodule LetStatement do
    defstruct [:token, :name, :value]
  end

  defmodule ReturnStatement do
    defstruct [:token, :value]
  end

  defmodule ExpressionStatement do
    defstruct [:token, :value]
  end

  defmodule OperatorExpressionStatement do
    defstruct [:left, :operator, :right]
  end

  def parse(parser = %Parser{next_token: next_token}) do
    case next_token do
      nil ->
        parser

      _ ->
        advanced_parser = parse_statement(parser)

        advance_token(advanced_parser)
        |> parse()
    end
  end

  @spec parse_statement(%Parser{}) :: term
  def parse_statement(parser = %Parser{}) do
    case parser.cur_token do
      :let ->
        parse_let_statement(parser)

      :return ->
        parse_return_statement(parser)

      _expression ->
        parse_expression(parser, @lowest)
    end
  end

  @spec parse_expression(%Parser{}, integer) :: %Parser{}
  def parse_expression(%{cur_token: cur_token} = parser = %Parser{}, _precedence_level) do
    cond do
      is_binary(cur_token) ->
        find_semicolon(parser)
        |> put_statement(%ExpressionStatement{token: :identifier, value: cur_token})

      is_integer(cur_token) ->
        find_semicolon(parser)
        |> put_statement(%ExpressionStatement{token: :number, value: cur_token})

      # infix operators
      cur_token in [:bang, :minus] ->
        # TODO find semicolon
        advanced_parser = advance_token(parser)

        final_parser = parse_expression(advanced_parser, @lowest)
        next_expression = List.last(final_parser.statements)

        # we want to ignore intermediate statements that are generated and only append one
        %Parser{
          lexer: final_parser.lexer,
          cur_token: final_parser.cur_token,
          next_token: final_parser.next_token,
          statements:
            parser.statements ++
              [%OperatorExpressionStatement{operator: cur_token, right: next_expression}]
        }
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

  @spec parse_return_statement(%Parser{}) :: %Parser{}
  defp parse_return_statement(parser = %Parser{}) do
    find_semicolon(parser)
    |> put_statement(%ReturnStatement{token: :return})
  end

  @spec put_statement(%Parser{}, term) :: %Parser{}
  def put_statement(parser = %Parser{}, statement) do
    %Parser{
      statements: parser.statements ++ [statement],
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
