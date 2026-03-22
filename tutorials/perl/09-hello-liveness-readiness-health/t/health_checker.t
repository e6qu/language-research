use strict;
use warnings;
use Test::More tests => 10;
use JSON::PP;
use lib 'lib';
use HealthChecker;

my $hc = HealthChecker->new();

is($hc->status(), "ok", "initial status ok");
ok($hc->check_all(), "all checks pass initially");

{
    my $data = decode_json($hc->liveness_json());
    is($data->{status}, "ok", "liveness ok");
}

{
    my $data = decode_json($hc->readiness_json());
    is($data->{status}, "ok", "readiness ok");
}

$hc->set_dependency("database", "ok");
$hc->set_dependency("cache", "ok");
ok($hc->check_all(), "all deps ok");

$hc->set_dependency("cache", "error");
ok(!$hc->check_all(), "fails when dep is error");

{
    my $data = decode_json($hc->readiness_json());
    is($data->{status}, "not_ready", "readiness not_ready");
}

{
    my $data = decode_json($hc->health_json());
    is($data->{healthy}, JSON::PP::false, "health not healthy");
    is($data->{dependencies}{cache}, "error", "cache dep error");
}

$hc->status("error");
{
    my $data = decode_json($hc->liveness_json());
    is($data->{status}, "error", "liveness error after status change");
}
