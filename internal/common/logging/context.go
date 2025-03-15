package logging

import (
	"context"
)

type loggerKey struct{}

// FromContext extracts a logger from the context
func FromContext(ctx context.Context) Logger {
	if logger, ok := ctx.Value(loggerKey{}).(Logger); ok {
		return logger
	}
	return New() // Return default logger if not found in context
}

// NewContext adds a logger to the context
func NewContext(ctx context.Context, logger Logger) context.Context {
	return context.WithValue(ctx, loggerKey{}, logger)
}

// Field constructors to make logging more convenient
func F(key string, value any) Field {
	return Field{Key: key, Value: value}
}

// Str creates a string field
func Str(key string, value string) Field {
	return Field{Key: key, Value: value}
}

// Int creates an integer field
func Int(key string, value int) Field {
	return Field{Key: key, Value: value}
}

// Int64 creates an int64 field
func Int64(key string, value int64) Field {
	return Field{Key: key, Value: value}
}

// Float64 creates a float64 field
func Float64(key string, value float64) Field {
	return Field{Key: key, Value: value}
}

// Bool creates a boolean field
func Bool(key string, value bool) Field {
	return Field{Key: key, Value: value}
}

// Err creates an error field
func Err(err error) Field {
	return Field{Key: "error", Value: err}
}
