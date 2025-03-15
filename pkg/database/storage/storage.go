package storage

import (
	"context"
	"fmt"
	"mime/multipart"
)

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
