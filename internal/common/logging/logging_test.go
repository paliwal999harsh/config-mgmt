package logging

import (
	"bytes"
	"encoding/json"
	"testing"
)

// TestLogger is a helper for testing with logging
type TestLogger struct {
	Logger Logger
	Buffer *bytes.Buffer
}

// NewTestLogger creates a logger suitable for testing
func NewTestLogger() *TestLogger {
	buf := &bytes.Buffer{}
	logger := New(
		WithOutput(buf),
		WithLevel("debug"),
		WithPrettyPrint(false),
	)

	return &TestLogger{
		Logger: logger,
		Buffer: buf,
	}
}

// AssertContains checks if the log output contains expected entry
func (tl *TestLogger) AssertContains(t *testing.T, expectedKey string, expectedValue any) {
	t.Helper()

	var parsedLog map[string]any
	err := json.Unmarshal(tl.Buffer.Bytes(), &parsedLog)
	if err != nil {
		t.Fatalf("Failed to parse log output: %v", err)
	}

	val, ok := parsedLog[expectedKey]
	if !ok {
		t.Fatalf("Log doesn't contain key '%s'", expectedKey)
	}

	// Convert both to strings for easier comparison
	expected := toString(expectedValue)
	actual := toString(val)

	if expected != actual {
		t.Fatalf("Expected log entry '%s' to be '%s', got '%s'", expectedKey, expected, actual)
	}
}

// Reset clears the buffer for the next test
func (tl *TestLogger) Reset() {
	tl.Buffer.Reset()
}

// toString converts any type to string for comparison
func toString(v any) string {
	if v == nil {
		return "<nil>"
	}

	if s, ok := v.(string); ok {
		return s
	}

	// For more complex types, use JSON representation
	b, err := json.Marshal(v)
	if err != nil {
		return "<unmarshalable>"
	}
	return string(b)
}
