package config

import (
	"github.com/paliwal999harsh/config-mgmt/internal/common/logging"
	"github.com/spf13/viper"
)

type ServiceConfig struct {
	Name string
}

func init() {
	viper.SetConfigFile("C:/Users/paliw/GolandProjects/config-mgmt/.env")
	viper.AutomaticEnv()
	if err := viper.ReadInConfig(); err != nil {
		logging.Info("No config file found, using environment variables")
	}
}
