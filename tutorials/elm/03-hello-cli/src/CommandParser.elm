module CommandParser exposing (Command(..), parse)


type Command
    = Help
    | Greet String
    | Echo String
    | Unknown String


parse : String -> Command
parse input =
    let
        trimmed =
            String.trim input

        parts =
            String.words trimmed
    in
    case parts of
        [ "help" ] ->
            Help

        "greet" :: rest ->
            Greet (String.join " " rest)

        "echo" :: rest ->
            Echo (String.join " " rest)

        _ ->
            Unknown trimmed
