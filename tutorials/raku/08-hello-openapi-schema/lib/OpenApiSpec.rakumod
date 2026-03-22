unit module OpenApiSpec;

sub spec(--> Hash) is export {
    return {
        openapi => "3.0.3",
        info => {
            title   => "Hello API",
            version => "1.0.0",
        },
        paths => {
            "/" => {
                get => {
                    summary  => "Root greeting",
                    responses => {
                        "200" => { description => "OK" },
                    },
                },
            },
            '/greet/{name}' => {
                get => {
                    summary    => "Greet by name",
                    parameters => [
                        {
                            name     => "name",
                            in       => "path",
                            required => True,
                            schema   => { type => "string" },
                        },
                    ],
                    responses => {
                        "200" => { description => "Greeting response" },
                    },
                },
            },
        },
    };
}

sub validate-name(Str $name --> Bool) is export {
    return so ($name.chars > 0 && $name.chars <= 100 && $name ~~ /^ <[a..zA..Z0..9_\-]>+ $/);
}

sub spec-to-json(--> Str) is export {
    return hash-to-json(spec());
}

sub hash-to-json($val --> Str) {
    given $val {
        when Hash {
            my @pairs = $val.sort(*.key).map: -> $p {
                qq["{$p.key}":{hash-to-json($p.value)}]
            };
            return '{' ~ @pairs.join(',') ~ '}';
        }
        when Array {
            my @items = $val.map: { hash-to-json($_) };
            return '[' ~ @items.join(',') ~ ']';
        }
        when Bool {
            return $val ?? 'true' !! 'false';
        }
        when Numeric {
            return $val.Str;
        }
        default {
            return qq["{ $val.Str.subst('"', '\\"', :g) }"];
        }
    }
}
