module HealthApiTest exposing (..)

import Expect
import HealthApi exposing (HealthStatus(..), healthDecoder, statusToColor)
import Json.Decode as Decode
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "HealthApi"
        [ describe "healthDecoder"
            [ test "decodes {\"status\":\"ok\"} to Healthy" <|
                \_ ->
                    Decode.decodeString healthDecoder """{"status":"ok"}"""
                        |> Result.map .status
                        |> Expect.equal (Ok Healthy)
            , test "decodes {\"status\":\"degraded\"} to Degraded" <|
                \_ ->
                    Decode.decodeString healthDecoder """{"status":"degraded"}"""
                        |> Result.map .status
                        |> Expect.equal (Ok Degraded)
            , test "decodes {\"status\":\"error\"} to Unhealthy" <|
                \_ ->
                    Decode.decodeString healthDecoder """{"status":"error"}"""
                        |> Result.map .status
                        |> Expect.equal (Ok Unhealthy)
            ]
        , describe "statusToColor"
            [ test "Healthy is green" <|
                \_ ->
                    statusToColor Healthy
                        |> Expect.equal "green"
            , test "Degraded is orange" <|
                \_ ->
                    statusToColor Degraded
                        |> Expect.equal "orange"
            ]
        ]
