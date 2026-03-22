use strict;
use warnings;
use Test::More tests => 7;
use JSON::PP;
use lib 'lib';
use Logger;

{
    my $json = Logger::info("server started");
    my $data = decode_json($json);
    is($data->{level}, "info", "info level");
    is($data->{message}, "server started", "info message");
    ok(exists $data->{timestamp}, "has timestamp");
}

{
    my $json = Logger::warn("disk low", host => "srv1");
    my $data = decode_json($json);
    is($data->{level}, "warn", "warn level");
    is($data->{host}, "srv1", "metadata included");
}

{
    my $json = Logger::error("crash", code => 500, trace => "main:42");
    my $data = decode_json($json);
    is($data->{level}, "error", "error level");
    is($data->{code}, 500, "numeric metadata");
}
