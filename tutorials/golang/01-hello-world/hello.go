package main

import "fmt"

// Greet returns a greeting for the given name.
func Greet(name string) string {
	if name == "" {
		name = "World"
	}
	return fmt.Sprintf("Hello, %s!", name)
}
