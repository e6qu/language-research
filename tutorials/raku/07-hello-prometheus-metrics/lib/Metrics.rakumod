unit module Metrics;

my %counters;
my %histograms;

sub counter-inc(Str $name, Num() $value = 1e0, *%labels) is export {
    my $key = $name ~ labels-key(%labels);
    %counters{$key} = { name => $name, value => (%counters{$key}<value> // 0e0) + $value, labels => %labels };
}

sub histogram-observe(Str $name, Num() $value, *%labels) is export {
    my $key = $name ~ labels-key(%labels);
    %histograms{$key} //= { name => $name, sum => 0e0, count => 0, labels => %labels };
    %histograms{$key}<sum> += $value;
    %histograms{$key}<count> += 1;
}

sub labels-key(%labels --> Str) {
    return %labels.sort(*.key).map({ "{.key}={.value}" }).join(',');
}

sub format-labels(%labels --> Str) {
    return '' unless %labels;
    my @pairs = %labels.sort(*.key).map: { qq[{.key}="{.value}"] };
    return '{' ~ @pairs.join(',') ~ '}';
}

sub metrics-format(--> Str) is export {
    my @lines;
    for %counters.sort(*.key) -> $p {
        my %c = $p.value;
        @lines.push("# TYPE {%c<name>} counter");
        @lines.push("{%c<name>}{format-labels(%c<labels>)} {%c<value>}");
    }
    for %histograms.sort(*.key) -> $p {
        my %h = $p.value;
        my $lbl = format-labels(%h<labels>);
        @lines.push("# TYPE {%h<name>} histogram");
        @lines.push("{%h<name>}_sum$lbl {%h<sum>}");
        @lines.push("{%h<name>}_count$lbl {%h<count>}");
    }
    return @lines.join("\n");
}

sub metrics-reset() is export {
    %counters = ();
    %histograms = ();
}
