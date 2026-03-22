package main

import "fmt"

// Item represents a selectable menu item.
type Item struct {
	Label string
}

// Model holds the TUI state.
type Model struct {
	Items    []Item
	Cursor   int
	Selected int // -1 means nothing selected
	Quit     bool
}

// NewModel creates a new model with the given items.
func NewModel(items []Item) *Model {
	return &Model{
		Items:    items,
		Cursor:   0,
		Selected: -1,
	}
}

// MoveUp moves the cursor up.
func (m *Model) MoveUp() {
	if m.Cursor > 0 {
		m.Cursor--
	}
}

// MoveDown moves the cursor down.
func (m *Model) MoveDown() {
	if m.Cursor < len(m.Items)-1 {
		m.Cursor++
	}
}

// Select selects the item at the cursor.
func (m *Model) Select() {
	m.Selected = m.Cursor
}

// SelectedItem returns the selected item label, or "" if none.
func (m *Model) SelectedItem() string {
	if m.Selected < 0 || m.Selected >= len(m.Items) {
		return ""
	}
	return m.Items[m.Selected].Label
}

// Render produces the ANSI string for the current state.
func (m *Model) Render() string {
	out := "\033[2J\033[H" // clear screen, move to top
	out += "Use ↑/↓ to navigate, Enter to select, q to quit\n\n"

	for i, item := range m.Items {
		cursor := "  "
		if i == m.Cursor {
			cursor = "▸ "
		}
		check := " "
		if i == m.Selected {
			check = "✓"
		}
		out += fmt.Sprintf(" %s[%s] %s\n", cursor, check, item.Label)
	}

	if m.Selected >= 0 {
		out += fmt.Sprintf("\nYou selected: %s\n", m.Items[m.Selected].Label)
	}
	return out
}
