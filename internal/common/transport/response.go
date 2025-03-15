package transport

import "github.com/labstack/echo/v4"

// APIResponse defines a standard API response format
type APIResponse struct {
	Status  string `json:"status"`
	Message string `json:"message"`
	Data    any    `json:"data,omitempty"`
}

// SuccessResponse returns a success message
func SuccessResponse(c echo.Context, statuscode int, message string, data any) error {
	return c.JSON(statuscode, APIResponse{Status: "success", Message: message, Data: data})
}

// ErrorResponse returns a formatted error response
func ErrorResponse(c echo.Context, statusCode int, message string) error {
	return c.JSON(statusCode, APIResponse{Status: "error", Message: message})
}
