package Hello;
use strict;
use warnings;

sub greet {
    my ($name) = @_;
    $name = "world" if !defined($name) || $name eq "";
    return "Hello, $name!";
}

1;
