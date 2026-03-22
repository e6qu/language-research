package main

import (
	"fmt"
	"os"

	"golang.org/x/term"
)

func main() {
	items := []Item{
		{Label: "Go"},
		{Label: "Rust"},
		{Label: "Python"},
		{Label: "Elixir"},
		{Label: "TypeScript"},
	}

	model := NewModel(items)

	// Put terminal in raw mode
	oldState, err := term.MakeRaw(int(os.Stdin.Fd()))
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: %v\n", err)
		os.Exit(1)
	}
	defer term.Restore(int(os.Stdin.Fd()), oldState)

	buf := make([]byte, 3)
	for !model.Quit {
		fmt.Print(model.Render())

		n, err := os.Stdin.Read(buf)
		if err != nil {
			break
		}

		if n == 1 {
			switch buf[0] {
			case 'q', 'Q':
				model.Quit = true
			case 13: // Enter
				model.Select()
			case 'k':
				model.MoveUp()
			case 'j':
				model.MoveDown()
			}
		} else if n == 3 && buf[0] == 27 && buf[1] == 91 {
			switch buf[2] {
			case 65: // Up arrow
				model.MoveUp()
			case 66: // Down arrow
				model.MoveDown()
			}
		}
	}

	// Clear screen on exit
	fmt.Print("\033[2J\033[H")
	if sel := model.SelectedItem(); sel != "" {
		fmt.Printf("You chose: %s\r\n", sel)
	} else {
		fmt.Print("No selection made.\r\n")
	}
}
