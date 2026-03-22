-module(hello_health_app).
-behaviour(application).
-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/healthz", liveness_handler, []},
            {"/readyz", readiness_handler, []},
            {"/health", health_handler, []}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http, [{port, 8083}], #{
        env => #{dispatch => Dispatch}
    }),
    hello_health_sup:start_link().

stop(_State) ->
    ok = cowboy:stop_listener(http),
    ok.
