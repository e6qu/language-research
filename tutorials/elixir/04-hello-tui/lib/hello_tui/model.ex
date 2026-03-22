defmodule HelloTui.Model do
  @moduledoc """
  Data model for the TUI app. Tracks a list of items and a cursor position.
  """

  defstruct items: ["Elixir", "Erlang", "Elm", "Haskell", "Rust"], cursor: 0

  def new, do: %__MODULE__{}

  def move_down(%__MODULE__{cursor: cursor, items: items} = model) do
    %{model | cursor: min(cursor + 1, length(items) - 1)}
  end

  def move_up(%__MODULE__{cursor: cursor} = model) do
    %{model | cursor: max(cursor - 1, 0)}
  end

  def selected_item(%__MODULE__{cursor: cursor, items: items}) do
    Enum.at(items, cursor)
  end
end
