package main

import "testing"

func TestNewModel(t *testing.T) {
	items := []Item{{Label: "A"}, {Label: "B"}}
	m := NewModel(items)

	if m.Cursor != 0 {
		t.Errorf("initial cursor = %d, want 0", m.Cursor)
	}
	if m.Selected != -1 {
		t.Errorf("initial selected = %d, want -1", m.Selected)
	}
	if len(m.Items) != 2 {
		t.Errorf("items count = %d, want 2", len(m.Items))
	}
}

func TestMoveUpDown(t *testing.T) {
	items := []Item{{Label: "A"}, {Label: "B"}, {Label: "C"}}
	m := NewModel(items)

	m.MoveDown()
	if m.Cursor != 1 {
		t.Errorf("after MoveDown, cursor = %d, want 1", m.Cursor)
	}

	m.MoveDown()
	if m.Cursor != 2 {
		t.Errorf("after MoveDown, cursor = %d, want 2", m.Cursor)
	}

	// Should not go past end
	m.MoveDown()
	if m.Cursor != 2 {
		t.Errorf("after MoveDown at end, cursor = %d, want 2", m.Cursor)
	}

	m.MoveUp()
	if m.Cursor != 1 {
		t.Errorf("after MoveUp, cursor = %d, want 1", m.Cursor)
	}

	// Go to top and try going past
	m.MoveUp()
	m.MoveUp()
	if m.Cursor != 0 {
		t.Errorf("after MoveUp at top, cursor = %d, want 0", m.Cursor)
	}
}

func TestSelect(t *testing.T) {
	items := []Item{{Label: "Go"}, {Label: "Rust"}}
	m := NewModel(items)

	m.Select()
	if m.Selected != 0 {
		t.Errorf("selected = %d, want 0", m.Selected)
	}
	if m.SelectedItem() != "Go" {
		t.Errorf("selectedItem = %q, want %q", m.SelectedItem(), "Go")
	}

	m.MoveDown()
	m.Select()
	if m.SelectedItem() != "Rust" {
		t.Errorf("selectedItem = %q, want %q", m.SelectedItem(), "Rust")
	}
}

func TestSelectedItemEmpty(t *testing.T) {
	m := NewModel([]Item{{Label: "A"}})
	if m.SelectedItem() != "" {
		t.Errorf("selectedItem before selection = %q, want empty", m.SelectedItem())
	}
}

func TestRenderContainsItems(t *testing.T) {
	items := []Item{{Label: "Go"}, {Label: "Rust"}}
	m := NewModel(items)
	out := m.Render()

	for _, item := range items {
		found := false
		for _, c := range out {
			_ = c
		}
		if !contains(out, item.Label) {
			t.Errorf("render output missing item %q", item.Label)
		}
		_ = found
	}
}

func contains(s, substr string) bool {
	return len(s) >= len(substr) && searchString(s, substr)
}

func searchString(s, substr string) bool {
	for i := 0; i <= len(s)-len(substr); i++ {
		if s[i:i+len(substr)] == substr {
			return true
		}
	}
	return false
}
