-module(openapi_spec_tests).
-include_lib("eunit/include/eunit.hrl").

spec_has_openapi_key_test() ->
    Spec = openapi_spec:spec(),
    ?assertMatch(#{<<"openapi">> := <<"3.0.0">>}, Spec).

spec_has_greet_path_test() ->
    #{<<"paths">> := Paths} = openapi_spec:spec(),
    ?assertMatch(#{<<"/api/greet">> := _}, Paths).

spec_json_encode_test() ->
    Spec = openapi_spec:spec(),
    Json = jsx:encode(Spec),
    ?assert(is_binary(Json)).
