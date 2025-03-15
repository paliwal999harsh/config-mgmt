package storage

import (
	"context"
	"fmt"
	"mime/multipart"

	"github.com/paliwal999harsh/config-mgmt/internal/common/logging"
)

var logger logging.Logger

func init() {
	logger = logging.New(
		logging.WithLevel("debug"),
		logging.WithPrettyPrint(true),
	)
}

type StorageService interface {
	UploadFile(ctx context.Context, file multipart.File, fileName string) (string, error)
}

func NewStorageService(storagetype string) (StorageService, error) {
	switch storagetype {
	case "MinIO":
		storage, err := NewMinIOStorage("uploads", false)
		if err != nil {
			return nil, fmt.Errorf("failed to get minio storage service")

		}
		return storage, nil
	default:
		return nil, fmt.Errorf("failed to get any storage service")
	}
}
