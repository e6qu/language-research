module Hello exposing (greet)

greet : String -> String
greet name =
    if String.isEmpty name then
        "Hello, world!"
    else
        "Hello, " ++ name ++ "!"
