-module(hello_logging).
-export([demo/0]).

demo() ->
    logger:info("Processing order", #{order_id => 123, user_id => <<"abc">>}),
    logger:warning("Slow query", #{duration_ms => 1500}),
    logger:error("Connection failed", #{service => <<"database">>}).
