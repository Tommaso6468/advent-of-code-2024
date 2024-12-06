defmodule AdventOfCode.Day06 do
  @max_steps 2_000_000 # large but finite step limit

  def part1(_args) do
    input = AdventOfCode.Input.get!(6, 2024)
    grid = parse_input(input)
    {start_r, start_c, dir} = find_guard(grid)
    {status, visited} = simulate(grid, start_r, start_c, dir)
    MapSet.size(visited)
  end

  def part2(_args) do
    input = AdventOfCode.Input.get!(6, 2024)
    orig_grid = parse_input(input)
    {start_r, start_c, dir} = find_guard(orig_grid)
    {status, visited} = simulate(orig_grid, start_r, start_c, dir)

    candidates =
      visited
      |> Enum.filter(fn {r,c} ->
        (r != start_r or c != start_c) and Enum.at(Enum.at(orig_grid, r), c) == "."
      end)

    count =
      Enum.reduce(candidates, 0, fn {r, c}, acc ->
        new_grid = put_in_grid(orig_grid, r, c, "#")
        {st, _vis} = simulate(new_grid, start_r, start_c, dir)
        if st == :loop, do: acc + 1, else: acc
      end)

    count
  end

  defp parse_input(input) do
    input
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
  end

  defp find_guard(grid) do
    dirs = %{"^"=>:up, "v"=>:down, "<"=>:left, ">"=>:right}
    for {row, r_idx} <- Enum.with_index(grid),
        {cell, c_idx} <- Enum.with_index(row),
        Map.has_key?(dirs, cell) do
      {r_idx, c_idx, dirs[cell]}
    end
    |> hd()
  end

  defp simulate(grid, r, c, d) do
    do_sim(grid, r, c, d, MapSet.new(), MapSet.new(), 0)
  end

  defp do_sim(grid, r, c, d, visited, states, steps) do
    if steps > @max_steps do
      {:loop, visited}
    else
      visited = MapSet.put(visited, {r,c})
      st = {r,c,d}
      if MapSet.member?(states, st) do
        {:loop, visited}
      else
        states = MapSet.put(states, st)
        case next_step(grid, r, c, d) do
          :done -> {:done, visited}
          {:ok, nr, nc, nd} -> do_sim(grid, nr, nc, nd, visited, states, steps + 1)
        end
      end
    end
  end

  defp next_step(grid, r, c, d) do
    {dr, dc} = delta(d)
    nr = r+dr
    nc = c+dc
    cond do
      out_of_bounds?(grid, nr, nc) -> :done
      blocked?(grid, nr, nc) -> {:ok, r, c, turn_right(d)}
      true -> {:ok, nr, nc, d}
    end
  end

  defp blocked?(grid, r, c), do: Enum.at(Enum.at(grid, r), c) == "#"
  defp out_of_bounds?(grid, r, c), do: r<0 or c<0 or r>=length(grid) or c>=length(List.first(grid))

  defp turn_right(:up), do: :right
  defp turn_right(:right), do: :down
  defp turn_right(:down), do: :left
  defp turn_right(:left), do: :up

  defp delta(:up), do: {-1,0}
  defp delta(:down), do: {1,0}
  defp delta(:left), do: {0,-1}
  defp delta(:right), do: {0,1}

  defp put_in_grid(grid, r, c, val) do
    row = Enum.at(grid, r)
    updated_row = List.replace_at(row, c, val)
    List.replace_at(grid, r, updated_row)
  end
end
