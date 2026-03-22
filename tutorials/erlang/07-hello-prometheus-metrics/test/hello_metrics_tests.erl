-module(hello_metrics_tests).
-include_lib("eunit/include/eunit.hrl").

setup() ->
    application:ensure_all_started(prometheus),
    try prometheus_counter:new([
        {name, hello_work_total},
        {help, "Total work requests"}
    ]) catch _:_ -> ok end,
    try prometheus_histogram:new([
        {name, hello_work_duration_ms},
        {help, "Work duration"},
        {buckets, [10, 50, 100, 500, 1000]}
    ]) catch _:_ -> ok end,
    ok.

counter_increment_test() ->
    setup(),
    Before = prometheus_counter:value(hello_work_total),
    prometheus_counter:inc(hello_work_total),
    After = prometheus_counter:value(hello_work_total),
    ?assertEqual(Before + 1, After).

metrics_format_test() ->
    setup(),
    prometheus_counter:inc(hello_work_total),
    Output = prometheus_text_format:format(),
    Text = lists:flatten(io_lib:format("~s", [Output])),
    ?assertNotEqual(nomatch, string:find(Text, "hello_work_total")).
