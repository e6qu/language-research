module Main exposing (main)

import Api.Requests exposing (fetchGreeting)
import Api.Types exposing (Greeting)
import Browser
import Html exposing (Html, button, div, h1, input, p, text)
import Html.Attributes exposing (placeholder, value)
import Html.Events exposing (onClick, onInput)
import Http


type alias Model =
    { name : String
    , greeting : Maybe Greeting
    , error : Maybe String
    }


type Msg
    = UpdateName String
    | FetchGreeting
    | GotGreeting (Result Http.Error Greeting)


init : () -> ( Model, Cmd Msg )
init _ =
    ( { name = "", greeting = Nothing, error = Nothing }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateName name ->
            ( { model | name = name }, Cmd.none )

        FetchGreeting ->
            ( { model | error = Nothing }, fetchGreeting model.name GotGreeting )

        GotGreeting (Ok greeting) ->
            ( { model | greeting = Just greeting, error = Nothing }, Cmd.none )

        GotGreeting (Err _) ->
            ( { model | error = Just "Failed to fetch greeting." }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Hello OpenAPI Client" ]
        , input [ placeholder "Enter name", value model.name, onInput UpdateName ] []
        , button [ onClick FetchGreeting ] [ text "Greet" ]
        , case model.greeting of
            Just g ->
                div []
                    [ p [] [ text g.message ]
                    , case g.timestamp of
                        Just ts ->
                            p [] [ text ("Timestamp: " ++ ts) ]

                        Nothing ->
                            text ""
                    ]

            Nothing ->
                text ""
        , case model.error of
            Just err ->
                p [] [ text err ]

            Nothing ->
                text ""
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
