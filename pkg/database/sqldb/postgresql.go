package sqldb

import (
	"database/sql"
	"fmt"

	"github.com/paliwal999harsh/config-mgmt/internal/common/config"
	"github.com/paliwal999harsh/config-mgmt/internal/common/logging"
)

type PostgresDB struct {
	config.DbConfig
}

func (p *PostgresDB) Connect() (*sql.DB, error) {
	dsn := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=%s",
		p.Host, p.Port, p.User, p.Password, p.Database, p.SSLMode,
	)

	db, err := sql.Open("postgres", dsn)
	if err != nil {
		return nil, err
	}

	if err := db.Ping(); err != nil {
		return nil, err
	}

	logging.Info("Connected to PostgreSQL successfully.")
	return db, nil
}
