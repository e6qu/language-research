module Main exposing (main)

import Browser
import Hello
import Html exposing (Html, div, h1, text)

main : Program () () ()
main =
    Browser.sandbox
        { init = ()
        , update = \_ _ -> ()
        , view = \_ -> view
        }

view : Html ()
view =
    div []
        [ h1 [] [ text (Hello.greet "Elm") ]
        ]
