-module(health_checker_tests).
-include_lib("eunit/include/eunit.hrl").

setup() ->
    case whereis(health_checker) of
        undefined -> ok;
        Pid -> gen_server:stop(Pid)
    end,
    {ok, Pid2} = health_checker:start_link(),
    Pid2.

cleanup(Pid) ->
    gen_server:stop(Pid).

initial_status_test() ->
    Pid = setup(),
    ?assertEqual(ok, health_checker:status()),
    cleanup(Pid).

degraded_status_test() ->
    Pid = setup(),
    health_checker:set_dependency(database, error),
    ?assertEqual(degraded, health_checker:status()),
    cleanup(Pid).

check_all_returns_map_test() ->
    Pid = setup(),
    Result = health_checker:check_all(),
    ?assert(is_map(Result)),
    ?assertEqual(ok, maps:get(database, Result)),
    ?assertEqual(ok, maps:get(cache, Result)),
    cleanup(Pid).

set_dependency_updates_test() ->
    Pid = setup(),
    health_checker:set_dependency(cache, error),
    Result = health_checker:check_all(),
    ?assertEqual(error, maps:get(cache, Result)),
    ?assertEqual(ok, maps:get(database, Result)),
    cleanup(Pid).
