defmodule Game do
  defstruct [:board, :players, :current_player_index, :game_state, :previous_steal, :turn_count]

  def new() do
    players = Player.setup_players()

    %Game{
      board: Board.new(),
      players: [players.player1, players.player2, players.player3],
      current_player_index: 0,
      game_state: :playing,
      previous_steal: %{},
      turn_count: 1
    }
  end

  def new_with_players(players) do
    %Game{
      board: Board.new(),
      players: players,
      current_player_index: 0,
      game_state: :playing,
      previous_steal: %{},
      turn_count: 1
    }
  end

  def current_player(%Game{players: players, current_player_index: index}) do
    Enum.at(players, index)
  end

  def make_move(%Game{board: board, game_state: :playing} = game, position) do
    player = current_player(game)

    case can_make_move?(game, player.symbol, position) do
      {:ok, :valid_move} ->
        execute_move(game, player.symbol, position, :normal)

      {:ok, :steal_move} ->
        {:ok, current_symbol} = Board.get_cell(board, position)
        execute_move(game, player.symbol, position, {:steal, current_symbol})

      {:error, reason} ->
        {:error, reason}
    end
  end

  def make_move(%Game{game_state: _} = _game, _position) do
    {:error, :game_over}
  end

  defp execute_move(game, symbol, position, move_type) do
    case Board.place_piece(game.board, symbol, position) do
      {:ok, new_board} ->
        new_game = update_game_after_move(game, new_board, symbol, move_type)
        check_game_end(new_game)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp update_game_after_move(%Game{} = game, new_board, symbol, move_type) do
    new_previous_steal =
      case move_type do
        :normal ->
          Map.put(game.previous_steal, symbol, nil)

        {:steal, stolen_symbol} ->
          Map.put(game.previous_steal, symbol, stolen_symbol)
      end

    %Game{
      game
      | board: new_board,
        current_player_index: next_player_index(game),
        previous_steal: new_previous_steal,
        turn_count: game.turn_count + 1
    }
  end

  defp can_make_move?(%Game{board: board, previous_steal: previous_steal}, symbol, position) do
    unless Rule.valid_position?(position) do
      {:error, :invalid_position}
    else
      case Board.get_cell(board, position) do
        {:ok, " "} ->
          {:ok, :valid_move}

        {:ok, current_symbol} when current_symbol == symbol ->
          {:ok, :valid_move}

        {:ok, current_symbol} ->
          last_steal_by_player = Map.get(previous_steal, symbol)

          if Rule.can_steal?(current_symbol, last_steal_by_player) do
            {:ok, :steal_move}
          else
            {:error, :cannot_steal_back_immediately}
          end

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  defp next_player_index(%Game{players: players, current_player_index: current_index}) do
    rem(current_index + 1, length(players))
  end

  defp check_game_end(%Game{board: board} = game) do
    cond do
      Rule.game_over?(board) ->
        case Rule.check_winner(board) do
          {:winner, symbol} ->
            {:ok, %Game{game | game_state: {:winner, symbol}}}

          :no_winner ->
            {:ok, %Game{game | game_state: :draw}}
        end

      true ->
        {:ok, game}
    end
  end

  def display_board(%Game{board: board}) do
    Board.display_board(board)
  end

  def restart(%Game{players: players}) do
    new_with_players(players)
  end

  def main(_args) do
    IO.puts("This is UTFPR Tic-Tac-Toe!")
    IO.puts("Rules:")
    IO.puts("- 3 players take turns: x, o, +")
    IO.puts("- You can steal opponent pieces by playing on their position")
    IO.puts("- You cannot immediately steal back the piece that was just stolen from you")
    IO.puts("- Win by getting 4 in a row (horizontal, vertical or diagonal)")
    IO.puts("- 4x4 board with positions (1,1) to (4,4)\n")

    game = new()

    IO.puts("\nPlayers:")

    Enum.with_index(game.players, 1)
    |> Enum.each(fn {player, index} ->
      IO.puts("Player #{index}: #{player.symbol}")
    end)

    IO.puts("")
    game_loop(game)
  end

  defp game_loop(%Game{game_state: :playing} = game) do
    player = current_player(game)

    IO.puts("=== Turn #{game.turn_count} ===")
    IO.puts("Current board:")
    IO.puts(display_board(game))

    display_steal_info(game, player)

    IO.puts("Player #{player.symbol}, choose your position!")
    {line, column} = get_position_from_input()

    if line in 1..4 and column in 1..4 do
      position = (line - 1) * 4 + column

      case make_move(game, position) do
        {:ok, new_game} ->
          display_move_result(game, new_game, player, {line, column})
          game_loop(new_game)

        {:error, reason} ->
          display_error(reason)
          game_loop(game)
      end
    else
      IO.puts("Invalid position! Use coordinates between (1,1) and (4,4)")
      game_loop(game)
    end
  end

  defp game_loop(%Game{game_state: {:winner, symbol}} = game) do
    IO.puts("=== GAME OVER ===")
    IO.puts("Final board:")
    IO.puts(display_board(game))
    IO.puts("Player #{symbol} WINS!")

    ask_for_rematch(game)
  end

  defp game_loop(%Game{game_state: :draw} = game) do
    IO.puts("=== GAME OVER ===")
    IO.puts("Final board:")
    IO.puts(display_board(game))
    IO.puts("It's a DRAW!")

    ask_for_rematch(game)
  end

  defp display_steal_info(%Game{previous_steal: previous_steal}, current_player) do
    last_stolen = Map.get(previous_steal, current_player.symbol)

    if last_stolen && last_stolen != nil do
      IO.puts("Revenge rule: You cannot steal back #{last_stolen} immediately!")
    end
  end

  defp display_move_result(old_game, _new_game, player, {line, column}) do
    position = (line - 1) * 4 + column

    case Board.get_cell(old_game.board, position) do
      {:ok, " "} ->
        IO.puts("Player #{player.symbol} placed piece at (#{line},#{column})")

      {:ok, stolen_symbol} when stolen_symbol != player.symbol ->
        IO.puts(
          "Player #{player.symbol} STOLE #{stolen_symbol}'s piece at (#{line},#{column})! Revenge!"
        )

      {:ok, _} ->
        IO.puts("Player #{player.symbol} reinforced position (#{line},#{column})")
    end

    IO.puts("")
  end

  defp display_error(reason) do
    case reason do
      :invalid_position ->
        IO.puts("Invalid position!")

      :cannot_steal_back_immediately ->
        IO.puts("Revenge rule violation! You cannot steal back immediately!")

      :game_over ->
        IO.puts("Game is already over!")

      other ->
        IO.puts("Error: #{other}")
    end

    IO.puts("")
  end

  defp get_position_from_input() do
    x = IO.gets("Enter row: ") |> String.trim() |> String.to_integer()
    y = IO.gets("Enter column: ") |> String.trim() |> String.to_integer()

    {x, y}
  end

  defp ask_for_rematch(game) do
    IO.puts("\nWould you like to play again? (y/n): ")

    case IO.gets("") |> String.trim() |> String.downcase() do
      "y" ->
        IO.puts("\n" <> String.duplicate("=", 50))
        IO.puts("Starting new game with same players!")
        IO.puts(String.duplicate("=", 50) <> "\n")

        new_game = restart(game)
        game_loop(new_game)

      "n" ->
        IO.puts("Thanks for playing UTFPR Tic-Tac-Toe!")

      _ ->
        IO.puts("Please enter 'y' for yes or 'n' for no.")
        ask_for_rematch(game)
    end
  end
end
