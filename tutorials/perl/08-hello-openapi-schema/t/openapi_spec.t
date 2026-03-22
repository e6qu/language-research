use strict;
use warnings;
use Test::More tests => 8;
use JSON::PP;
use lib 'lib';
use OpenApiSpec;

{
    my $s = OpenApiSpec::spec();
    is($s->{openapi}, "3.0.3", "openapi version");
    is($s->{info}{title}, "Hello API", "api title");
    ok(exists $s->{paths}{"/"}, "root path exists");
    ok(exists $s->{paths}{"/greet/{name}"}, "greet path exists");
}

{
    my $json = OpenApiSpec::to_json();
    my $data = decode_json($json);
    is($data->{openapi}, "3.0.3", "JSON roundtrip");
}

{
    ok(OpenApiSpec::validate_name("Alice"), "valid name");
    ok(!OpenApiSpec::validate_name(""), "empty name invalid");
    ok(!OpenApiSpec::validate_name("a<script>"), "special chars invalid");
}
