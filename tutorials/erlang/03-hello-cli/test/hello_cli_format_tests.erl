-module(hello_cli_format_tests).
-include_lib("eunit/include/eunit.hrl").

format_name_no_shout_test() ->
    Result = lists:flatten(hello_cli_format:format(#{name => "Alice", shout => false})),
    ?assertEqual("Hello, Alice!", Result).

format_name_shout_test() ->
    Result = lists:flatten(hello_cli_format:format(#{name => "Alice", shout => true})),
    ?assertEqual("HELLO, ALICE!", Result).

format_name_default_shout_test() ->
    Result = lists:flatten(hello_cli_format:format(#{name => "Alice"})),
    ?assertEqual("Hello, Alice!", Result).
