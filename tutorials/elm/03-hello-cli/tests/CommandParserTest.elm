module CommandParserTest exposing (..)

import CommandParser exposing (Command(..), parse)
import Expect
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "CommandParser.parse"
        [ test "help returns Help" <|
            \_ ->
                parse "help"
                    |> Expect.equal Help
        , test "greet Alice returns Greet Alice" <|
            \_ ->
                parse "greet Alice"
                    |> Expect.equal (Greet "Alice")
        , test "echo hello world returns Echo hello world" <|
            \_ ->
                parse "echo hello world"
                    |> Expect.equal (Echo "hello world")
        , test "unknown returns Unknown unknown" <|
            \_ ->
                parse "unknown"
                    |> Expect.equal (Unknown "unknown")
        , test "empty string returns Unknown empty" <|
            \_ ->
                parse ""
                    |> Expect.equal (Unknown "")
        ]
