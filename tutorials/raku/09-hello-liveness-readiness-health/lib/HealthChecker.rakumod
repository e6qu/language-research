unit class HealthChecker;

has %.deps;

method register-dep(Str $name, Bool $healthy = True) {
    %!deps{$name} = $healthy;
}

method set-dep-status(Str $name, Bool $healthy) {
    %!deps{$name} = $healthy;
}

method is-live(--> Bool) {
    return True;  # alive if process is running
}

method is-ready(--> Bool) {
    return %!deps.values.all.so;
}

method health-status(--> Hash) {
    my $status = self.is-ready() ?? "ok" !! "degraded";
    return {
        status => $status,
        live   => self.is-live(),
        ready  => self.is-ready(),
        deps   => %!deps.clone,
    };
}

method to-json(--> Str) {
    my %h = self.health-status();
    my @dep-pairs = %h<deps>.sort(*.key).map: -> $p {
        qq["{$p.key}":{ $p.value ?? 'true' !! 'false' }]
    };
    my $deps-json = '{' ~ @dep-pairs.join(',') ~ '}';
    my $live  = %h<live>  ?? 'true' !! 'false';
    my $ready = %h<ready> ?? 'true' !! 'false';
    return qq[\{"status":"{%h<status>}","live":$live,"ready":$ready,"deps":$deps-json\}];
}
