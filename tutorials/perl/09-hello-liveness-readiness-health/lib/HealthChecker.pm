package HealthChecker;
use strict;
use warnings;
use JSON::PP;

sub new {
    my ($class) = @_;
    return bless {
        status       => "ok",
        dependencies => {},
    }, $class;
}

sub status {
    my ($self, $new_status) = @_;
    $self->{status} = $new_status if defined $new_status;
    return $self->{status};
}

sub set_dependency {
    my ($self, $name, $status) = @_;
    $self->{dependencies}{$name} = $status;
}

sub check_all {
    my ($self) = @_;
    return 0 if $self->{status} ne "ok";
    for my $dep (values %{ $self->{dependencies} }) {
        return 0 if $dep ne "ok";
    }
    return 1;
}

sub liveness_json {
    my ($self) = @_;
    return encode_json({
        status => $self->{status} eq "ok" ? "ok" : "error",
    });
}

sub readiness_json {
    my ($self) = @_;
    my $ready = $self->check_all();
    return encode_json({
        status       => $ready ? "ok" : "not_ready",
        dependencies => $self->{dependencies},
    });
}

sub health_json {
    my ($self) = @_;
    return encode_json({
        status       => $self->{status},
        healthy      => $self->check_all() ? JSON::PP::true : JSON::PP::false,
        dependencies => $self->{dependencies},
    });
}

1;
