use lib 'lib';
use HelloCli;

sub MAIN(Str :$name = "world", Bool :$shout = False) {
    say format-greeting($name, $shout);
}
