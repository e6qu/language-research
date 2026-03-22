module ParallelFetchTest exposing (..)

import Expect
import Http
import ParallelFetch exposing (Model, Msg(..), init, isComplete, update)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "ParallelFetch"
        [ test "init 5 has total=5 and completed=0" <|
            \_ ->
                let
                    model =
                        init 5
                in
                Expect.all
                    [ \m -> Expect.equal 5 m.total
                    , \m -> Expect.equal 0 m.completed
                    ]
                    model
        , test "update with GotResponse increments completed" <|
            \_ ->
                let
                    model =
                        init 3

                    updated =
                        update (GotResponse 0 (Ok "body")) model
                in
                Expect.equal 1 updated.completed
        , test "isComplete is false when completed < total" <|
            \_ ->
                let
                    model =
                        init 3
                in
                Expect.equal False (isComplete model)
        , test "isComplete is true when completed >= total" <|
            \_ ->
                let
                    model =
                        { total = 2, completed = 2, results = [] }
                in
                Expect.equal True (isComplete model)
        ]
