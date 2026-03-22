module HealthApi exposing (DependencyCheck, HealthResponse, HealthStatus(..), detailedHealthDecoder, healthDecoder, statusToColor)

import Json.Decode as Decode exposing (Decoder)


type HealthStatus
    = Healthy
    | Degraded
    | Unhealthy
    | Unknown


type alias HealthResponse =
    { status : HealthStatus }


type alias DependencyCheck =
    { name : String
    , status : HealthStatus
    }


healthDecoder : Decoder HealthResponse
healthDecoder =
    Decode.map HealthResponse
        (Decode.field "status" statusDecoder)


statusDecoder : Decoder HealthStatus
statusDecoder =
    Decode.string
        |> Decode.andThen
            (\s ->
                case s of
                    "ok" ->
                        Decode.succeed Healthy

                    "degraded" ->
                        Decode.succeed Degraded

                    "error" ->
                        Decode.succeed Unhealthy

                    _ ->
                        Decode.succeed Unknown
            )


detailedHealthDecoder : Decoder (List DependencyCheck)
detailedHealthDecoder =
    Decode.field "checks" (Decode.keyValuePairs (Decode.field "status" statusDecoder))
        |> Decode.map (List.map (\( name, status ) -> DependencyCheck name status))


statusToColor : HealthStatus -> String
statusToColor status =
    case status of
        Healthy ->
            "green"

        Degraded ->
            "orange"

        Unhealthy ->
            "red"

        Unknown ->
            "gray"
