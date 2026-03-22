module Main exposing (main)

import Browser
import HealthApi exposing (DependencyCheck, HealthResponse, HealthStatus(..), detailedHealthDecoder, healthDecoder, statusToColor)
import Html exposing (Html, div, h1, h2, span, table, td, text, th, tr)
import Html.Attributes exposing (class, style)
import Http
import Time


type alias Model =
    { liveness : Maybe HealthStatus
    , readiness : Maybe HealthStatus
    , checks : List DependencyCheck
    }


type Msg
    = Tick Time.Posix
    | GotLiveness (Result Http.Error HealthResponse)
    | GotReadiness (Result Http.Error HealthResponse)
    | GotHealth (Result Http.Error (List DependencyCheck))


init : () -> ( Model, Cmd Msg )
init _ =
    ( { liveness = Nothing
      , readiness = Nothing
      , checks = []
      }
    , Cmd.batch [ fetchLiveness, fetchReadiness, fetchHealth ]
    )


fetchLiveness : Cmd Msg
fetchLiveness =
    Http.get
        { url = "/healthz"
        , expect = Http.expectJson GotLiveness healthDecoder
        }


fetchReadiness : Cmd Msg
fetchReadiness =
    Http.get
        { url = "/readyz"
        , expect = Http.expectJson GotReadiness healthDecoder
        }


fetchHealth : Cmd Msg
fetchHealth =
    Http.get
        { url = "/health"
        , expect = Http.expectJson GotHealth detailedHealthDecoder
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick _ ->
            ( model, Cmd.batch [ fetchLiveness, fetchReadiness, fetchHealth ] )

        GotLiveness (Ok resp) ->
            ( { model | liveness = Just resp.status }, Cmd.none )

        GotLiveness (Err _) ->
            ( { model | liveness = Just Unhealthy }, Cmd.none )

        GotReadiness (Ok resp) ->
            ( { model | readiness = Just resp.status }, Cmd.none )

        GotReadiness (Err _) ->
            ( { model | readiness = Just Unhealthy }, Cmd.none )

        GotHealth (Ok checks) ->
            ( { model | checks = checks }, Cmd.none )

        GotHealth (Err _) ->
            ( { model | checks = [] }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 5000 Tick


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ h1 [] [ text "Hello Health Dashboard" ]
        , div [ class "cards" ]
            [ statusCard "Liveness" "/healthz" model.liveness
            , statusCard "Readiness" "/readyz" model.readiness
            , statusCard "Health" "/health" (overallFromChecks model.checks)
            ]
        , h2 [] [ text "Dependency Checks" ]
        , if List.isEmpty model.checks then
            div [ class "placeholder" ] [ text "No backend running — waiting for /health response..." ]

          else
            checksTable model.checks
        ]


overallFromChecks : List DependencyCheck -> Maybe HealthStatus
overallFromChecks checks =
    if List.isEmpty checks then
        Nothing

    else if List.all (\c -> c.status == Healthy) checks then
        Just Healthy

    else if List.any (\c -> c.status == Unhealthy) checks then
        Just Unhealthy

    else
        Just Degraded


statusCard : String -> String -> Maybe HealthStatus -> Html Msg
statusCard title endpoint maybeStatus =
    let
        ( color, label ) =
            case maybeStatus of
                Just s ->
                    ( statusToColor s, statusLabel s )

                Nothing ->
                    ( "gray", "Pending..." )
    in
    div [ class "card" ]
        [ div [ class "card-title" ] [ text title ]
        , div [ class "card-endpoint" ] [ text endpoint ]
        , div [ class "status-row" ]
            [ span
                [ class "dot"
                , style "background-color" color
                ]
                []
            , span [] [ text label ]
            ]
        ]


statusLabel : HealthStatus -> String
statusLabel s =
    case s of
        Healthy ->
            "Healthy"

        Degraded ->
            "Degraded"

        Unhealthy ->
            "Unhealthy"

        Unknown ->
            "Unknown"


checksTable : List DependencyCheck -> Html Msg
checksTable checks =
    table [ class "checks-table" ]
        (tr []
            [ th [] [ text "Dependency" ]
            , th [] [ text "Status" ]
            ]
            :: List.map checkRow checks
        )


checkRow : DependencyCheck -> Html Msg
checkRow dep =
    tr []
        [ td [] [ text dep.name ]
        , td []
            [ span
                [ class "dot-sm"
                , style "background-color" (statusToColor dep.status)
                ]
                []
            , text (" " ++ statusLabel dep.status)
            ]
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
