defmodule Interpreter do
  def start do
    IO.puts("Welcome to the Monkey REPL!")
    handle_input()
  end

  defp handle_input do
    input = IO.gets(">> ")
    tokens = Lexer.lex(IO.chardata_to_string(input))
    IO.inspect(tokens)
    handle_input()
  end
end
