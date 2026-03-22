unit module HelloCli;

sub parse-args(@args --> Hash) is export {
    my %opts = name => "world", shout => False;
    my $i = 0;
    while $i < @args.elems {
        given @args[$i] {
            when '--name'  { %opts<name> = @args[++$i] }
            when '--shout' { %opts<shout> = True }
        }
        $i++;
    }
    return %opts;
}

sub format-greeting(Str $name, Bool $shout --> Str) is export {
    my $msg = "Hello, $name!";
    $msg = $msg.uc if $shout;
    return $msg;
}
