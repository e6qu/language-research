-module(hello_tui_state_tests).
-include_lib("eunit/include/eunit.hrl").

new_has_five_items_test() ->
    State = hello_tui_state:new(),
    ?assertEqual(5, length(hello_tui_state:items(State))).

new_cursor_is_zero_test() ->
    State = hello_tui_state:new(),
    ?assertEqual(0, hello_tui_state:cursor(State)).

move_down_increments_cursor_test() ->
    State = hello_tui_state:move_down(hello_tui_state:new()),
    ?assertEqual(1, hello_tui_state:cursor(State)).

move_down_at_end_stays_test() ->
    S0 = hello_tui_state:new(),
    S1 = hello_tui_state:move_down(S0),
    S2 = hello_tui_state:move_down(S1),
    S3 = hello_tui_state:move_down(S2),
    S4 = hello_tui_state:move_down(S3),
    S5 = hello_tui_state:move_down(S4),
    ?assertEqual(4, hello_tui_state:cursor(S5)).

move_up_at_zero_stays_test() ->
    State = hello_tui_state:move_up(hello_tui_state:new()),
    ?assertEqual(0, hello_tui_state:cursor(State)).

selected_item_returns_correct_test() ->
    S0 = hello_tui_state:new(),
    ?assertEqual(<<"Elixir">>, hello_tui_state:selected_item(S0)),
    S1 = hello_tui_state:move_down(S0),
    ?assertEqual(<<"Erlang">>, hello_tui_state:selected_item(S1)).
