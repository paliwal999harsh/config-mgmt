package config

import (
	"github.com/spf13/viper"
)

type MinIoStorageConfig struct {
	URL       string
	AccessKey string
	SecretKey string
}

var MinIOStorageConfig MinIoStorageConfig

func LoadMinIOStorageConfig() {
	MinIOStorageConfig = MinIoStorageConfig{
		URL:       viper.GetString("MinIOURL"),
		AccessKey: viper.GetString("MinIOAccessKey"),
		SecretKey: viper.GetString("MinIOSecretKey"),
	}
}
