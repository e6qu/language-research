use strict;
use warnings;
use Test::More tests => 4;
use lib 'lib';
use ParallelFetch;

{
    my @results = ParallelFetch::fetch_all();
    is(scalar @results, 0, "empty list returns empty");
}

{
    my @results = ParallelFetch::fetch_all("http://a.com");
    is(scalar @results, 1, "single URL returns one result");
    like($results[0], qr/a\.com:200/, "result contains URL and status");
}

{
    my @results = ParallelFetch::fetch_all("http://a.com", "http://b.com", "http://c.com");
    is(scalar @results, 3, "three URLs return three results");
}
