package config

import (
	"github.com/spf13/viper"
)

type DbConfig struct {
	Driver   string
	Host     string
	Port     string
	User     string
	Password string
	Database string
	SSLMode  string
}

func LoadDBConfig() DbConfig {
	return DbConfig{
		Driver:   viper.GetString("SQLDB_DRIVER"),
		Host:     viper.GetString("SQLDB_HOST"),
		Port:     viper.GetString("SQLDB_PORT"),
		User:     viper.GetString("SQLDB_USER"),
		Password: viper.GetString("SQLDB_PASSWORD"),
		Database: viper.GetString("SQLDB_NAME"),
		SSLMode:  viper.GetString("SQLDB_SSLMODE"),
	}
}
