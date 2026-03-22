-module(hello_web_app).
-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/", hello_handler, []},
            {"/greet/:name", greet_handler, []},
            {"/[...]", notfound_handler, []}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(hello_listener,
        [{port, 8080}],
        #{env => #{dispatch => Dispatch}}
    ),
    hello_web_sup:start_link().

stop(_State) ->
    ok = cowboy:stop_listener(hello_listener),
    ok.
