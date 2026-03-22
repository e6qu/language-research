-module(hello_cli_format).
-export([format/1]).

format(#{name := Name, shout := true}) ->
    Greeting = io_lib:format("Hello, ~ts!", [Name]),
    string:uppercase(unicode:characters_to_list(Greeting));
format(#{name := Name, shout := false}) ->
    io_lib:format("Hello, ~ts!", [Name]);
format(#{name := Name}) ->
    format(#{name => Name, shout => false}).
