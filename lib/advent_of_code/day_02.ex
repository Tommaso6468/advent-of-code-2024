defmodule AdventOfCode.Day02 do
  def part1(_args) do
    reports = parse_input()
    Enum.count(reports, &is_safe_report?/1)
  end

  def part2(_args) do
    reports = parse_input()

    Enum.count(reports, fn report ->
      if is_safe_report?(report) do
        true
      else
        report_length = length(report)

        Enum.any?(0..(report_length - 1), fn idx ->
          List.delete_at(report, idx)
          |> is_safe_report?()
        end)
      end
    end)
  end


  defp parse_input() do
    AdventOfCode.Input.get!(2,2024)
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split()
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp is_safe_report?(levels) do
    if length(levels) < 2 do
      false
    else
      differences =
        Enum.zip(levels, tl(levels))
        |> Enum.map(fn {a, b} -> b - a end)

      differences_valid =
        Enum.all?(differences, fn diff ->
          abs(diff) >= 1 and abs(diff) <= 3
        end)

      if differences_valid do
        increasing = Enum.all?(differences, &(&1 > 0))
        decreasing = Enum.all?(differences, &(&1 < 0))
        increasing or decreasing
      else
        false
      end
    end
  end
end
