defmodule AdventOfCode.Day04 do
  def part1(_args) do
    grid = parse_input()
    word = "XMAS"

    rows = length(grid)
    cols = length(List.first(grid))
    directions = [
      {0, 1},    # right
      {1, 0},    # down
      {1, 1},    # down right
      {-1, 0},   # up
      {0, -1},   # left
      {-1, -1},  # up left
      {-1, 1},   # up right
      {1, -1},   # down left
    ]

    Enum.reduce(0..(rows - 1), 0, fn row, acc ->
      Enum.reduce(0..(cols - 1), acc, fn col, acc_inner ->
        acc_inner + count_from_cell(grid, row, col, word, directions)
      end)
    end)
  end

  def part2(_args) do
    grid = parse_input()
    rows = length(grid)
    cols = length(List.first(grid))

    positions_with_a =
      for row <- 1..(rows - 2),
          col <- 1..(cols - 2),
          get_cell(grid, row, col) == "A",
          do: {row, col}

    Enum.reduce(positions_with_a, 0, fn {row, col}, acc ->
      if is_xmas_at(grid, row, col) do
        acc + 1
      else
        acc
      end
    end)
  end

  defp parse_input() do
    AdventOfCode.Input.get!(4, 2024)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  defp is_xmas_at(grid, row, col) do
    main_diag = [
      get_cell(grid, row - 1, col - 1),
      get_cell(grid, row, col),
      get_cell(grid, row + 1, col + 1)
    ]

    anti_diag = [
      get_cell(grid, row - 1, col + 1),
      get_cell(grid, row, col),
      get_cell(grid, row + 1, col - 1)
    ]

    mas_sequences = [["M", "A", "S"], ["S", "A", "M"]]

    Enum.member?(mas_sequences, main_diag) and Enum.member?(mas_sequences, anti_diag)
  end

  defp get_cell(grid, row, col) do
    grid
    |> Enum.at(row)
    |> Enum.at(col)
  end

  defp count_from_cell(grid, row, col, word, directions) do
    Enum.reduce(directions, 0, fn {dx, dy}, acc ->
      if check_direction(grid, row, col, word, dx, dy) do
        acc + 1
      else
        acc
      end
    end)
  end

  defp check_direction(grid, row, col, word, dx, dy) do
    word_chars = String.graphemes(word)
    check_direction_recursive(grid, row, col, word_chars, dx, dy)
  end

  defp check_direction_recursive(_grid, _row, _col, [], _dx, _dy), do: true

  defp check_direction_recursive(grid, row, col, [char | rest], dx, dy) do
    if in_bounds?(grid, row, col) and Enum.at(Enum.at(grid, row), col) == char do
      check_direction_recursive(grid, row + dx, col + dy, rest, dx, dy)
    else
      false
    end
  end

  defp in_bounds?(grid, row, col) do
    row >= 0 and row < length(grid) and col >= 0 and col < length(List.first(grid))
  end
end
