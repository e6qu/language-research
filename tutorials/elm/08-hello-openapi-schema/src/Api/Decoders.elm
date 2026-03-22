module Api.Decoders exposing (encodeGreeting, greetingDecoder)

import Api.Types exposing (Greeting)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


greetingDecoder : Decoder Greeting
greetingDecoder =
    Decode.map2 Greeting
        (Decode.field "message" Decode.string)
        (Decode.maybe (Decode.field "timestamp" Decode.string))


encodeGreeting : Greeting -> Encode.Value
encodeGreeting g =
    Encode.object
        ([ ( "message", Encode.string g.message ) ]
            ++ (case g.timestamp of
                    Just ts ->
                        [ ( "timestamp", Encode.string ts ) ]

                    Nothing ->
                        []
               )
        )
