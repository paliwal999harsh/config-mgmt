package config

var CoreServiceConfig ServiceConfig

func LoadCoreServiceConfig() {
	CoreServiceConfig = ServiceConfig{
		Name: "CORE-SERVICE",
	}
}
