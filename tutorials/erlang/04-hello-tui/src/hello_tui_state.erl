-module(hello_tui_state).
-export([new/0, move_up/1, move_down/1, selected_item/1, items/1, cursor/1]).

-record(state, {items :: [binary()], cursor :: non_neg_integer()}).

new() ->
    #state{items = [<<"Elixir">>, <<"Erlang">>, <<"Elm">>, <<"Haskell">>, <<"Rust">>], cursor = 0}.

move_up(#state{cursor = 0} = S) -> S;
move_up(#state{cursor = C} = S) -> S#state{cursor = C - 1}.

move_down(#state{items = Items, cursor = C} = S) when C >= length(Items) - 1 -> S;
move_down(#state{cursor = C} = S) -> S#state{cursor = C + 1}.

selected_item(#state{items = Items, cursor = C}) -> lists:nth(C + 1, Items).

items(#state{items = Items}) -> Items.
cursor(#state{cursor = C}) -> C.
