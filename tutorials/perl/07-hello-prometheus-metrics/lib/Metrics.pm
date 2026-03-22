package Metrics;
use strict;
use warnings;

sub new {
    my ($class) = @_;
    return bless {
        counters   => {},
        histograms => {},
    }, $class;
}

sub increment {
    my ($self, $name, $labels, $value) = @_;
    $labels //= {};
    $value  //= 1;
    my $key = _label_key($name, $labels);
    $self->{counters}{$key} //= { name => $name, labels => $labels, value => 0 };
    $self->{counters}{$key}{value} += $value;
}

sub observe {
    my ($self, $name, $value, $labels) = @_;
    $labels //= {};
    my $key = _label_key($name, $labels);
    $self->{histograms}{$key} //= { name => $name, labels => $labels, sum => 0, count => 0 };
    $self->{histograms}{$key}{sum}   += $value;
    $self->{histograms}{$key}{count} += 1;
}

sub format {
    my ($self) = @_;
    my $out = "";

    for my $key (sort keys %{ $self->{counters} }) {
        my $c = $self->{counters}{$key};
        my $lbl = _format_labels($c->{labels});
        $out .= "# TYPE $c->{name} counter\n";
        $out .= "$c->{name}$lbl $c->{value}\n";
    }

    for my $key (sort keys %{ $self->{histograms} }) {
        my $h = $self->{histograms}{$key};
        my $lbl = _format_labels($h->{labels});
        $out .= "# TYPE $h->{name} histogram\n";
        $out .= "$h->{name}_sum$lbl $h->{sum}\n";
        $out .= "$h->{name}_count$lbl $h->{count}\n";
    }

    return $out;
}

sub _label_key {
    my ($name, $labels) = @_;
    my $lbl = join(",", map { "$_=$labels->{$_}" } sort keys %$labels);
    return "$name\{$lbl\}";
}

sub _format_labels {
    my ($labels) = @_;
    return "" unless %$labels;
    my $inner = join(",", map { qq($_="$labels->{$_}") } sort keys %$labels);
    return "{$inner}";
}

1;
