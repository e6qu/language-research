#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use TuiState;

my $state = TuiState->new("Option A", "Option B", "Option C", "Quit");

sub render {
    print "\033[2J\033[H";  # clear screen
    print "Use j/k to move, Enter to select, q to quit\n\n";
    my $i = 0;
    for my $item ($state->items) {
        if ($i == $state->cursor) {
            print " \033[7m> $item\033[0m\n";
        } else {
            print "   $item\n";
        }
        $i++;
    }
    print "\nSelected: " . ($state->selected_item // "none") . "\n";
}

# Raw terminal mode
system("stty", "-icanon", "-echo");
render();

while (1) {
    my $key;
    sysread(STDIN, $key, 1);
    if ($key eq 'q') { last }
    elsif ($key eq 'k') { $state->move_up }
    elsif ($key eq 'j') { $state->move_down }
    elsif ($key eq "\n") {
        print "\033[2J\033[H";
        print "You chose: " . $state->selected_item . "\n";
        last;
    }
    render();
}

system("stty", "icanon", "echo");
