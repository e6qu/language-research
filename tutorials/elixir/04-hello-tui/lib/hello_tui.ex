defmodule HelloTui do
  @moduledoc """
  A minimal terminal UI app built with Owl.
  Displays a selectable list with arrow-key navigation.
  """

  alias HelloTui.Model

  def start do
    model = Model.new()
    loop(model)
  end

  defp loop(model) do
    render(model)

    case IO.getn("", 1) do
      "q" ->
        IO.puts("\nGoodbye!")

      "\e" ->
        # Read escape sequence
        case IO.getn("", 2) do
          "[A" -> loop(Model.move_up(model))
          "[B" -> loop(Model.move_down(model))
          _ -> loop(model)
        end

      _ ->
        loop(model)
    end
  end

  defp render(%Model{items: items, cursor: cursor} = model) do
    # Clear screen and move to top
    IO.write("\e[2J\e[H")
    IO.puts(Owl.Data.tag("Hello TUI - Use arrows to navigate, q to quit", :cyan))
    IO.puts(String.duplicate("─", 50))

    items
    |> Enum.with_index()
    |> Enum.each(fn {item, idx} ->
      if idx == cursor do
        IO.puts(Owl.Data.tag("▸ #{item}", [:green, :bold]))
      else
        IO.puts("  #{item}")
      end
    end)

    IO.puts(String.duplicate("─", 50))
    IO.puts("Selected: #{Owl.Data.tag(Model.selected_item(model), :yellow)}")
  end
end
