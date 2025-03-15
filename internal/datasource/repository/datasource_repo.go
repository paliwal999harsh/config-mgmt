package repository

import (
	"database/sql"
	"fmt"

	"github.com/paliwal999harsh/config-mgmt/internal/common/logging"
	"github.com/paliwal999harsh/config-mgmt/pkg/model"
)

type DataSourceRepository struct {
	DB *sql.DB
}

func NewDataSourceRepository(db *sql.DB) *DataSourceRepository {
	return &DataSourceRepository{DB: db}
}

func (r *DataSourceRepository) SaveDataSource(name string, ds model.DataSource) error {
	query := "INSERT INTO datasources (name, datasource) VALUES ($1, $2)"

	_, err := r.DB.Exec(query, name, ds)
	if err != nil {
		logging.Info(fmt.Sprintf("Error saving datasource: %v", err))
	}
	return err
}
