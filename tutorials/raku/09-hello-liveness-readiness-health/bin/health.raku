use lib 'lib';
use HealthChecker;

my $hc = HealthChecker.new;
$hc.register-dep("database", True);
$hc.register-dep("cache", True);
$hc.register-dep("queue", True);

say "All healthy:";
say $hc.to-json;

$hc.set-dep-status("cache", False);
say "\nCache down:";
say $hc.to-json;
