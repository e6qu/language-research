defmodule HelloTui.ModelTest do
  use ExUnit.Case, async: true

  alias HelloTui.Model

  describe "new/0" do
    test "returns a model with 5 items and cursor at 0" do
      model = Model.new()
      assert length(model.items) == 5
      assert model.cursor == 0
    end
  end

  describe "move_down/1" do
    test "increments the cursor" do
      model = Model.new() |> Model.move_down()
      assert model.cursor == 1
    end

    test "clamps at the last item" do
      model = %Model{cursor: 4}
      assert Model.move_down(model).cursor == 4
    end
  end

  describe "move_up/1" do
    test "stays at 0 when already at the top" do
      model = Model.new()
      assert Model.move_up(model).cursor == 0
    end
  end

  describe "selected_item/1" do
    test "returns the item at the cursor position" do
      model = %Model{cursor: 2}
      assert Model.selected_item(model) == "Elm"
    end
  end
end
