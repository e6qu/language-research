module MetricsParserTest exposing (..)

import Expect
import MetricsParser exposing (Metric, parse, parseLine)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "MetricsParser"
        [ describe "parseLine"
            [ test "parses a valid metric line" <|
                \_ ->
                    parseLine "my_counter 42"
                        |> Expect.equal (Just { name = "my_counter", value = 42 })
            , test "ignores comment lines" <|
                \_ ->
                    parseLine "# HELP comment"
                        |> Expect.equal Nothing
            , test "ignores empty lines" <|
                \_ ->
                    parseLine ""
                        |> Expect.equal Nothing
            , test "parses float values" <|
                \_ ->
                    parseLine "request_duration 3.14"
                        |> Expect.equal (Just { name = "request_duration", value = 3.14 })
            ]
        , describe "parse"
            [ test "parses multi-line text into metrics" <|
                \_ ->
                    let
                        input =
                            "# HELP counter\nhttp_requests 100\nerrors 5"
                    in
                    parse input
                        |> Expect.equal
                            [ { name = "http_requests", value = 100 }
                            , { name = "errors", value = 5 }
                            ]
            , test "returns empty list for empty string" <|
                \_ ->
                    parse ""
                        |> Expect.equal []
            ]
        ]
