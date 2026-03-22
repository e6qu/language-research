unit module Server;

sub handle-request(Str $request --> List) is export {
    my @words = $request.words;
    my $method = @words[0] // '';
    my $path   = @words[1] // '';
    return (400, '{"error":"bad request"}') unless $path;

    given $path {
        when '/' {
            return (200, '{"message":"Hello, world!"}');
        }
        when /^ '/greet/' (.+) $/ {
            my $name = ~$/[0];
            return (200, qq[\{"message":"Hello, $name!"\}]);
        }
        default {
            return (404, '{"error":"not found"}');
        }
    }
}

sub start-server(Int $port = 8080) is export {
    my $listener = IO::Socket::INET.new(
        :listen,
        :localport($port),
    );
    say "Listening on port $port";

    loop {
        my $conn = $listener.accept;
        my $request = $conn.recv;
        my ($status, $body) = handle-request($request);
        my $response = "HTTP/1.1 $status OK\r\nContent-Type: application/json\r\nContent-Length: {$body.chars}\r\nConnection: close\r\n\r\n$body";
        $conn.print($response);
        $conn.close;
    }
}
