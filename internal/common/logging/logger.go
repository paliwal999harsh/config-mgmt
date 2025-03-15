package logging

import (
	"context"
	"io"
	"os"
	"time"

	"github.com/rs/zerolog"
)

// Logger represents the interface for logging operations
type Logger interface {
	Debug(msg string, fields ...Field)
	Info(msg string, fields ...Field)
	Warn(msg string, fields ...Field)
	Error(msg string, fields ...Field)
	Fatal(msg string, fields ...Field)
	With(fields ...Field) Logger
	WithContext(ctx context.Context) Logger
}

// Field represents a key-value pair for structured logging
type Field struct {
	Key   string
	Value any
}

// config holds Logger configuration
type config struct {
	level      zerolog.Level
	output     io.Writer
	timeFormat string
	pretty     bool
}

// Option is a function that modifies the Logger config
type Option func(*config)

// WithLevel sets the minimum logging level
func WithLevel(level string) Option {
	return func(c *config) {
		switch level {
		case "debug":
			c.level = zerolog.DebugLevel
		case "info":
			c.level = zerolog.InfoLevel
		case "warn":
			c.level = zerolog.WarnLevel
		case "error":
			c.level = zerolog.ErrorLevel
		case "fatal":
			c.level = zerolog.FatalLevel
		default:
			c.level = zerolog.InfoLevel
		}
	}
}

// WithOutput sets the output writer
func WithOutput(output io.Writer) Option {
	return func(c *config) {
		c.output = output
	}
}

// WithTimeFormat sets the time format for log entries
func WithTimeFormat(format string) Option {
	return func(c *config) {
		c.timeFormat = format
	}
}

// WithPrettyPrint enables human-readable, colored output
func WithPrettyPrint(enabled bool) Option {
	return func(c *config) {
		c.pretty = enabled
	}
}

// zeroLogger implements the Logger interface using zerolog
type zeroLogger struct {
	zerolog.Logger
}

// New creates a new zerolog-based Logger with the provided options
func New(opts ...Option) Logger {
	// Default configuration
	cfg := &config{
		level:      zerolog.InfoLevel,
		output:     os.Stdout,
		timeFormat: time.RFC3339,
		pretty:     false,
	}

	// Apply options
	for _, opt := range opts {
		opt(cfg)
	}

	// Configure zerolog
	zerolog.TimeFieldFormat = cfg.timeFormat
	zerolog.SetGlobalLevel(cfg.level)

	var output io.Writer = cfg.output
	if cfg.pretty {
		output = zerolog.ConsoleWriter{
			Out:        cfg.output,
			TimeFormat: cfg.timeFormat,
		}
	}

	zl := zerolog.New(output).With().Timestamp().Logger()
	return &zeroLogger{Logger: zl}
}

// Debug logs a debug message
func (l *zeroLogger) Debug(msg string, fields ...Field) {
	l.log(l.Logger.Debug(), msg, fields...)
}

// Info logs an info message
func (l *zeroLogger) Info(msg string, fields ...Field) {
	l.log(l.Logger.Info(), msg, fields...)
}

// Warn logs a warning message
func (l *zeroLogger) Warn(msg string, fields ...Field) {
	l.log(l.Logger.Warn(), msg, fields...)
}

// Error logs an error message
func (l *zeroLogger) Error(msg string, fields ...Field) {
	l.log(l.Logger.Error(), msg, fields...)
}

// Fatal logs a fatal message and exits
func (l *zeroLogger) Fatal(msg string, fields ...Field) {
	l.log(l.Logger.Fatal(), msg, fields...)
}

// With returns a new Logger with the given fields added
func (l *zeroLogger) With(fields ...Field) Logger {
	Logger := l.Logger
	for _, field := range fields {
		Logger = Logger.With().Interface(field.Key, field.Value).Logger()
	}
	return &zeroLogger{Logger: Logger}
}

// WithContext returns a new Logger with context values
func (l *zeroLogger) WithContext(ctx context.Context) Logger {
	return &zeroLogger{Logger: l.Logger.With().Ctx(ctx).Logger()}
}

// log applies fields to the event and sends the message
func (l *zeroLogger) log(event *zerolog.Event, msg string, fields ...Field) {
	for _, field := range fields {
		event = event.Interface(field.Key, field.Value)
	}
	event.Msg(msg)
}

var log Logger

func init() {
	log = New(
		WithLevel("debug"),
		WithPrettyPrint(true),
	)
}
