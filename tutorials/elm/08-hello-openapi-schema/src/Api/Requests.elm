module Api.Requests exposing (fetchGreeting)

import Api.Decoders exposing (greetingDecoder)
import Api.Types exposing (Greeting)
import Http
import Url.Builder


fetchGreeting : String -> (Result Http.Error Greeting -> msg) -> Cmd msg
fetchGreeting name toMsg =
    Http.get
        { url =
            Url.Builder.absolute [ "api", "greet" ]
                [ Url.Builder.string "name" name ]
        , expect = Http.expectJson toMsg greetingDecoder
        }
