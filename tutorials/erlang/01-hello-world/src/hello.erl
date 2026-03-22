-module(hello).
-export([greet/0, greet/1]).

greet() -> <<"Hello, world!">>.

greet(Name) -> <<"Hello, ", Name/binary, "!">>.
