-module(greet_handler).
-behaviour(cowboy_handler).

-export([init/2]).

init(Req0, State) ->
    Name = cowboy_req:binding(name, Req0),
    Body = jsx:encode(#{<<"message">> => <<"Hello, ", Name/binary, "!">>}),
    Req = cowboy_req:reply(200,
        #{<<"content-type">> => <<"application/json">>},
        Body, Req0),
    {ok, Req, State}.
