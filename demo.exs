#!/usr/bin/env elixir

Code.require_file("lib/board.ex")
Code.require_file("lib/player.ex")
Code.require_file("lib/rule.ex")
Code.require_file("lib/game.ex")

defmodule GameDemo do
  def run do
    IO.puts("=== DEMO: UTFPR Tic-Tac-Toe ===\n")

    players = [
      Player.new(:x, 1),
      Player.new(:o, 2),
      Player.new(:+, 3)
    ]

    game = Game.new_with_players(players)

    IO.puts("Created players:")

    Enum.with_index(players, 1)
    |> Enum.each(fn {player, index} ->
      IO.puts("Player #{index}: #{player.symbol}")
    end)

    IO.puts("\nInitial board:")
    IO.puts(Game.display_board(game))

    moves = [
      {1, 1},
      {1, 2},
      {1, 1},
      {2, 1},
      {1, 1},
      {1, 2}
    ]

    IO.puts("Moving pieces...")

    game = execute_demo_moves(game, moves)

    IO.puts("\nFinal demo board:")
    IO.puts(Game.display_board(game))

    IO.puts("Demo played! To really play the game run: mix run -e \"Game.main([])\"\n")
  end

  defp execute_demo_moves(game, []), do: game

  defp execute_demo_moves(game, [{line, column} | rest]) do
    player = Game.current_player(game)
    position = (line - 1) * 4 + column

    IO.puts("\nTurn #{game.turn_count}: Player #{player.symbol} plays in (#{line},#{column})")

    case Game.make_move(game, position) do
      {:ok, new_game} ->
        IO.puts("Played successfully!")
        IO.puts(Game.display_board(new_game))

        case new_game.game_state do
          :playing ->
            execute_demo_moves(new_game, rest)

          {:winner, winner} ->
            IO.puts("Player #{winner} won!")
            new_game

          :draw ->
            IO.puts("Draw!")
            new_game
        end

      {:error, reason} ->
        IO.puts("Error: #{reason}")
        IO.puts("Going to next move...")
        execute_demo_moves(game, rest)
    end
  end
end

GameDemo.run()
