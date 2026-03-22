module Logger exposing (Level(..), encode, error, info, warn)

import Json.Encode as Encode


type Level
    = Debug
    | Info
    | Warn
    | Error


encode : Level -> String -> List ( String, Encode.Value ) -> Encode.Value
encode level message metadata =
    Encode.object
        ([ ( "message", Encode.string message )
         , ( "level", Encode.string (levelToString level) )
         ]
            ++ metadata
        )


levelToString : Level -> String
levelToString level =
    case level of
        Debug ->
            "debug"

        Info ->
            "info"

        Warn ->
            "warn"

        Error ->
            "error"


info : String -> List ( String, Encode.Value ) -> Encode.Value
info msg meta =
    encode Info msg meta


warn : String -> List ( String, Encode.Value ) -> Encode.Value
warn msg meta =
    encode Warn msg meta


error : String -> List ( String, Encode.Value ) -> Encode.Value
error msg meta =
    encode Error msg meta
