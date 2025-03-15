package transport

import (
	"github.com/labstack/echo/v4"
)

// RegisterRoutes sets up API routes for file upload service
func RegisterRoutes(e *echo.Echo, h *FileUploadHandler) {
	api := e.Group("/api/v1")

	api.POST("/upload", h.UploadFile)
}
