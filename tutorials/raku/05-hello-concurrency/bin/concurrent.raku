use lib 'lib';
use Concurrent;

my @urls = <http://example.com http://raku.org http://perl.org>;
say "Fetching {+@urls} URLs concurrently...";
my @results = fetch-all(@urls);
for @results -> %r {
    say "  {%r<url>} => {%r<status>}";
}
say "Done.";
