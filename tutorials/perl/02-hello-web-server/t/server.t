use strict;
use warnings;
use Test::More tests => 6;
use JSON::PP;
use lib 'lib';
use Server;

{
    my ($status, $body) = Server::handle_request("GET / HTTP/1.1");
    is($status, 200, "root returns 200");
    my $data = decode_json($body);
    is($data->{message}, "Hello, world!", "root message");
}

{
    my ($status, $body) = Server::handle_request("GET /greet/Alice HTTP/1.1");
    is($status, 200, "greet returns 200");
    my $data = decode_json($body);
    is($data->{message}, "Hello, Alice!", "greet message");
}

{
    my ($status, $body) = Server::handle_request("GET /unknown HTTP/1.1");
    is($status, 404, "unknown returns 404");
    my $data = decode_json($body);
    is($data->{error}, "not found", "404 error message");
}
