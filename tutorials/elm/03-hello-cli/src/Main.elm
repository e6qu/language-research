module Main exposing (main)

import Browser
import CommandParser exposing (Command(..), parse)
import Html exposing (Html, div, input, text)
import Html.Attributes exposing (autofocus, placeholder, style, type_, value)
import Html.Events exposing (onInput)
import Json.Decode as Decode


type alias Model =
    { input : String
    , history : List ( String, String )
    }


type Msg
    = InputChanged String
    | Submit


init : () -> ( Model, Cmd Msg )
init _ =
    ( { input = "", history = [] }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputChanged val ->
            ( { model | input = val }, Cmd.none )

        Submit ->
            let
                output =
                    executeCommand (parse model.input)

                entry =
                    ( model.input, output )
            in
            ( { model | input = "", history = entry :: model.history }, Cmd.none )


executeCommand : Command -> String
executeCommand cmd =
    case cmd of
        Help ->
            "Commands: help, greet <name>, echo <text>"

        Greet name ->
            "Hello, " ++ name ++ "!"

        Echo txt ->
            txt

        Unknown c ->
            "Unknown command: " ++ c


onEnter : Msg -> Html.Attribute Msg
onEnter msg =
    Html.Events.on "keydown"
        (Decode.field "key" Decode.string
            |> Decode.andThen
                (\key ->
                    if key == "Enter" then
                        Decode.succeed msg

                    else
                        Decode.fail ""
                )
        )


view : Model -> Html Msg
view model =
    div
        [ style "background" "#1e1e1e"
        , style "color" "#0f0"
        , style "font-family" "monospace"
        , style "padding" "20px"
        , style "min-height" "100vh"
        , style "box-sizing" "border-box"
        , style "display" "flex"
        , style "flex-direction" "column"
        ]
        [ div [ style "flex" "1", style "overflow-y" "auto" ]
            (List.map viewEntry (List.reverse model.history))
        , div [ style "display" "flex", style "align-items" "center" ]
            [ text "> "
            , input
                [ type_ "text"
                , value model.input
                , onInput InputChanged
                , onEnter Submit
                , autofocus True
                , placeholder "type a command..."
                , style "background" "transparent"
                , style "border" "none"
                , style "color" "#0f0"
                , style "font-family" "monospace"
                , style "font-size" "inherit"
                , style "outline" "none"
                , style "flex" "1"
                ]
                []
            ]
        ]


viewEntry : ( String, String ) -> Html Msg
viewEntry ( cmd, output ) =
    div [ style "margin-bottom" "4px" ]
        [ div [] [ text ("> " ++ cmd) ]
        , div [ style "color" "#ccc" ] [ text output ]
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
