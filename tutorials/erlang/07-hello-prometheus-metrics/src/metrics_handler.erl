-module(metrics_handler).
-export([init/2]).

init(Req0, State) ->
    Metrics = prometheus_text_format:format(),
    Req = cowboy_req:reply(200, #{<<"content-type">> => <<"text/plain">>}, Metrics, Req0),
    {ok, Req, State}.
