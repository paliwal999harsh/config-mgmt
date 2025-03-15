#!/bin/bash
# build.sh - Build script for Enterprise Configuration Management System

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Services
SERVICES=("cmdb" "discovery" "integration" "visualization" "change")

# Functions
print_header() {
    echo -e "${YELLOW}=================================================${NC}"
    echo -e "${YELLOW}$1${NC}"
    echo -e "${YELLOW}=================================================${NC}"
}

check_dependencies() {
    print_header "Checking dependencies"
    
    if ! command -v go &> /dev/null; then
        echo -e "${RED}Go is not installed. Please install Go 1.18 or higher.${NC}"
        exit 1
    fi
    
    go_version=$(go version | awk '{print $3}' | sed 's/go//')
    required_version="1.18"
    
    if [[ $(echo -e "$required_version\n$go_version" | sort -V | head -n1) != "$required_version" ]]; then
        echo -e "${RED}Go version must be $required_version or higher. Found $go_version.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Go $go_version installed${NC}"
    
    if ! command -v golangci-lint &> /dev/null; then
        echo -e "${YELLOW}Warning: golangci-lint not found. Linting will be skipped.${NC}"
    else
        echo -e "${GREEN}✓ golangci-lint installed${NC}"
    fi
    
    echo -e "${GREEN}All required dependencies are installed.${NC}"
}

clean_build() {
    print_header "Cleaning build artifacts"
    rm -rf bin
    mkdir -p bin
    echo -e "${GREEN}Build directory cleaned.${NC}"
}

build_services() {
    print_header "Building services"
    
    for service in "${SERVICES[@]}"; do
        echo -e "Building ${YELLOW}$service${NC} service..."
        go build -ldflags="-s -w" -o bin/$service-service ./cmd/$service-service
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ $service service built successfully${NC}"
        else
            echo -e "${RED}✗ Failed to build $service service${NC}"
            exit 1
        fi
    done
    
    echo -e "${GREEN}All services built successfully.${NC}"
}

run_tests() {
    print_header "Running tests"
    
    go test ./... -cover
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ All tests passed${NC}"
    else
        echo -e "${RED}✗ Tests failed${NC}"
        exit 1
    fi
}

run_linting() {
    print_header "Running linters"
    
    echo "Running go vet..."
    go vet ./...
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ go vet passed${NC}"
    else
        echo -e "${RED}✗ go vet failed${NC}"
        exit 1
    fi
    
    if command -v golangci-lint &> /dev/null; then
        echo "Running golangci-lint..."
        golangci-lint run ./...
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ golangci-lint passed${NC}"
        else
            echo -e "${RED}✗ golangci-lint failed${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}Skipping golangci-lint (not installed)${NC}"
    fi
    
    echo -e "${GREEN}All linting passed.${NC}"
}

# Main execution
echo -e "${GREEN}Enterprise Configuration Management System Build Script${NC}"
echo -e "Started at $(date)"

check_dependencies
clean_build
run_linting
run_tests
build_services

print_header "Build Summary"
echo -e "${GREEN}All services built successfully!${NC}"
echo -e "Build completed at $(date)"
echo -e "Services can be found in the ${YELLOW}bin/${NC} directory"
echo -e "Run individual services with ${YELLOW}./bin/<service-name>${NC}"
echo -e "Or run all services with ${YELLOW}make run-all${NC}"