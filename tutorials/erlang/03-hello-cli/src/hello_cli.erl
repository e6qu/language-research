-module(hello_cli).
-export([main/1]).

main(Args) ->
    Command = #{
        arguments => [
            #{name => name, type => string, default => "world", long => "-name"},
            #{name => shout, type => boolean, default => false, long => "-shout"}
        ]
    },
    {ok, Parsed, _, _} = argparse:parse(Args, Command),
    Result = hello_cli_format:format(Parsed),
    io:format("~ts~n", [Result]).
