package transport

import (
	"mime/multipart"

	"github.com/go-playground/validator/v10"
)

var validate = validator.New()

// FileUploadRequest represents the file upload payload
type FileUploadRequest struct {
	File *multipart.FileHeader `form:"file" validate:"required"`
}

// Validate performs request validation
func (r *FileUploadRequest) Validate() error {
	return validate.Struct(r)
}
