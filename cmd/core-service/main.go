package main

import (
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/paliwal999harsh/config-mgmt/internal/common/config"
	"github.com/paliwal999harsh/config-mgmt/internal/common/logging"
	"github.com/paliwal999harsh/config-mgmt/internal/file/service"
	"github.com/paliwal999harsh/config-mgmt/internal/file/transport"
)

func main() {
	coreServiceCfg := config.LoadCoreServiceConfig()
	logging.Info("Server starting",
		logging.Str("service", coreServiceCfg.Name),
		logging.Int("port", 8080))
	e := echo.New()
	e.HideBanner = true
	e.HidePort = true
	e.Use(middleware.RequestLoggerWithConfig(middleware.RequestLoggerConfig{
		LogURI:    true,
		LogStatus: true,
		LogValuesFunc: func(c echo.Context, v middleware.RequestLoggerValues) error {
			logging.Info("request",
				logging.Str("URI", v.URI),
				logging.Int("status", v.Status))

			return nil
		},
	}))

	fileService, err := service.NewFileUploadService("MinIO")
	if err != nil {
		logging.Debug(err.Error())
		fileService = &service.FileUploadService{}
	}

	handler := &transport.FileUploadHandler{Service: fileService}

	// Register routes
	transport.RegisterRoutes(e, handler)

	e.Logger.Fatal(e.Start(":" + "8080"))
}
