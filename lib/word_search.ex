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
      isPresent =
        Enum.any?(flattened_grid_map, fn {_, element} ->
          String.contains?(element, word) || String.contains?(element, String.reverse(word))
        end)

      if !isPresent do
        # Map.put_new(search_results, word, nil)
        IO.inspect(flattened_grid_map, label: :map)

        topbottom =
          Enum.reduce(1..map_size(flattened_grid_map), [], fn pos, arr ->
            [
              Enum.reduce(flattened_grid_map, "", fn {_, element}, acc ->
                "#{acc}#{String.at(element, pos - 1)}"
              end)
              | arr
            ]
          end)

        IO.inspect(topbottom, label: :debug)
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
          end
        end
      end
    end)
  end
end
