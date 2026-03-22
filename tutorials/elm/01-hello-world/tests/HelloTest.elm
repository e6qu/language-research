module HelloTest exposing (..)

import Expect
import Hello
import Test exposing (Test, describe, test)

suite : Test
suite =
    describe "Hello.greet"
        [ test "empty string returns Hello, world!" <|
            \_ -> Hello.greet "" |> Expect.equal "Hello, world!"
        , test "with name returns greeting" <|
            \_ -> Hello.greet "Alice" |> Expect.equal "Hello, Alice!"
        , test "with Elm returns Hello, Elm!" <|
            \_ -> Hello.greet "Elm" |> Expect.equal "Hello, Elm!"
        ]
