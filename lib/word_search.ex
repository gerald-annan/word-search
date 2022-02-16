defmodule WordSearch do
  defmodule Location do
    defstruct [:from, :to]

    @type t :: %Location{
            from: %{row: integer, column: integer},
            to: %{row: integer, column: integer}
          }
  end

  @doc """
  Find the start and end positions of words in a grid of letters.
  Row and column positions are 1 indexed.
  """
  @spec search(grid :: String.t(), words :: [String.t()]) :: %{String.t() => nil | Location.t()}
  def search(grid, words) do
    flattened_grid_map =
      String.replace(grid, "\n", " ")
      |> String.trim()
      |> String.split(" ")
      |> Enum.with_index(fn element, row -> {row, element} end)
      |> Enum.into(%{})

    Enum.reduce(words, %{}, fn word, search_results ->
      isHorizontal =
        Enum.any?(flattened_grid_map, fn {_, element} ->
          String.contains?(element, word) || String.contains?(element, String.reverse(word))
        end)

      if !isHorizontal do
        vertical =
          Enum.reduce(1..map_size(flattened_grid_map), [], fn pos, arr ->
            arr ++
              [
                Enum.reduce(flattened_grid_map, "", fn {_, element}, acc ->
                  "#{acc}#{String.at(element, pos - 1)}"
                end)
              ]
          end)
          |> Enum.with_index(fn element, row -> {row, element} end)
          |> Enum.into(%{})

        isVertical =
          Enum.any?(vertical, fn {_, element} ->
            String.contains?(element, word) || String.contains?(element, String.reverse(word))
          end)

        if !isVertical do
          Map.put_new(search_results, word, nil)
        else
          [isTopToBottom | [col | [element]]] =
            Enum.reduce(vertical, [false, nil, nil], fn {index, element}, acc ->
              if String.contains?(element, word), do: [true, index + 1, element], else: acc
            end)

          if isTopToBottom do
            distance = String.length(element) - String.length(word)

            Enum.reduce(0..distance, %{}, fn shift, acc ->
              upper_bound = shift + (String.length(word) - 1)

              if String.slice(element, shift..upper_bound) == word do
                Map.put_new(acc, word, %Location{
                  from: %{row: shift + 1, column: col},
                  to: %{row: String.length(word) + shift, column: col}
                })
              else
                acc
              end
            end)
            |> Map.merge(search_results)
          else
            [isBottomToTop | [col | [element]]] =
              Enum.reduce(vertical, [false, nil, nil], fn {index, element}, acc ->
                if String.contains?(element, String.reverse(word)),
                  do: [true, index + 1, element],
                  else: acc
              end)

            if isBottomToTop do
              distance = String.length(element) - String.length(word)

              Enum.reduce(0..distance, %{}, fn shift, acc ->
                upper_bound = shift + (String.length(word) - 1)

                if String.slice(element, shift..upper_bound) == String.reverse(word) do
                  Map.put_new(acc, word, %Location{
                    from: %{row: String.length(word) + shift, column: col},
                    to: %{row: shift + 1, column: col}
                  })
                else
                  acc
                end
              end)
              |> Map.merge(search_results)
            end
          end
        end
      else
        [isLeftToRight | [row | [element]]] =
          Enum.reduce(flattened_grid_map, [false, nil, nil], fn {index, element}, acc ->
            if String.contains?(element, word), do: [true, index + 1, element], else: acc
          end)

        if isLeftToRight do
          distance = String.length(element) - String.length(word)

          Enum.reduce(0..distance, %{}, fn shift, acc ->
            upper_bound = shift + (String.length(word) - 1)

            if String.slice(element, shift..upper_bound) == word do
              Map.put_new(acc, word, %Location{
                from: %{row: row, column: shift + 1},
                to: %{row: row, column: String.length(word) + shift}
              })
            else
              acc
            end
          end)
          |> Map.merge(search_results)
        else
          [isRightToLeft | [row | [element]]] =
            Enum.reduce(flattened_grid_map, [false, nil, nil], fn {index, element}, acc ->
              if String.contains?(element, String.reverse(word)),
                do: [true, index + 1, element],
                else: acc
            end)

          if isRightToLeft do
            distance = String.length(element) - String.length(word)

            Enum.reduce(0..distance, %{}, fn shift, acc ->
              upper_bound = shift + (String.length(word) - 1)

              if String.slice(element, shift..upper_bound) == String.reverse(word) do
                Map.put_new(acc, word, %Location{
                  to: %{row: row, column: shift + 1},
                  from: %{row: row, column: String.length(word) + shift}
                })
              else
                acc
              end
            end)
            |> Map.merge(search_results)
          else
          end
        end
      end
    end)
  end
end

grid = """
jefblpepre
camdcimgtc
oivokprjsm
pbwasqroua
rixilelhrs
wolcqlirpc
screeaumgr
alxhpburyi
jalaycalmp
clojurermt
"""

list = String.trim(grid) |> String.split("\n")

Enum.reduce(list, %{i: 0, vals: []}, fn _, %{i: i, vals: vals} ->
  %{j: _, str: strval} =
    Enum.reduce(list, %{j: i, str: ""}, fn element, %{j: j, str: str} ->
      %{j: j + 1, str: "#{str}#{String.at(element, j)}"}
    end)

  %{i: i + 1, vals: vals ++ [strval]}
end)
|> IO.inspect()

# "######################################################" |> IO.puts()

# Enum.reduce(1..length(list), %{list: list, vals: []}, fn _, %{list: items, vals: vals} ->
#   %{j: _, str: strval} =
#     Enum.reduce(items, %{j: 0, str: ""}, fn element, %{j: j, str: str} ->
#       %{j: j + 1, str: "#{str}#{String.at(element, j)}"}
#     end)

#   [_ | tail] = items
#   %{list: tail, vals: vals ++ [strval]}
# end)
# |> IO.inspect()
