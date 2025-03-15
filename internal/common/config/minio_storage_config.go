package config

import (
	"github.com/spf13/viper"
)

type MinIoStorageConfig struct {
	URL       string
	AccessKey string
	SecretKey string
}

func LoadMinIOStorageConfig() MinIoStorageConfig {
	return MinIoStorageConfig{
		URL:       viper.GetString("MinIOURL"),
		AccessKey: viper.GetString("MinIOAccessKey"),
		SecretKey: viper.GetString("MinIOSecretKey"),
	}
}
