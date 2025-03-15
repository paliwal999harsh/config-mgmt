package main

import (
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/paliwal999harsh/config-mgmt/internal/common/config"
	"github.com/paliwal999harsh/config-mgmt/internal/common/logging"
	"github.com/paliwal999harsh/config-mgmt/internal/file/service"
	"github.com/paliwal999harsh/config-mgmt/internal/file/transport"
)

var logger logging.Logger

func init() {
	logger = logging.New(
		logging.WithLevel("debug"),
		logging.WithPrettyPrint(true),
	)
}

func main() {
	config.LoadCoreServiceConfig()
	config.LoadMinIOStorageConfig()
	logger.Info("Server starting",
		logging.Str("service", "core"),
		logging.Int("port", 8080))
	e := echo.New()
	e.HideBanner = true
	e.HidePort = true
	e.Use(middleware.RequestLoggerWithConfig(middleware.RequestLoggerConfig{
		LogURI:    true,
		LogStatus: true,
		LogValuesFunc: func(c echo.Context, v middleware.RequestLoggerValues) error {
			logger.Info("request",
				logging.Str("URI", v.URI),
				logging.Int("status", v.Status))

			return nil
		},
	}))

	fileService, err := service.NewFileUploadService("MinIO")
	if err != nil {
		logger.Debug(err.Error())
		fileService = &service.FileUploadService{}
	}

	handler := &transport.FileUploadHandler{Service: fileService}

	// Register routes
	transport.RegisterRoutes(e, handler)

	e.Logger.Fatal(e.Start(":" + "8080"))
}
