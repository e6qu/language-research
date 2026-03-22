package HelloCli;
use strict;
use warnings;
use Getopt::Long qw(GetOptionsFromArray);

sub parse_args {
    my ($argv) = @_;
    my %opts = (name => "world", shout => 0);

    GetOptionsFromArray($argv,
        'name=s' => \$opts{name},
        'shout'  => \$opts{shout},
    ) or die "Invalid arguments\n";

    return \%opts;
}

sub format {
    my ($opts) = @_;
    my $msg = "Hello, $opts->{name}!";
    $msg = uc($msg) if $opts->{shout};
    return $msg;
}

1;
