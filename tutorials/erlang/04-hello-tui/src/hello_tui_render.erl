-module(hello_tui_render).
-export([render/1]).

render(State) ->
    Items = hello_tui_state:items(State),
    Cursor = hello_tui_state:cursor(State),
    Clear = "\e[2J\e[H",
    Header = "Use arrow keys to navigate, q to quit\n\n",
    ItemLines = render_items(Items, Cursor, 0, []),
    Selected = hello_tui_state:selected_item(State),
    StatusBar = ["\n\e[1mSelected: ", Selected, "\e[0m\n"],
    [Clear, Header, ItemLines, StatusBar].

render_items([], _Cursor, _Idx, Acc) ->
    lists:reverse(Acc);
render_items([Item | Rest], Cursor, Idx, Acc) ->
    Line = case Idx of
        Cursor -> ["\e[7m  > ", Item, " \e[0m\n"];
        _      -> ["    ", Item, "\n"]
    end,
    render_items(Rest, Cursor, Idx + 1, [Line | Acc]).
