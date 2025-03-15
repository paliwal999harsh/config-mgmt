package types

import (
	"time"
)

// Event represents a generic event structure
type Event struct {
	EventID   string    `json:"event_id"`
	EventType string    `json:"event_type"`
	Timestamp time.Time `json:"timestamp"`
	Source    string    `json:"source"`
	Payload   any       `json:"payload"`
}
