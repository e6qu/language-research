-module(json_formatter_tests).
-include_lib("eunit/include/eunit.hrl").

make_log_event(Msg, Level, Meta) ->
    #{msg => Msg, level => Level, meta => Meta}.

basic_format_test() ->
    Event = make_log_event({string, "hello"}, info, #{time => erlang:system_time(microsecond)}),
    Output = iolist_to_binary(json_formatter:format(Event, #{})),
    %% Should not crash — valid JSON
    _Decoded = jsx:decode(Output),
    ok.

contains_message_key_test() ->
    Event = make_log_event({string, "test msg"}, info, #{time => erlang:system_time(microsecond)}),
    Output = iolist_to_binary(json_formatter:format(Event, #{})),
    Decoded = jsx:decode(Output, [return_maps]),
    ?assert(maps:is_key(<<"message">>, Decoded)),
    ?assertEqual(<<"test msg">>, maps:get(<<"message">>, Decoded)).

contains_level_key_test() ->
    Event = make_log_event({string, "x"}, warning, #{time => erlang:system_time(microsecond)}),
    Output = iolist_to_binary(json_formatter:format(Event, #{})),
    Decoded = jsx:decode(Output, [return_maps]),
    ?assert(maps:is_key(<<"level">>, Decoded)),
    ?assertEqual(<<"warning">>, maps:get(<<"level">>, Decoded)).

custom_metadata_test() ->
    Meta = #{time => erlang:system_time(microsecond), order_id => 42, user => <<"alice">>},
    Event = make_log_event({string, "order"}, info, Meta),
    Output = iolist_to_binary(json_formatter:format(Event, #{})),
    Decoded = jsx:decode(Output, [return_maps]),
    ?assertEqual(42, maps:get(<<"order_id">>, Decoded)),
    ?assertEqual(<<"alice">>, maps:get(<<"user">>, Decoded)).
