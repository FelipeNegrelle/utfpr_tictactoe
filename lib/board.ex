defmodule Board do
  defstruct cells: []

  def new() do
    %Board{
      cells: [
        " ",
        " ",
        " ",
        " ",
        " ",
        " ",
        " ",
        " ",
        " ",
        " ",
        " ",
        " ",
        " ",
        " ",
        " ",
        " "
      ]
    }
  end

  def place_piece(%Board{cells: cells} = board, symbol, position) do
    # board starts in 1 but the array in 0
    idx = position - 1

    if valid_position?(idx) and in_bounds?(idx, cells) do
      {:ok, %Board{board | cells: List.replace_at(cells, idx, symbol)}}
    else
      {:error, :invalid_position}
    end
  end

  def get_cell(%Board{cells: cells}, position) do
    idx = position - 1

    if valid_position?(idx) and in_bounds?(idx, cells) do
      {:ok, Enum.at(cells, idx)}
    else
      {:error, :invalid_position}
    end
  end

  def empty_cell?(%Board{cells: cells}, position) do
    get_cell(%Board{cells: cells}, position) === {:ok, " "}
  end

  defp valid_position?(idx), do: idx >= 0 and idx < 16

  defp in_bounds?(idx, cells), do: idx < length(cells)

  defp convert_symbol_to_string(cell) do
    case cell do
      " " -> " "
      symbol -> Atom.to_string(symbol)
    end
  end

  def line_between(row_num) do
    if row_num < 4 do
      "\n ├───┼───┼───┼───┤"
    else
      "\n"
    end
  end

  def display_inside_cells(data) do
    data
    |> Enum.map(fn {row, row_num} ->
      row_display =
        row
        |> Enum.map(&convert_symbol_to_string/1)
        |> Enum.join(" │ ")

      "#{row_num}│ #{row_display} │" <> line_between(row_num)
    end)
    |> Enum.join("\n")
  end

  def generate_inside_cells(cells) do
    cells
    |> Enum.chunk_every(4)
    |> Enum.with_index(1)
    |> display_inside_cells()
  end

  def display_board(%Board{cells: cells}) do
    result = ""

    result = result <> "   1   2   3   4\n"
    result = result <> " ┌───┬───┬───┬───┐\n"
    result = result <> generate_inside_cells(cells)
    result = result <> " └───┴───┴───┴───┘\n"

    result
  end
end
