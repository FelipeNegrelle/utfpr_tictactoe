defmodule BoardTest do
  use ExUnit.Case
  alias Board

  describe "new/0" do
    test "creates a new empty board" do
      board = Board.new()
      assert length(board.cells) == 16
      assert Enum.all?(board.cells, fn cell -> cell == " " end)
    end
  end

  describe "place_piece/3" do
    test "places a piece on an empty cell" do
      board = Board.new()
      {:ok, new_board} = Board.place_piece(board, :x, 1)
      {:ok, cell} = Board.get_cell(new_board, 1)
      assert cell == :x
    end

    test "returns error for invalid position" do
      board = Board.new()
      assert Board.place_piece(board, :x, 0) == {:error, :invalid_position}
      assert Board.place_piece(board, :x, 17) == {:error, :invalid_position}
    end
  end

  describe "get_cell/2" do
    test "gets cell content" do
      board = Board.new()
      {:ok, cell} = Board.get_cell(board, 1)
      assert cell == " "
    end

    test "returns error for invalid position" do
      board = Board.new()
      assert Board.get_cell(board, 0) == {:error, :invalid_position}
      assert Board.get_cell(board, 17) == {:error, :invalid_position}
    end
  end

  describe "display_board/1" do
    test "displays board as string" do
      board = Board.new()
      display = Board.display_board(board)
      assert is_binary(display)
      assert String.contains?(display, "1   2   3   4")
    end
  end
end
