use lib 'lib';
use Server;

my $port = @*ARGS[0] ?? @*ARGS[0].Int !! 8080;
start-server($port);
