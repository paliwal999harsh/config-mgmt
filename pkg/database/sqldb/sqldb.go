package sqldb

import (
	"database/sql"
	"fmt"

	_ "github.com/lib/pq"
	"github.com/paliwal999harsh/config-mgmt/internal/common/config"
)

type Database interface {
	Connect() (*sql.DB, error)
}

func NewDatabase() (Database, error) {
	cfg := config.LoadDBConfig()
	switch cfg.Driver {
	case "postgres":
		return &PostgresDB{cfg}, nil
	default:
		return nil, fmt.Errorf("unsupported database driver: %s", cfg.Driver)
	}
}
