-module(readiness_handler).
-export([init/2]).

init(Req0, State) ->
    case health_checker:status() of
        ok ->
            Body = jsx:encode(#{<<"status">> => <<"ok">>}),
            Req = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Body, Req0),
            {ok, Req, State};
        degraded ->
            Body = jsx:encode(#{<<"status">> => <<"degraded">>}),
            Req = cowboy_req:reply(503, #{<<"content-type">> => <<"application/json">>}, Body, Req0),
            {ok, Req, State}
    end.
