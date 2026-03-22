port module Ports exposing (log)

import Json.Encode as Encode


port log : Encode.Value -> Cmd msg
