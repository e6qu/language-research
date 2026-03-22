-module(json_formatter).
-export([format/2]).

format(#{msg := Msg, level := Level, meta := Meta} = _LogEvent, _Config) ->
    Message = format_msg(Msg),
    Timestamp = format_timestamp(Meta),
    Base = #{
        <<"message">> => unicode:characters_to_binary(Message),
        <<"level">> => atom_to_binary(Level, utf8),
        <<"timestamp">> => Timestamp
    },
    %% Add custom metadata (skip standard keys)
    Extra = maps:fold(fun(K, V, Acc) when is_atom(K) ->
        case lists:member(K, [time, mfa, file, line, gl, pid, domain, report_cb]) of
            true -> Acc;
            false -> Acc#{atom_to_binary(K, utf8) => format_value(V)}
        end;
       (_, _, Acc) -> Acc
    end, #{}, Meta),
    Json = jsx:encode(maps:merge(Base, Extra)),
    [Json, "\n"].

format_msg({string, Msg}) -> Msg;
format_msg({report, Report}) -> io_lib:format("~p", [Report]);
format_msg({Format, Args}) -> io_lib:format(Format, Args).

format_timestamp(#{time := Time}) ->
    calendar:system_time_to_rfc3339(Time, [{unit, microsecond}]);
format_timestamp(_) -> <<"unknown">>.

format_value(V) when is_binary(V) -> V;
format_value(V) when is_atom(V) -> atom_to_binary(V, utf8);
format_value(V) when is_integer(V) -> V;
format_value(V) when is_float(V) -> V;
format_value(V) -> unicode:characters_to_binary(io_lib:format("~p", [V])).
