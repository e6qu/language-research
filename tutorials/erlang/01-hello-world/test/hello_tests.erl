-module(hello_tests).
-include_lib("eunit/include/eunit.hrl").

greet_default_test() ->
    ?assertEqual(<<"Hello, world!">>, hello:greet()).

greet_name_test() ->
    ?assertEqual(<<"Hello, Alice!">>, hello:greet(<<"Alice">>)).

greet_empty_test() ->
    ?assertEqual(<<"Hello, !">>, hello:greet(<<>>)).
