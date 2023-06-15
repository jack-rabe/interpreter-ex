defmodule Interpreter do
  def start do
    IO.puts("Welcome to the Monkey REPL!")
    handle_input()
  end

  defp handle_input do
    input = IO.gets(">> ")
    tokens = Lexer.parse(input)
    IO.inspect(tokens)
    handle_input()
  end
end
