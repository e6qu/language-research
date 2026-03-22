package main

import "testing"

func TestParseFlags(t *testing.T) {
	tests := []struct {
		name     string
		args     []string
		wantCfg  Config
		wantErr  bool
	}{
		{"defaults", []string{}, Config{Name: "World", Shout: false}, false},
		{"custom name", []string{"-name", "Go"}, Config{Name: "Go", Shout: false}, false},
		{"shout flag", []string{"-shout"}, Config{Name: "World", Shout: true}, false},
		{"both flags", []string{"-name", "Gopher", "-shout"}, Config{Name: "Gopher", Shout: true}, false},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			cfg, err := parseFlags(tt.args)
			if (err != nil) != tt.wantErr {
				t.Fatalf("parseFlags(%v) error = %v, wantErr %v", tt.args, err, tt.wantErr)
			}
			if cfg != tt.wantCfg {
				t.Errorf("parseFlags(%v) = %+v, want %+v", tt.args, cfg, tt.wantCfg)
			}
		})
	}
}

func TestFormatGreeting(t *testing.T) {
	tests := []struct {
		name string
		cfg  Config
		want string
	}{
		{"normal", Config{Name: "World", Shout: false}, "Hello, World!"},
		{"shout", Config{Name: "Go", Shout: true}, "HELLO, GO!"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := formatGreeting(tt.cfg)
			if got != tt.want {
				t.Errorf("formatGreeting(%+v) = %q, want %q", tt.cfg, got, tt.want)
			}
		})
	}
}
