package transport

import (
	"context"
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/paliwal999harsh/config-mgmt/internal/file/service"
)

type FileUploadHandler struct {
	Service *service.FileUploadService
}

func (h *FileUploadHandler) UploadFile(c echo.Context) error {
	file, err := c.FormFile("file")
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"error": "File is required"})
	}

	src, err := file.Open()
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": "Failed to open file"})
	}
	defer src.Close()

	fileURL, err := h.Service.UploadFile(context.TODO(), src, file.Filename)
	if err != nil {
		return c.JSON(http.StatusInternalServerError, echo.Map{"error": "File upload failed"})
	}

	return c.JSON(http.StatusOK, echo.Map{"file_url": fileURL})
}
