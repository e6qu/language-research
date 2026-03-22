package TuiState;
use strict;
use warnings;

sub new {
    my ($class, @items) = @_;
    return bless {
        items  => [@items],
        cursor => 0,
    }, $class;
}

sub items  { return @{ $_[0]->{items} } }
sub cursor { return $_[0]->{cursor} }

sub move_up {
    my ($self) = @_;
    $self->{cursor}-- if $self->{cursor} > 0;
    return $self->{cursor};
}

sub move_down {
    my ($self) = @_;
    my $max = scalar(@{ $self->{items} }) - 1;
    $self->{cursor}++ if $self->{cursor} < $max;
    return $self->{cursor};
}

sub selected_item {
    my ($self) = @_;
    return undef unless @{ $self->{items} };
    return $self->{items}[ $self->{cursor} ];
}

1;
