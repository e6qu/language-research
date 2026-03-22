module Grid exposing (Grid, Cell, init, setCell, getCell, moveCursor, writeChar, rows, cols, cursor)

import Array exposing (Array)


type alias Cell =
    Char


type alias Grid =
    { cells : Array (Array Cell)
    , cursorRow : Int
    , cursorCol : Int
    , numRows : Int
    , numCols : Int
    }


init : Int -> Int -> Grid
init r c =
    { cells = Array.repeat r (Array.repeat c ' ')
    , cursorRow = 0
    , cursorCol = 0
    , numRows = r
    , numCols = c
    }


setCell : Int -> Int -> Cell -> Grid -> Grid
setCell row col ch grid =
    case Array.get row grid.cells of
        Just rowArray ->
            { grid | cells = Array.set row (Array.set col ch rowArray) grid.cells }

        Nothing ->
            grid


getCell : Int -> Int -> Grid -> Cell
getCell row col grid =
    case Array.get row grid.cells of
        Just rowArray ->
            Array.get col rowArray |> Maybe.withDefault ' '

        Nothing ->
            ' '


moveCursor : Int -> Int -> Grid -> Grid
moveCursor dr dc grid =
    { grid
        | cursorRow = clamp 0 (grid.numRows - 1) (grid.cursorRow + dr)
        , cursorCol = clamp 0 (grid.numCols - 1) (grid.cursorCol + dc)
    }


writeChar : Char -> Grid -> Grid
writeChar ch grid =
    let
        updated =
            setCell grid.cursorRow grid.cursorCol ch grid

        nextCol =
            grid.cursorCol + 1
    in
    if nextCol >= grid.numCols then
        if grid.cursorRow + 1 < grid.numRows then
            { updated | cursorRow = grid.cursorRow + 1, cursorCol = 0 }

        else
            { updated | cursorCol = grid.numCols - 1 }

    else
        { updated | cursorCol = nextCol }


rows : Grid -> Int
rows grid =
    grid.numRows


cols : Grid -> Int
cols grid =
    grid.numCols


cursor : Grid -> ( Int, Int )
cursor grid =
    ( grid.cursorRow, grid.cursorCol )
