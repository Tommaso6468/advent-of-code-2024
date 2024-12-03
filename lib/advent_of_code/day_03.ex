defmodule AdventOfCode.Day03 do
  def part1(_args) do
    regex = ~r/mul\((\d{1,3}),(\d{1,3})\)/

    Regex.scan(regex, AdventOfCode.Input.get!(3, 2024))
    |> Enum.map(fn [_, x_str, y_str] ->
      x = String.to_integer(x_str)
      y = String.to_integer(y_str)
      x * y
    end)
    |> Enum.sum()
  end

  def part2(_args) do
    mul_regex = ~r/mul\((\d{1,3}),(\d{1,3})\)/
    do_regex = ~r/do\(\)/
    dont_regex = ~r/don't\(\)/

    input = AdventOfCode.Input.get!(3, 2024)

    # mul()
    mul_matches_positions = Regex.scan(mul_regex, input, return: :index)
    mul_matches = Regex.scan(mul_regex, input)

    mul_instructions = Enum.zip(mul_matches_positions, mul_matches)
    |> Enum.map(fn {positions, match} ->
      [{offset, length} | _rest] = positions
      [_, x_str, y_str] = match
      x = String.to_integer(x_str)
      y = String.to_integer(y_str)
      %{
        type: :mul,
        start_pos: offset,
        end_pos: offset + length,
        x: x,
        y: y
      }
    end)

    # do()
    do_matches_positions = Regex.scan(do_regex, input, return: :index)
    do_instructions = Enum.map(do_matches_positions, fn [{offset, length}] ->
      %{
        type: :do,
        start_pos: offset,
        end_pos: offset + length
      }
    end)

    # don't()
    dont_matches_positions = Regex.scan(dont_regex, input, return: :index)
    dont_instructions = Enum.map(dont_matches_positions, fn [{offset, length}] ->
      %{
        type: :dont,
        start_pos: offset,
        end_pos: offset + length
      }
    end)

    instructions = mul_instructions ++ do_instructions ++ dont_instructions

    sorted_instructions = Enum.sort_by(instructions, &(&1.start_pos))

    {total_sum, _enabled} = Enum.reduce(sorted_instructions, {0, true}, fn instr, {acc_sum, enabled} ->
      case instr.type do
        :do ->
          {acc_sum, true}
        :dont ->
          {acc_sum, false}
        :mul ->
          if enabled do
            {acc_sum + (instr.x * instr.y), enabled}
          else
            {acc_sum, enabled}
          end
      end
    end)

    total_sum
  end
end
