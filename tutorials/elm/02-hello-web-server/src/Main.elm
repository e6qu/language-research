module Main exposing (main)

import Browser
import Decoder exposing (MessageResponse, decoder)
import Html exposing (Html, div, h1, p, text)
import Html.Attributes exposing (style)
import Http


type Model
    = Loading
    | Success String
    | Failure String


type Msg
    = GotResponse (Result Http.Error MessageResponse)


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , Http.get
        { url = "https://httpbin.org/get"
        , expect = Http.expectJson GotResponse decoder
        }
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        GotResponse (Ok response) ->
            ( Success response.message, Cmd.none )

        GotResponse (Err err) ->
            ( Failure (httpErrorToString err), Cmd.none )


httpErrorToString : Http.Error -> String
httpErrorToString err =
    case err of
        Http.BadUrl url ->
            "Bad URL: " ++ url

        Http.Timeout ->
            "Request timed out"

        Http.NetworkError ->
            "Network error"

        Http.BadStatus status ->
            "Bad status: " ++ String.fromInt status

        Http.BadBody body ->
            "Bad body: " ++ body


view : Model -> Html Msg
view model =
    div [ style "font-family" "sans-serif", style "padding" "2rem" ]
        [ h1 [] [ text "Hello Web Server" ]
        , case model of
            Loading ->
                p [] [ text "Loading..." ]

            Success message ->
                p [ style "color" "green" ] [ text message ]

            Failure error ->
                p [ style "color" "red" ] [ text error ]
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }
