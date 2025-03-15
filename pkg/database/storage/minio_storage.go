package storage

import (
	"context"
	"fmt"
	"io"
	"log"
	"mime/multipart"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
	"github.com/paliwal999harsh/config-mgmt/internal/common/config"
)

type MinIOStorage struct {
	Client *minio.Client
	Bucket string
}

func (s *MinIOStorage) UploadFile(ctx context.Context, file multipart.File, fileName string) (string, error) {
	fileSize, err := getFileSize(file)
	if err != nil {
		return "", fmt.Errorf("failed to upload file: %v", err)
	}
	_, err = s.Client.PutObject(ctx, s.Bucket, fileName, file, fileSize, minio.PutObjectOptions{ContentType: "application/octet-stream"})
	if err != nil {
		return "", fmt.Errorf("failed to upload file: %v", err)
	}
	url := fmt.Sprintf("%s/%s/%s", s.Client.EndpointURL(), s.Bucket, fileName)
	return url, nil
}

func NewMinIOStorage(bucket string, useSSL bool) (*MinIOStorage, error) {
	config.LoadMinIOStorageConfig()

	client, err := minio.New(config.MinIOStorageConfig.URL,
		&minio.Options{
			Creds:  credentials.NewStaticV4(config.MinIOStorageConfig.AccessKey, config.MinIOStorageConfig.SecretKey, ""),
			Secure: useSSL,
		})

	if err != nil {
		return nil, fmt.Errorf("failed to initialize minio client: %v", err)
	}
	// Ensure bucket exists
	ctx := context.Background()
	exists, err := client.BucketExists(ctx, bucket)
	if err != nil {
		logger.Info(fmt.Sprintf("%v", err.Error()))
		return nil, err
	}
	if !exists {
		log.Printf("Creating bucket: %s\n", bucket)
		err = client.MakeBucket(ctx, bucket, minio.MakeBucketOptions{})
		if err != nil {
			return nil, fmt.Errorf("failed to create bucket: %v", err)
		}
	}
	return &MinIOStorage{Client: client, Bucket: bucket}, nil
}

func getFileSize(file multipart.File) (int64, error) {
	size, err := file.Seek(0, io.SeekEnd) // Move to end to get size
	if err != nil {
		return 0, err
	}
	_, err = file.Seek(0, io.SeekStart) // Reset position to start
	if err != nil {
		return 0, err
	}
	return size, nil
}
