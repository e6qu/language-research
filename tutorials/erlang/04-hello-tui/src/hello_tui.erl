-module(hello_tui).
-export([start/0]).

start() ->
    io:setopts([{binary, true}]),
    State = hello_tui_state:new(),
    loop(State).

loop(State) ->
    Output = hello_tui_render:render(State),
    io:put_chars(Output),
    case read_key() of
        quit ->
            io:put_chars("\e[2J\e[H"),
            io:format("You selected: ~s~n", [hello_tui_state:selected_item(State)]),
            ok;
        up ->
            loop(hello_tui_state:move_up(State));
        down ->
            loop(hello_tui_state:move_down(State));
        _ ->
            loop(State)
    end.

read_key() ->
    case io:get_chars(<<>>, 1) of
        <<"q">> -> quit;
        <<"\e">> ->
            case io:get_chars(<<>>, 1) of
                <<"[">> ->
                    case io:get_chars(<<>>, 1) of
                        <<"A">> -> up;
                        <<"B">> -> down;
                        _ -> unknown
                    end;
                _ -> unknown
            end;
        _ -> unknown
    end.
