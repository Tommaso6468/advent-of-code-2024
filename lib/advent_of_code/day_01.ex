defmodule AdventOfCode.Day01 do
  def part1(_args) do
    {left, right} = parse_input()

    sorted_left = Enum.sort(left)
    sorted_right = Enum.sort(right)

    Enum.zip(sorted_left, sorted_right)
    |> Enum.map(fn {l, r} -> abs(l - r) end)
    |> Enum.sum()

  end

  def part2(_args) do
    {left, right} = parse_input()

    frequencies = Enum.frequencies(right)

    Enum.reduce(left, 0, fn num, acc ->
      count = Map.get(frequencies, num, 0)
      acc + (num * count)
    end)
  end

  defp parse_input() do
    input = AdventOfCode.Input.get!(1, 2024)
    |> String.split("\n", trim: true)
    |> Enum.reduce({[], []}, fn line, {left, right} ->
      [l, r] = String.split(line) |> Enum.map(&String.to_integer/1)
      {[l | left], [r | right]}
    end)
  end
end
