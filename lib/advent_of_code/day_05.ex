defmodule AdventOfCode.Day05 do
  def part1(_args) do
    {ordering_rules, updates} = parse_input()

    total_sum =
      updates
      |> Enum.reduce(0, fn update, acc ->
        if correctly_ordered?(update, ordering_rules) do
          acc + find_middle_page(update)
        else
          acc
        end
      end)

    total_sum
  end

  def part2(_args) do
    {ordering_rules, updates} = parse_input()

    total_sum =
      updates
      |> Enum.reduce(0, fn update, acc ->
        if correctly_ordered?(update, ordering_rules) do
          acc
        else
          acc + find_middle_page(reorder_update(update, ordering_rules))
        end
      end)
  end

  defp reorder_update(update, ordering_rules) do
    pages = MapSet.new(update)

    {graph, in_degrees} =
      Enum.reduce(pages, {%{}, %{}}, fn page, {g, indeg} ->
        {Map.put(g, page, []), Map.put(indeg, page, 0)}
      end)

    {graph, in_degrees} =
      Enum.reduce(ordering_rules, {graph, in_degrees}, fn {x, y}, {g, indeg} ->
        if x in pages and y in pages do
          g = Map.update!(g, x, &[y | &1])
          indeg = Map.update!(indeg, y, &(&1 + 1))
          {g, indeg}
        else
          {g, indeg}
        end
      end)

    topo_sort(graph, in_degrees)
  end

  defp topo_sort(graph, in_degrees) do
    queue = for {node, 0} <- in_degrees, do: node
    topo_sort(queue, graph, in_degrees, [])
  end

  defp topo_sort([], _graph, _in_degrees, sorted), do: Enum.reverse(sorted)

  defp topo_sort([node | rest], graph, in_degrees, sorted) do
    neighbors = Map.get(graph, node, [])
    {in_degrees, new_nodes} =
      Enum.reduce(neighbors, {in_degrees, []}, fn neighbor, {indeg, nodes} ->
        indeg = Map.update!(indeg, neighbor, &(&1 - 1))
        if indeg[neighbor] == 0, do: {indeg, [neighbor | nodes]}, else: {indeg, nodes}
      end)
    topo_sort(rest ++ Enum.reverse(new_nodes), graph, in_degrees, [node | sorted])
  end

  defp parse_input() do
    [rules_section, updates_section] =
      AdventOfCode.Input.get!(5, 2024)
      |> String.trim()
      |> String.split("\n\n", parts: 2)

    ordering_rules =
      rules_section
      |> String.split()
      |> Enum.map(fn line ->
        [x_str, y_str] = String.split(line, "|")
        {String.to_integer(x_str), String.to_integer(y_str)}
      end)

    updates =
      updates_section
      |> String.split("\n")
      |> Enum.map(fn line ->
        line
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
      end)

    {ordering_rules, updates}
  end

  defp correctly_ordered?(update, ordering_rules) do
    update_pages = MapSet.new(update)
    page_indices = Enum.with_index(update) |> Enum.into(%{})

    relevant_rules =
      Enum.filter(ordering_rules, fn {x, y} ->
        MapSet.member?(update_pages, x) and MapSet.member?(update_pages, y)
      end)

    Enum.all?(relevant_rules, fn {x, y} ->
      page_indices[x] < page_indices[y]
    end)
  end

  defp find_middle_page(update) do
    Enum.at(update, div(length(update), 2))
  end
end
