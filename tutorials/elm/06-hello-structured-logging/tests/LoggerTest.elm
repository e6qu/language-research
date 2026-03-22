module LoggerTest exposing (..)

import Expect
import Json.Decode as Decode
import Json.Encode as Encode
import Logger exposing (Level(..))
import Test exposing (..)


decodeField : String -> Decode.Decoder a -> Encode.Value -> Result Decode.Error a
decodeField field decoder value =
    Decode.decodeValue (Decode.field field decoder) value


suite : Test
suite =
    describe "Logger"
        [ test "encode Info produces message and level fields" <|
            \_ ->
                let
                    value =
                        Logger.encode Info "hello" []

                    message =
                        decodeField "message" Decode.string value

                    level =
                        decodeField "level" Decode.string value
                in
                Expect.equal
                    ( Ok "hello", Ok "info" )
                    ( message, level )
        , test "encode Error has level error" <|
            \_ ->
                let
                    value =
                        Logger.encode Error "fail" []

                    level =
                        decodeField "level" Decode.string value
                in
                Expect.equal (Ok "error") level
        , test "metadata is included in output" <|
            \_ ->
                let
                    value =
                        Logger.encode Info "test" [ ( "count", Encode.int 42 ) ]

                    count =
                        decodeField "count" Decode.int value
                in
                Expect.equal (Ok 42) count
        , test "info convenience function sets level to info" <|
            \_ ->
                let
                    value =
                        Logger.info "msg" []

                    level =
                        decodeField "level" Decode.string value
                in
                Expect.equal (Ok "info") level
        , test "warn convenience function sets level to warn" <|
            \_ ->
                let
                    value =
                        Logger.warn "msg" []

                    level =
                        decodeField "level" Decode.string value
                in
                Expect.equal (Ok "warn") level
        , test "error convenience function sets level to error" <|
            \_ ->
                let
                    value =
                        Logger.error "msg" []

                    level =
                        decodeField "level" Decode.string value
                in
                Expect.equal (Ok "error") level
        ]
