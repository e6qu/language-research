module Main exposing (main)

import Array
import Browser
import Browser.Events
import Grid exposing (Grid)
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class, style)
import Json.Decode as Decode


type alias Model =
    Grid


type Msg
    = KeyPress String


init : () -> ( Model, Cmd Msg )
init _ =
    ( Grid.init 24 80, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KeyPress key ->
            case key of
                "ArrowUp" ->
                    ( Grid.moveCursor -1 0 model, Cmd.none )

                "ArrowDown" ->
                    ( Grid.moveCursor 1 0 model, Cmd.none )

                "ArrowLeft" ->
                    ( Grid.moveCursor 0 -1 model, Cmd.none )

                "ArrowRight" ->
                    ( Grid.moveCursor 0 1 model, Cmd.none )

                _ ->
                    case String.uncons key of
                        Just ( ch, "" ) ->
                            ( Grid.writeChar ch model, Cmd.none )

                        _ ->
                            ( model, Cmd.none )


view : Model -> Html Msg
view model =
    let
        ( curRow, curCol ) =
            Grid.cursor model

        renderCell row col =
            let
                ch =
                    Grid.getCell row col model

                isCursor =
                    row == curRow && col == curCol
            in
            span
                [ class
                    (if isCursor then
                        "cell cursor"

                     else
                        "cell"
                    )
                ]
                [ text (String.fromChar ch) ]

        renderRow row =
            div [ class "row" ]
                (List.map (renderCell row) (List.range 0 (Grid.cols model - 1)))
    in
    div [ class "grid" ]
        (List.map renderRow (List.range 0 (Grid.rows model - 1)))


subscriptions : Model -> Sub Msg
subscriptions _ =
    Browser.Events.onKeyDown
        (Decode.field "key" Decode.string |> Decode.map KeyPress)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
