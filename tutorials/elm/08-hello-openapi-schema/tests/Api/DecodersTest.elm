module Api.DecodersTest exposing (..)

import Api.Decoders exposing (encodeGreeting, greetingDecoder)
import Api.Types exposing (Greeting)
import Expect
import Json.Decode as Decode
import Json.Encode as Encode
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Greeting decoder"
        [ test "decodes valid JSON without timestamp" <|
            \_ ->
                let
                    json =
                        """{"message":"Hello"}"""

                    result =
                        Decode.decodeString greetingDecoder json
                in
                Expect.equal result (Ok { message = "Hello", timestamp = Nothing })
        , test "decodes valid JSON with timestamp" <|
            \_ ->
                let
                    json =
                        """{"message":"Hello","timestamp":"2026-03-21T00:00:00Z"}"""

                    result =
                        Decode.decodeString greetingDecoder json
                in
                Expect.equal result (Ok { message = "Hello", timestamp = Just "2026-03-21T00:00:00Z" })
        , test "fails when message field is missing" <|
            \_ ->
                let
                    json =
                        """{"timestamp":"2026-03-21T00:00:00Z"}"""

                    result =
                        Decode.decodeString greetingDecoder json
                in
                Expect.err result
        , test "encode/decode round-trip" <|
            \_ ->
                let
                    greeting =
                        { message = "Round trip", timestamp = Just "2026-03-21T12:00:00Z" }

                    encoded =
                        encodeGreeting greeting

                    decoded =
                        Decode.decodeValue greetingDecoder encoded
                in
                Expect.equal decoded (Ok greeting)
        ]
