local M = {}

function M.new()
    return {
        items = {"Lua", "Elixir", "Erlang", "Elm", "Tcl"},
        cursor = 1
    }
end

function M.move_down(state)
    if state.cursor < #state.items then
        state.cursor = state.cursor + 1
    end
    return state
end

function M.move_up(state)
    if state.cursor > 1 then
        state.cursor = state.cursor - 1
    end
    return state
end

function M.selected_item(state)
    return state.items[state.cursor]
end

return M
