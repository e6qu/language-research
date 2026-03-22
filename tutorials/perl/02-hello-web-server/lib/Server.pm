package Server;
use strict;
use warnings;
use JSON::PP;
use IO::Socket::INET;

sub handle_request {
    my ($request_line) = @_;
    $request_line //= "";

    my ($method, $path) = split /\s+/, $request_line;
    $method //= "";
    $path   //= "";

    if ($method ne "GET") {
        return (405, encode_json({ error => "method not allowed" }));
    }

    if ($path eq "/") {
        return (200, encode_json({ message => "Hello, world!" }));
    }
    if ($path =~ m{^/greet/(\w+)$}) {
        return (200, encode_json({ message => "Hello, $1!" }));
    }

    return (404, encode_json({ error => "not found" }));
}

sub start {
    my ($port) = @_;
    $port //= 8080;

    my $server = IO::Socket::INET->new(
        LocalPort => $port,
        Type      => SOCK_STREAM,
        Reuse     => 1,
        Listen    => 5,
    ) or die "Cannot start server on port $port: $!\n";

    print "Listening on http://localhost:$port\n";

    while (my $client = $server->accept()) {
        my $request_line = <$client>;
        chomp $request_line if defined $request_line;
        my ($status, $body) = handle_request($request_line);
        my $status_text = $status == 200 ? "OK" : $status == 404 ? "Not Found" : "Error";
        print $client "HTTP/1.0 $status $status_text\r\n";
        print $client "Content-Type: application/json\r\n";
        print $client "Content-Length: " . length($body) . "\r\n";
        print $client "\r\n";
        print $client $body;
        close $client;
    }
    close $server;
}

1;
