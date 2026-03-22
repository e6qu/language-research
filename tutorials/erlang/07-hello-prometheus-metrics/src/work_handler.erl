-module(work_handler).
-export([init/2]).

init(Req0, State) ->
    prometheus_counter:inc(hello_work_total),
    Duration = rand:uniform(200),
    prometheus_histogram:observe(hello_work_duration_ms, Duration),
    Body = io_lib:format("{\"status\":\"ok\",\"duration_ms\":~b}", [Duration]),
    Req = cowboy_req:reply(200, #{<<"content-type">> => <<"application/json">>}, Body, Req0),
    {ok, Req, State}.
