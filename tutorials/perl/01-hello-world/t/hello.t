use strict;
use warnings;
use Test::More tests => 3;
use lib 'lib';
use Hello;

is(Hello::greet(),        "Hello, world!", "default greeting");
is(Hello::greet("Alice"), "Hello, Alice!", "named greeting");
is(Hello::greet(""),      "Hello, world!", "empty string greeting");
