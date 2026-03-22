module Main exposing (main)

import BarChart
import Browser
import Html exposing (Html, div, h1, p, text)
import Html.Attributes exposing (style)
import Http
import MetricsParser exposing (Metric)
import Time


type alias Model =
    { metrics : List Metric
    , error : Maybe String
    }


type Msg
    = Tick Time.Posix
    | GotMetrics (Result Http.Error String)


sampleData : String
sampleData =
    String.join "\n"
        [ "# HELP http_requests_total Total HTTP requests"
        , "# TYPE http_requests_total counter"
        , "http_requests_total 1027"
        , "http_errors_total 3"
        , "db_query_duration_ms 45.2"
        , "memory_usage_mb 128.5"
        , "active_connections 17"
        ]


init : () -> ( Model, Cmd Msg )
init _ =
    ( { metrics = MetricsParser.parse sampleData
      , error = Nothing
      }
    , fetchMetrics
    )


fetchMetrics : Cmd Msg
fetchMetrics =
    Http.get
        { url = "/metrics"
        , expect = Http.expectString GotMetrics
        }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick _ ->
            ( model, fetchMetrics )

        GotMetrics (Ok body) ->
            let
                parsed =
                    MetricsParser.parse body
            in
            if List.isEmpty parsed then
                ( model, Cmd.none )

            else
                ( { model | metrics = parsed, error = Nothing }, Cmd.none )

        GotMetrics (Err _) ->
            -- Keep showing existing metrics (sample data as fallback)
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 5000 Tick


view : Model -> Html Msg
view model =
    div [ style "font-family" "sans-serif", style "padding" "20px" ]
        [ h1 [] [ text "Hello Metrics Dashboard" ]
        , case model.error of
            Just err ->
                p [ style "color" "red" ] [ text err ]

            Nothing ->
                text ""
        , if List.isEmpty model.metrics then
            p [] [ text "No metrics available." ]

          else
            BarChart.view model.metrics
        ]


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }
