module BarChart exposing (view)

import MetricsParser exposing (Metric)
import Svg exposing (Svg, g, rect, svg, text, text_)
import Svg.Attributes
    exposing
        ( fill
        , fontFamily
        , fontSize
        , height
        , textAnchor
        , viewBox
        , width
        , x
        , y
        )


barHeight : Float
barHeight =
    30


barSpacing : Float
barSpacing =
    8


labelWidth : Float
labelWidth =
    200


chartWidth : Float
chartWidth =
    600


maxBarWidth : Float
maxBarWidth =
    chartWidth - labelWidth - 80


view : List Metric -> Svg msg
view metrics =
    let
        totalHeight =
            toFloat (List.length metrics) * (barHeight + barSpacing) + barSpacing

        maxValue =
            metrics
                |> List.map .value
                |> List.maximum
                |> Maybe.withDefault 1
                |> max 1

        bars =
            List.indexedMap (viewBar maxValue) metrics
    in
    svg
        [ width (String.fromFloat chartWidth)
        , height (String.fromFloat (max 40 totalHeight))
        , viewBox ("0 0 " ++ String.fromFloat chartWidth ++ " " ++ String.fromFloat (max 40 totalHeight))
        ]
        bars


viewBar : Float -> Int -> Metric -> Svg msg
viewBar maxValue index metric =
    let
        yPos =
            toFloat index * (barHeight + barSpacing) + barSpacing

        barW =
            (metric.value / maxValue) * maxBarWidth |> max 2

        labelY =
            yPos + barHeight / 2 + 5
    in
    g []
        [ text_
            [ x (String.fromFloat (labelWidth - 8))
            , y (String.fromFloat labelY)
            , textAnchor "end"
            , fontSize "14"
            , fontFamily "monospace"
            , fill "#333"
            ]
            [ text metric.name ]
        , rect
            [ x (String.fromFloat labelWidth)
            , y (String.fromFloat yPos)
            , width (String.fromFloat barW)
            , height (String.fromFloat barHeight)
            , fill "#4a90d9"
            ]
            []
        , text_
            [ x (String.fromFloat (labelWidth + barW + 6))
            , y (String.fromFloat labelY)
            , fontSize "13"
            , fontFamily "monospace"
            , fill "#555"
            ]
            [ text (String.fromFloat metric.value) ]
        ]
