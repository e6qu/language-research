use strict;
use warnings;
use Test::More tests => 5;
use lib 'lib';
use HelloCli;

{
    my $opts = HelloCli::parse_args([]);
    is($opts->{name}, "world", "default name");
    is($opts->{shout}, 0, "default no shout");
}

{
    my $opts = HelloCli::parse_args(["--name", "Alice"]);
    is(HelloCli::format($opts), "Hello, Alice!", "named format");
}

{
    my $opts = HelloCli::parse_args(["--name", "Bob", "--shout"]);
    is(HelloCli::format($opts), "HELLO, BOB!", "shout format");
}

{
    my $opts = HelloCli::parse_args([]);
    is(HelloCli::format($opts), "Hello, world!", "default format");
}
