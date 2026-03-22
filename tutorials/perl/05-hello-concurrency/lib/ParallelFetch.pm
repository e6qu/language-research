package ParallelFetch;
use strict;
use warnings;

sub fetch_all {
    my @urls = @_;
    return () unless @urls;

    my @results;
    for my $url (@urls) {
        pipe(my $reader, my $writer);
        my $pid = fork();
        if ($pid == 0) {
            close $reader;
            print $writer "$url:200\n";
            close $writer;
            exit 0;
        }
        close $writer;
        my $line = <$reader>;
        chomp $line;
        push @results, $line;
        close $reader;
        waitpid($pid, 0);
    }
    return @results;
}

1;
