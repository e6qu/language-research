-module(parallel_fetch_tests).
-include_lib("eunit/include/eunit.hrl").

setup() ->
    application:ensure_all_started(inets),
    application:ensure_all_started(ssl).

fetch_all_empty_test() ->
    ?assertEqual([], parallel_fetch:fetch_all([])).

fetch_all_returns_results_test() ->
    setup(),
    Urls = ["https://httpbin.org/get", "https://httpbin.org/ip"],
    Results = parallel_fetch:fetch_all(Urls),
    ?assertEqual(length(Urls), length(Results)),
    lists:foreach(fun({Url, _Result}) ->
        ?assert(lists:member(Url, Urls))
    end, Results).

fetch_invalid_url_test() ->
    setup(),
    Result = parallel_fetch:fetch("http://localhost:1"),
    ?assertMatch({error, _}, Result).
