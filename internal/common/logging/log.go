package logging

func Debug(msg string, fields ...Field) {
	log.Debug(msg, fields...)
}

func Info(msg string, fields ...Field) {
	log.Info(msg, fields...)
}

func Warn(msg string, fields ...Field) {
	log.Warn(msg, fields...)
}

func Error(msg string, fields ...Field) {
	log.Error(msg, fields...)
}

func Fatal(msg string, fields ...Field) {
	log.Fatal(msg, fields...)
}
