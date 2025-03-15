package service

import (
	"context"
	"fmt"
	"mime/multipart"

	"github.com/paliwal999harsh/config-mgmt/internal/common/logging"
	"github.com/paliwal999harsh/config-mgmt/pkg/database/storage"
)

var logger logging.Logger

func init() {
	logger = logging.New(
		logging.WithLevel("debug"),
		logging.WithPrettyPrint(true),
	)
}

func (f *FileUploadService) UploadFile(context context.Context, src multipart.File, filename string) (any, error) {
	logger.Info("File Upload Service", logging.Str("filename", filename))
	file_url, err := (*f.storage).UploadFile(context, src, filename)
	if err != nil {
		return nil, fmt.Errorf("unable to upload file")
	}
	return file_url, nil
}

func NewFileUploadService(storagetype string) (*FileUploadService, error) {
	storage, err := storage.NewStorageService(storagetype)
	if err != nil {
		return nil, fmt.Errorf("failed to init upload service: %w", err)
	}
	return &FileUploadService{storage: &storage}, nil
}
