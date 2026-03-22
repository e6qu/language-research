module Api.Types exposing (Greeting)


type alias Greeting =
    { message : String
    , timestamp : Maybe String
    }
