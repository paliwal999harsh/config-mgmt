# Enterprise Configuration Management System Makefile

# Variables
SHELL := /bin/bash
GO := go
GOFLAGS := -ldflags="-s -w"
GOCMD := $(GO) $(GOFLAGS)

# Service names
SERVICES := cmdb discovery integration visualization change

# Docker variables
DOCKER_REGISTRY := ecms
DOCKER_TAG := latest
DOCKER_BUILD_ARGS := --no-cache

# Kubernetes variables
K8S_NAMESPACE := ecms
K8S_CONTEXT := minikube

.PHONY: all build clean test lint vet fmt help docker-build docker-push k8s-deploy k8s-delete run-all

all: clean vet fmt lint test build

# Build all services
build:
	@echo "Building all services..."
	@mkdir -p ./bin
	@for service in $(SERVICES); do \
		echo "Building $$service service..." ; \
		$(GOCMD) build -o ./bin/$$service-service ./cmd/$$service-service ; \
	done
	@echo "Build complete"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf ./bin
	@echo "Clean complete"

# Run tests
test:
	@echo "Running tests..."
	@$(GO) test ./... -cover
	@echo "Tests complete"

# Run linter
lint:
	@echo "Running linter..."
	@golangci-lint run ./...
	@echo "Lint complete"

# Run go vet
vet:
	@echo "Running go vet..."
	@$(GO) vet ./...
	@echo "Vet complete"

# Format code
fmt:
	@echo "Formatting code..."
	@$(GO) fmt ./...
	@echo "Format complete"

# Build Docker images
docker-build:
	@echo "Building Docker images..."
	@for service in $(SERVICES); do \
		echo "Building $$service service image..." ; \
		docker build -t $(DOCKER_REGISTRY)/$$service-service:$(DOCKER_TAG) -f ./deployments/docker/$$service/Dockerfile . $(DOCKER_BUILD_ARGS) ; \
	done
	@echo "Docker build complete"

# Push Docker images
docker-push:
	@echo "Pushing Docker images..."
	@for service in $(SERVICES); do \
		echo "Pushing $$service service image..." ; \
		docker push $(DOCKER_REGISTRY)/$$service-service:$(DOCKER_TAG) ; \
	done
	@echo "Docker push complete"

# Deploy to Kubernetes
k8s-deploy:
	@echo "Deploying to Kubernetes..."
	@kubectl config use-context $(K8S_CONTEXT)
	@kubectl apply -f ./deployments/kubernetes/base/namespace.yaml
	@kubectl apply -f ./deployments/kubernetes/base -n $(K8S_NAMESPACE)
	@kubectl apply -f ./deployments/kubernetes/environments/development -n $(K8S_NAMESPACE)
	@echo "Deployment complete"

# Delete Kubernetes deployment
k8s-delete:
	@echo "Deleting Kubernetes deployment..."
	@kubectl config use-context $(K8S_CONTEXT)
	@kubectl delete -f ./deployments/kubernetes/environments/development -n $(K8S_NAMESPACE)
	@kubectl delete -f ./deployments/kubernetes/base -n $(K8S_NAMESPACE)
	@echo "Deletion complete"

# Run all services locally
run-all:
	@echo "Starting all services..."
	@for service in $(SERVICES); do \
		echo "Starting $$service service..." ; \
		$(GO) run ./cmd/$$service-service/main.go & \
	done
	@echo "All services started"

# Show help
help:
	@echo "Enterprise Configuration Management System"
	@echo ""
	@echo "Usage:"
	@echo "  make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  all          Run clean, vet, fmt, lint, test, and build"
	@echo "  build        Build all services"
	@echo "  clean        Remove build artifacts"
	@echo "  test         Run tests"
	@echo "  lint         Run linter"
	@echo "  vet          Run go vet"
	@echo "  fmt          Format code"
	@echo "  docker-build Build Docker images"
	@echo "  docker-push  Push Docker images to registry"
	@echo "  k8s-deploy   Deploy to Kubernetes"
	@echo "  k8s-delete   Delete Kubernetes deployment"
	@echo "  run-all      Run all services locally"
	@echo "  help         Show this help"