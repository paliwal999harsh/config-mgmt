package transport

import "github.com/paliwal999harsh/config-mgmt/pkg/model"

type DataSourceCreationRequest struct {
	DS model.DataSource
}

type DataSourceUpdateRequest struct {
	DS model.DataSource
}

type DataSourceDeletionRequest struct {
	Id string
}

type DataSourceGetRequest struct {
	Id string
}
