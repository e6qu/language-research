-module(health_handler).
-export([init/2]).

init(Req0, State) ->
    Deps = health_checker:check_all(),
    DepList = maps:fold(fun(K, V, Acc) ->
        [#{<<"name">> => atom_to_binary(K, utf8),
           <<"status">> => atom_to_binary(V, utf8)} | Acc]
    end, [], Deps),
    Overall = health_checker:status(),
    Body = jsx:encode(#{
        <<"status">> => atom_to_binary(Overall, utf8),
        <<"dependencies">> => DepList
    }),
    Code = case Overall of ok -> 200; degraded -> 503 end,
    Req = cowboy_req:reply(Code, #{<<"content-type">> => <<"application/json">>}, Body, Req0),
    {ok, Req, State}.
