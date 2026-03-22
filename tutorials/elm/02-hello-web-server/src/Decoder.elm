module Decoder exposing (MessageResponse, decoder)

import Json.Decode as Decode exposing (Decoder)


type alias MessageResponse =
    { message : String }


decoder : Decoder MessageResponse
decoder =
    Decode.map MessageResponse
        (Decode.field "message" Decode.string)
