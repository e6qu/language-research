-module(hello_metrics_app).
-behaviour(application).
-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    %% Declare Prometheus metrics
    prometheus_counter:new([
        {name, hello_work_total},
        {help, "Total work requests"}
    ]),
    prometheus_histogram:new([
        {name, hello_work_duration_ms},
        {help, "Work duration"},
        {buckets, [10, 50, 100, 500, 1000]}
    ]),

    %% Set up Cowboy routes
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/work", work_handler, []},
            {"/metrics", metrics_handler, []}
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http, [{port, 8081}], #{
        env => #{dispatch => Dispatch}
    }),

    hello_metrics_sup:start_link().

stop(_State) ->
    cowboy:stop_listener(http),
    ok.
