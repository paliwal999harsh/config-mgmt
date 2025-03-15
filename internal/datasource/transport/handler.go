package transport

import (
	"github.com/labstack/echo/v4"
	"github.com/paliwal999harsh/config-mgmt/internal/datasource/service"
)

type DataSourceHandler struct {
	Service *service.DataSourceService
}

func (ds *DataSourceHandler) ListDataSource(c echo.Context) error {
	return nil
}
func (ds *DataSourceHandler) GetDataSource(c echo.Context) error {
	return nil

}
func (ds *DataSourceHandler) CreateDataSource(c echo.Context) error {
	return nil

}
func (ds *DataSourceHandler) ModifyDataSource(c echo.Context) error {
	return nil

}
func (ds *DataSourceHandler) DeleteDataSource(c echo.Context) error {
	return nil

}
