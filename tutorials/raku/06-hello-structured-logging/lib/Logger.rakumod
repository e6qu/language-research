unit module Logger;

sub to-json(%hash --> Str) is export {
    my @pairs = %hash.sort(*.key).map: -> $p {
        my $v = $p.value;
        my $val = $v ~~ Numeric && !($v ~~ Bool)
            ?? $v.Str
            !! qq["{ $v.Str.subst('"', '\\"', :g) }"];
        qq["{$p.key}":$val]
    };
    return '{' ~ @pairs.join(',') ~ '}';
}

sub log-entry(Str $level, Str $message, *%metadata --> Str) is export {
    my %entry = (
        level   => $level,
        message => $message,
        |%metadata,
    );
    return to-json(%entry);
}

sub log-info(Str $msg, *%meta --> Str) is export  { log-entry("info", $msg, |%meta) }
sub log-warn(Str $msg, *%meta --> Str) is export  { log-entry("warn", $msg, |%meta) }
sub log-error(Str $msg, *%meta --> Str) is export { log-entry("error", $msg, |%meta) }
