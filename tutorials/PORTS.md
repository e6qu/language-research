# Port Assignments

Each language uses a unique port range to avoid conflicts when running e2e tests.

| Language | Base Port | 02-web | 07-metrics | 08-openapi | 09-health |
|---|---|---|---|---|---|
| **Elixir** | 4000 | 4000 | 4001 | 4002 | 4003 |
| **Erlang** | 8080 | 8080 | 8081 | 8082 | 8083 |
| **Elm** | — | — | — | — | — |
| **Lua** | 4010 | 4010 | 4011 | 4012 | 4013 |
| **Tcl** | 4020 | 4020 | 4021 | 4022 | 4023 |
| **Perl** | 4030 | 4030 | 4031 | 4032 | 4033 |
| **Raku** | 4040 | 4040 | 4041 | 4042 | 4043 |
| **Rust** | 4050 | 4050 | 4051 | 4052 | 4053 |
| **Rust-WASM** | — | — | — | — | — |
| **Go** | 4060 | 4060 | 4061 | 4062 | 4063 |
| **Java** | 4070 | 4070 | 4071 | 4072 | 4073 |
| **Spring Boot** | 4080 | 4080 | 4081 | 4082 | 4083 |
| **Quarkus** | 4090 | 4090 | 4091 | 4092 | 4093 |
| **Clojure** | 4100 | 4100 | 4101 | 4102 | 4103 |
| **Zig** | 4110 | 4110 | 4111 | 4112 | 4113 |
| **D** | 4120 | 4120 | 4121 | 4122 | 4123 |
| **C3** | — | — | — | — | — |
| **Scheme** | 4140 | 4140 | 4141 | 4142 | 4143 |
| **Common Lisp** | 4150 | 4150 | 4151 | 4152 | 4153 |

Languages marked `—` do not have HTTP server tutorials (browser-only or no server).
