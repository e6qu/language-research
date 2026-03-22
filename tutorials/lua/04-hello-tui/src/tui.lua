local tui_state = require("src.tui_state")

local M = {}

local ESC = "\27"

function M.clear_screen()
    io.write(ESC .. "[2J" .. ESC .. "[H")
end

function M.hide_cursor()
    io.write(ESC .. "[?25l")
end

function M.show_cursor()
    io.write(ESC .. "[?25h")
end

function M.render(state)
    M.clear_screen()
    io.write("Select a language (up/down arrows, q to quit):\n\n")
    for i, item in ipairs(state.items) do
        if i == state.cursor then
            io.write(ESC .. "[7m > " .. item .. " " .. ESC .. "[0m\n")
        else
            io.write("   " .. item .. "\n")
        end
    end
    io.write("\n")
    io.flush()
end

function M.read_key()
    local c = io.read(1)
    if c == nil then return "quit" end
    if c == "q" or c == "Q" then return "quit" end
    if c == ESC then
        local c2 = io.read(1)
        if c2 == "[" then
            local c3 = io.read(1)
            if c3 == "A" then return "up" end
            if c3 == "B" then return "down" end
        end
    end
    return nil
end

function M.enable_raw_mode()
    os.execute("stty -echo -icanon min 1 time 0 2>/dev/null")
end

function M.disable_raw_mode()
    os.execute("stty sane 2>/dev/null")
end

function M.run()
    local state = tui_state.new()
    M.enable_raw_mode()
    M.hide_cursor()

    local running = true
    while running do
        M.render(state)
        local key = M.read_key()
        if key == "quit" then
            running = false
        elseif key == "up" then
            tui_state.move_up(state)
        elseif key == "down" then
            tui_state.move_down(state)
        end
    end

    M.clear_screen()
    io.write("Selected: " .. tui_state.selected_item(state) .. "\n")
    M.show_cursor()
    M.disable_raw_mode()
end

return M
