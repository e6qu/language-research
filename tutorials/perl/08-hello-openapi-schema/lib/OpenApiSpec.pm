package OpenApiSpec;
use strict;
use warnings;
use JSON::PP;

sub spec {
    return {
        openapi => "3.0.3",
        info    => {
            title   => "Hello API",
            version => "1.0.0",
        },
        paths => {
            "/" => {
                get => {
                    summary   => "Hello world",
                    responses => {
                        200 => {
                            description => "Successful response",
                            content     => {
                                "application/json" => {
                                    schema => {
                                        type       => "object",
                                        properties => {
                                            message => { type => "string" },
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
            },
            "/greet/{name}" => {
                get => {
                    summary    => "Greet by name",
                    parameters => [
                        {
                            name     => "name",
                            in       => "path",
                            required => JSON::PP::true,
                            schema   => { type => "string" },
                        },
                    ],
                    responses => {
                        200 => {
                            description => "Greeting response",
                        },
                    },
                },
            },
        },
    };
}

sub to_json {
    return JSON::PP->new->pretty->canonical->encode(spec());
}

sub validate_name {
    my ($name) = @_;
    return 0 if !defined($name) || $name eq "";
    return 0 if $name =~ /[^a-zA-Z0-9_\- ]/;
    return 0 if length($name) > 100;
    return 1;
}

1;
