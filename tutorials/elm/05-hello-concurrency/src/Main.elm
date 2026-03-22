module Main exposing (main)

import Browser
import Html exposing (Html, div, h1, h2, li, p, text, ul)
import Html.Attributes exposing (style)
import ParallelFetch
import Time


type alias Model =
    { fetch : ParallelFetch.Model
    , ticks : Int
    }


type Msg
    = FetchMsg ParallelFetch.Msg
    | Tick Time.Posix


urls : List String
urls =
    List.map
        (\i -> "https://jsonplaceholder.typicode.com/posts/" ++ String.fromInt i)
        (List.range 1 5)


init : () -> ( Model, Cmd Msg )
init _ =
    let
        fetchModel =
            ParallelFetch.init (List.length urls)

        cmds =
            ParallelFetch.buildRequests urls ParallelFetch.GotResponse
                |> Cmd.map FetchMsg
    in
    ( { fetch = fetchModel, ticks = 0 }, cmds )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchMsg fetchMsg ->
            ( { model | fetch = ParallelFetch.update fetchMsg model.fetch }
            , Cmd.none
            )

        Tick _ ->
            ( { model | ticks = model.ticks + 1 }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 1000 Tick


view : Model -> Html Msg
view model =
    let
        fetch =
            model.fetch

        pct =
            if fetch.total == 0 then
                0

            else
                toFloat fetch.completed / toFloat fetch.total * 100

        pctStr =
            String.fromInt (round pct) ++ "%"
    in
    div [ style "font-family" "sans-serif", style "max-width" "600px", style "margin" "2em auto" ]
        [ h1 [] [ text "Hello Async" ]
        , h2 [] [ text "Progress" ]
        , div
            [ style "background" "#eee"
            , style "border-radius" "4px"
            , style "overflow" "hidden"
            , style "height" "24px"
            ]
            [ div
                [ style "background" "#4caf50"
                , style "height" "100%"
                , style "width" pctStr
                , style "transition" "width 0.3s"
                ]
                []
            ]
        , p []
            [ text
                (String.fromInt fetch.completed
                    ++ " / "
                    ++ String.fromInt fetch.total
                    ++ " completed"
                )
            ]
        , p [] [ text ("Ticks: " ++ String.fromInt model.ticks) ]
        , h2 [] [ text "Results" ]
        , ul [] (List.indexedMap viewResult fetch.results)
        ]


viewResult : Int -> Result String String -> Html Msg
viewResult i result =
    case result of
        Ok body ->
            li []
                [ text
                    ("#"
                        ++ String.fromInt (i + 1)
                        ++ ": "
                        ++ String.left 80 body
                        ++ "..."
                    )
                ]

        Err err ->
            li [ style "color" "red" ]
                [ text ("#" ++ String.fromInt (i + 1) ++ ": Error - " ++ err) ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
