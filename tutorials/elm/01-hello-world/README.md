# 01 - Hello World

A minimal Elm application that displays a greeting on the page.

## Prerequisites

- Elm 0.19.1
- elm-test (`npm install -g elm-test`)

## What You Learn

- Elm project structure (`elm.json`, `src/`, `tests/`)
- Defining and exposing modules
- Type annotations
- Writing unit tests with `elm-test`
- Using `Browser.sandbox` to create a simple app

## Walkthrough

1. **`src/Hello.elm`** -- A pure function `greet` that takes a name and returns a greeting string. Returns "Hello, world!" for an empty string.
2. **`src/Main.elm`** -- The entry point. Uses `Browser.sandbox` with a minimal model/update/view. The view calls `Hello.greet "Elm"` and displays the result in an `h1` tag.
3. **`tests/HelloTest.elm`** -- Three tests verifying `greet` handles empty strings, regular names, and the specific "Elm" input.

## Running

```bash
bash run.sh
```

This runs the tests, then compiles `main.js`. Open `index.html` in a browser to see the app.

## Exercises

1. Add a text input so the user can type a name and see the greeting update live.
2. Handle whitespace-only input the same as empty input.
3. Add a test for a name containing special characters.
