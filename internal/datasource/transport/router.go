package transport

import (
	"github.com/labstack/echo/v4"
)

// RegisterRoutes sets up API routes for datasource service
func RegisterRoutes(e *echo.Echo, ds *DataSourceHandler) {
	api := e.Group("/api/v1/datasource")

	api.GET("", ds.ListDataSource)
	api.GET("/:id", ds.GetDataSource)
	api.POST("", ds.CreateDataSource)
	api.PUT("/:id", ds.ModifyDataSource)
	api.DELETE("/:id", ds.DeleteDataSource)
}
