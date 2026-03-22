unit module Hello;

sub greet(Str $name = "") is export {
    return $name eq "" ?? "Hello, world!" !! "Hello, $name!";
}
