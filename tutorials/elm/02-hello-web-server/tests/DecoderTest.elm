module DecoderTest exposing (..)

import Decoder exposing (MessageResponse, decoder)
import Expect
import Json.Decode as Decode
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Decoder"
        [ test "decodes valid JSON with message field" <|
            \_ ->
                let
                    json =
                        """{"message":"hello"}"""

                    result =
                        Decode.decodeString decoder json
                in
                Expect.equal (Ok { message = "hello" }) result
        , test "fails when message field is missing" <|
            \_ ->
                let
                    json =
                        """{"other":"value"}"""

                    result =
                        Decode.decodeString decoder json
                in
                Expect.err result
        , test "ignores extra fields" <|
            \_ ->
                let
                    json =
                        """{"message":"hello","extra":"ignored"}"""

                    result =
                        Decode.decodeString decoder json
                in
                Expect.equal (Ok { message = "hello" }) result
        ]
