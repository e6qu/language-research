-module(parallel_fetch).
-export([fetch_all/1, fetch/1, demo/0]).

fetch_all(Urls) ->
    Parent = self(),
    Refs = lists:map(fun(Url) ->
        Ref = make_ref(),
        spawn(fun() -> Parent ! {Ref, Url, fetch(Url)} end),
        {Ref, Url}
    end, Urls),
    [receive {Ref, Url, Result} -> {Url, Result} after 10000 -> {Url, {error, timeout}} end
     || {Ref, Url} <- Refs].

fetch(Url) ->
    application:ensure_all_started(inets),
    application:ensure_all_started(ssl),
    case httpc:request(get, {Url, []}, [{timeout, 5000}], []) of
        {ok, {{_, Status, _}, _, _}} -> {ok, Status};
        {error, Reason} -> {error, Reason}
    end.

demo() ->
    Urls = ["https://httpbin.org/get", "https://httpbin.org/ip", "https://httpbin.org/user-agent"],
    Results = fetch_all(Urls),
    lists:foreach(fun({Url, Result}) ->
        io:format("~s -> ~p~n", [Url, Result])
    end, Results).
