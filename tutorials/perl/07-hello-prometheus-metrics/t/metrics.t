use strict;
use warnings;
use Test::More tests => 6;
use lib 'lib';
use Metrics;

my $m = Metrics->new();

$m->increment("http_requests_total", { method => "GET" });
$m->increment("http_requests_total", { method => "GET" });
$m->increment("http_requests_total", { method => "POST" });

my $out = $m->format();
like($out, qr/http_requests_total/, "contains metric name");
like($out, qr/counter/, "contains TYPE counter");
like($out, qr/method="GET".*2/, "GET count is 2");
like($out, qr/method="POST".*1/, "POST count is 1");

$m->observe("request_duration_seconds", 0.25);
$m->observe("request_duration_seconds", 0.75);
$out = $m->format();
like($out, qr/request_duration_seconds_sum 1/, "histogram sum");
like($out, qr/request_duration_seconds_count 2/, "histogram count");
