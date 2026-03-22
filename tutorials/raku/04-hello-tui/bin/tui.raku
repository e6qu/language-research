use lib 'lib';
use TuiState;

my $state = TuiState.new;
say "TUI State Demo (non-interactive)";
say "---";
say $state.render;
say "---";
say "Selected: {$state.selected-item}";
say "";
say "After moving down twice:";
$state = $state.move-down.move-down;
say $state.render;
say "Selected: {$state.selected-item}";
