module GridTest exposing (..)

import Expect
import Grid
import Test exposing (..)


suite : Test
suite =
    describe "Grid"
        [ describe "init"
            [ test "creates grid with correct dimensions" <|
                \_ ->
                    let
                        g =
                            Grid.init 10 20
                    in
                    Expect.equal ( Grid.rows g, Grid.cols g ) ( 10, 20 )
            , test "cursor starts at origin" <|
                \_ ->
                    Expect.equal (Grid.cursor (Grid.init 5 5)) ( 0, 0 )
            ]
        , describe "setCell / getCell"
            [ test "round-trip stores and retrieves a character" <|
                \_ ->
                    let
                        g =
                            Grid.init 5 5
                                |> Grid.setCell 2 3 'X'
                    in
                    Expect.equal (Grid.getCell 2 3 g) 'X'
            , test "unset cell returns space" <|
                \_ ->
                    Expect.equal (Grid.getCell 0 0 (Grid.init 5 5)) ' '
            ]
        , describe "moveCursor"
            [ test "moves cursor by delta" <|
                \_ ->
                    let
                        g =
                            Grid.init 10 10
                                |> Grid.moveCursor 3 4
                    in
                    Expect.equal (Grid.cursor g) ( 3, 4 )
            , test "clamps at top-left boundary" <|
                \_ ->
                    let
                        g =
                            Grid.init 10 10
                                |> Grid.moveCursor -5 -5
                    in
                    Expect.equal (Grid.cursor g) ( 0, 0 )
            , test "clamps at bottom-right boundary" <|
                \_ ->
                    let
                        g =
                            Grid.init 10 10
                                |> Grid.moveCursor 100 100
                    in
                    Expect.equal (Grid.cursor g) ( 9, 9 )
            ]
        , describe "writeChar"
            [ test "places char at cursor position" <|
                \_ ->
                    let
                        g =
                            Grid.init 5 5
                                |> Grid.writeChar 'A'
                    in
                    Expect.equal (Grid.getCell 0 0 g) 'A'
            , test "advances cursor to the right" <|
                \_ ->
                    let
                        g =
                            Grid.init 5 5
                                |> Grid.writeChar 'A'
                    in
                    Expect.equal (Grid.cursor g) ( 0, 1 )
            , test "wraps to next row at end of line" <|
                \_ ->
                    let
                        g =
                            Grid.init 5 3
                                |> Grid.writeChar 'A'
                                |> Grid.writeChar 'B'
                                |> Grid.writeChar 'C'
                    in
                    Expect.equal (Grid.cursor g) ( 1, 0 )
            ]
        ]
