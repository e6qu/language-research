-module(hello_web_tests).
-include_lib("eunit/include/eunit.hrl").

hello_json_test() ->
    Expected = #{<<"message">> => <<"Hello, world!">>},
    Encoded = jsx:encode(Expected),
    Decoded = jsx:decode(Encoded, [return_maps]),
    ?assertEqual(Expected, Decoded).

greet_json_test() ->
    Name = <<"Alice">>,
    Message = <<"Hello, ", Name/binary, "!">>,
    Expected = #{<<"message">> => Message},
    Encoded = jsx:encode(Expected),
    Decoded = jsx:decode(Encoded, [return_maps]),
    ?assertEqual(Expected, Decoded),
    ?assertEqual(<<"Hello, Alice!">>, maps:get(<<"message">>, Decoded)).

notfound_json_test() ->
    Expected = #{<<"error">> => <<"not found">>},
    Encoded = jsx:encode(Expected),
    Decoded = jsx:decode(Encoded, [return_maps]),
    ?assertEqual(Expected, Decoded).

json_encoding_roundtrip_test() ->
    Map = #{<<"key">> => <<"value">>, <<"number">> => 42},
    ?assertEqual(Map, jsx:decode(jsx:encode(Map), [return_maps])).
