local tui_state = require("src.tui_state")
local state = tui_state.new()
print("TUI state initialized. Items: " .. #state.items)
print("Selected: " .. tui_state.selected_item(state))
