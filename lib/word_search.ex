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
      String.split(grid, "\n")
      |> Enum.with_index(fn element, row -> {row, element} end)
      |> Enum.into(%{})

    Enum.reduce(words, %{}, fn word, acc ->
      isPresent =
        Enum.any?(flattened_grid_map, fn {_row, element} ->
          String.contains?(element, word)
        end)

      if !isPresent, do: Map.put_new(acc, word, nil)
    end)
  end
end
