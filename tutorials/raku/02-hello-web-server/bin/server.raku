use lib 'lib';
use Server;

my $port = @*ARGS[0] ?? @*ARGS[0].Int !! 4040;
start-server($port);
