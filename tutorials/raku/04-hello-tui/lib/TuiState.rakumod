unit class TuiState;

has @.items = <Raku Perl Elixir Erlang Lua>;
has Int $.cursor = 0;

method move-down(--> TuiState) {
    my $new-cursor = min($!cursor + 1, @!items.elems - 1);
    return TuiState.new(:@!items, :cursor($new-cursor));
}

method move-up(--> TuiState) {
    my $new-cursor = max($!cursor - 1, 0);
    return TuiState.new(:@!items, :cursor($new-cursor));
}

method selected-item(--> Str) {
    return @!items[$!cursor];
}

method render(--> Str) {
    my @lines;
    for @!items.kv -> $i, $item {
        my $marker = $i == $!cursor ?? '>' !! ' ';
        @lines.push("$marker $item");
    }
    return @lines.join("\n");
}
