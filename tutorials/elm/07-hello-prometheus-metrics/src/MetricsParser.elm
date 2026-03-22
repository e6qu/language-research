module MetricsParser exposing (Metric, parse, parseLine)


type alias Metric =
    { name : String
    , value : Float
    }


parse : String -> List Metric
parse text =
    text
        |> String.lines
        |> List.filterMap parseLine


parseLine : String -> Maybe Metric
parseLine line =
    if String.startsWith "#" line then
        Nothing

    else
        case String.words (String.trim line) of
            [ name, valueStr ] ->
                String.toFloat valueStr
                    |> Maybe.map (\v -> { name = name, value = v })

            _ ->
                Nothing
