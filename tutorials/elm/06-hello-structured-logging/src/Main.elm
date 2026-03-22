module Main exposing (main)

import Browser
import Html exposing (Html, button, div, p, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Json.Encode as Encode
import Logger
import Ports


type alias Model =
    { clickCount : Int }


type Msg
    = ButtonClicked


init : () -> ( Model, Cmd Msg )
init _ =
    ( { clickCount = 0 }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ButtonClicked ->
            let
                newCount =
                    model.clickCount + 1
            in
            ( { model | clickCount = newCount }
            , Ports.log
                (Logger.info "Button clicked"
                    [ ( "count", Encode.int newCount ) ]
                )
            )


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick ButtonClicked ] [ text "Click me" ]
        , p [] [ text ("Clicks: " ++ String.fromInt model.clickCount) ]
        ]


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
