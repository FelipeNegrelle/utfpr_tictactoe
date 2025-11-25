defmodule Rule do
  def check_winner(board) do
    winning_combinations = [
      [1, 2, 3, 4],
      [5, 6, 7, 8],
      [9, 10, 11, 12],
      [13, 14, 15, 16],
      [1, 5, 9, 13],
      [2, 6, 10, 14],
      [3, 7, 11, 15],
      [4, 8, 12, 16],
      [1, 6, 11, 16],
      [4, 7, 10, 13]
    ]

    Enum.find_value(winning_combinations, :no_winner, fn positions ->
      check_line_winner(board, positions)
    end)
  end

  defp board_full?(board) do
    1..16
    |> Enum.all?(fn position ->
      case Board.get_cell(board, position) do
        {:ok, " "} -> false
        {:ok, _symbol} -> true
        {:error, _} -> false
      end
    end)
  end

  def draw?(board) do
    case check_winner(board) do
      :no_winner -> board_full?(board)
      _ -> false
    end
  end

  def game_over?(board) do
    case check_winner(board) do
      :no_winner -> draw?(board)
      _ -> true
    end
  end

  defp check_line_winner(board, positions) do
    symbols =
      Enum.map(positions, fn pos ->
        case Board.get_cell(board, pos) do
          {:ok, symbol} when symbol != " " -> symbol
          _ -> nil
        end
      end)

    case symbols do
      [symbol, symbol, symbol, symbol] when symbol != nil -> {:winner, symbol}
      _ -> nil
    end
  end

  def valid_position?(position) do
    position >= 1 and position <= 16
  end

  def can_steal?(current_symbol, last_steal_by_player) do
    last_steal_by_player != current_symbol
  end
end
