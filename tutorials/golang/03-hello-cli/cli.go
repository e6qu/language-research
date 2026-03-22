package main

import (
	"flag"
	"fmt"
	"strings"
)

type Config struct {
	Name  string
	Shout bool
}

func parseFlags(args []string) (Config, error) {
	fs := flag.NewFlagSet("hello-cli", flag.ContinueOnError)
	name := fs.String("name", "World", "name to greet")
	shout := fs.Bool("shout", false, "SHOUT the greeting")

	if err := fs.Parse(args); err != nil {
		return Config{}, err
	}
	return Config{Name: *name, Shout: *shout}, nil
}

func formatGreeting(cfg Config) string {
	msg := fmt.Sprintf("Hello, %s!", cfg.Name)
	if cfg.Shout {
		msg = strings.ToUpper(msg)
	}
	return msg
}
