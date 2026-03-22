module ParallelFetch exposing (Model, Msg(..), init, update, buildRequests, isComplete)

import Http


type alias Model =
    { total : Int
    , completed : Int
    , results : List (Result String String)
    }


type Msg
    = GotResponse Int (Result Http.Error String)


init : Int -> Model
init n =
    { total = n, completed = 0, results = [] }


buildRequests : List String -> (Int -> Result Http.Error String -> Msg) -> Cmd Msg
buildRequests urls tagger =
    urls
        |> List.indexedMap
            (\i url ->
                Http.get
                    { url = url
                    , expect =
                        Http.expectString (\result -> tagger i result)
                    }
            )
        |> Cmd.batch


update : Msg -> Model -> Model
update msg model =
    case msg of
        GotResponse _ result ->
            { model
                | completed = model.completed + 1
                , results =
                    model.results
                        ++ [ Result.mapError httpErrorToString result ]
            }


isComplete : Model -> Bool
isComplete model =
    model.completed >= model.total


httpErrorToString : Http.Error -> String
httpErrorToString err =
    case err of
        Http.BadUrl u ->
            "Bad URL: " ++ u

        Http.Timeout ->
            "Timeout"

        Http.NetworkError ->
            "Network error"

        Http.BadStatus code ->
            "Bad status: " ++ String.fromInt code

        Http.BadBody body ->
            "Bad body: " ++ body
