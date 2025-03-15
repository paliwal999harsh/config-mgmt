package config

import (
	"github.com/paliwal999harsh/config-mgmt/internal/common/logging"
	"github.com/spf13/viper"
)

type ServiceConfig struct {
	Name string
}

var logger logging.Logger

func init() {
	logger = logging.New(
		logging.WithLevel("debug"),
		logging.WithPrettyPrint(true),
	)
	viper.SetConfigFile("C:/Users/paliw/GolandProjects/config-mgmt/.env")
	viper.AutomaticEnv()
	if err := viper.ReadInConfig(); err != nil {
		logger.Info("No config file found, using environment variables")
	}
}
