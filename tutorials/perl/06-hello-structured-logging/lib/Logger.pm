package Logger;
use strict;
use warnings;
use JSON::PP;
use POSIX qw(strftime);

sub log_entry {
    my ($level, $message, %metadata) = @_;
    my $entry = {
        level     => $level,
        message   => $message,
        timestamp => strftime("%Y-%m-%dT%H:%M:%SZ", gmtime()),
        %metadata,
    };
    return encode_json($entry);
}

sub info  { return log_entry("info",  @_) }
sub warn  { return log_entry("warn",  @_) }
sub error { return log_entry("error", @_) }

1;
