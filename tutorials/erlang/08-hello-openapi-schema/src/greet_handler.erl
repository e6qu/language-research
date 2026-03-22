-module(greet_handler).
-behaviour(cowboy_handler).
-export([init/2]).

init(Req0, State) ->
    QsVals = cowboy_req:parse_qs(Req0),
    case lists:keyfind(<<"name">>, 1, QsVals) of
        {_, Name} ->
            Body = jsx:encode(#{<<"message">> => <<"Hello, ", Name/binary, "!">>}),
            Req = cowboy_req:reply(200, #{
                <<"content-type">> => <<"application/json">>
            }, Body, Req0),
            {ok, Req, State};
        false ->
            Body = jsx:encode(#{<<"error">> => <<"Missing required parameter: name">>}),
            Req = cowboy_req:reply(400, #{
                <<"content-type">> => <<"application/json">>
            }, Body, Req0),
            {ok, Req, State}
    end.
