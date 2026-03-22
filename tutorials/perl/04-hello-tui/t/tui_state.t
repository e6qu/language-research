use strict;
use warnings;
use Test::More tests => 8;
use lib 'lib';
use TuiState;

my $s = TuiState->new("A", "B", "C");

is($s->cursor, 0, "initial cursor at 0");
is($s->selected_item, "A", "initial selection");

$s->move_down;
is($s->cursor, 1, "moved down to 1");
is($s->selected_item, "B", "selected B");

$s->move_down;
$s->move_down;  # should clamp
is($s->cursor, 2, "clamped at max");

$s->move_up;
is($s->cursor, 1, "moved up to 1");

$s->move_up;
$s->move_up;  # should clamp at 0
is($s->cursor, 0, "clamped at 0");

my $empty = TuiState->new();
is($empty->selected_item, undef, "empty state returns undef");
