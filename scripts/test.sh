#!/bin/bash
# test.sh - Test script for Enterprise Configuration Management System

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

run_unit_tests() {
    print_header "Running unit tests"
    
    go test ./... -short -cover
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ All unit tests passed${NC}"
    else
        echo -e "${RED}✗ Unit tests failed${NC}"
        exit 1
    fi
}

run_integration_tests() {
    print_header "Running integration tests"
    
    # Check if integration tests should be skipped
    if [ "$SKIP_INTEGRATION" == "true" ]; then
        echo -e "${YELLOW}Integration tests skipped due to SKIP_INTEGRATION=true${NC}"
        return 0
    fi
    
    # Check for required services
    if ! command -v docker-compose &> /dev/null; then
        echo -e "${YELLOW}Warning: docker-compose not found. Integration tests will be skipped.${NC}"
        return 0
    fi
    
    # Start test environment
    echo "Starting test environment with docker-compose..."
    docker-compose -f deployments/docker/development/docker-compose.yaml up -d
    
    # Wait for services to be ready
    echo "Waiting for services to be ready..."
    sleep 10
    
    # Run integration tests
    go test ./test/integration/... -tags=integration
    INTEGRATION_RESULT=$?
    
    # Stop test environment
    echo "Stopping test environment..."
    docker-compose -f deployments/docker/development/docker-compose.yaml down
    
    if [ $INTEGRATION_RESULT -eq 0 ]; then
        echo -e "${GREEN}✓ All integration tests passed${NC}"
    else
        echo -e "${RED}✗ Integration tests failed${NC}"
        exit 1
    fi
}

run_coverage_report() {
    print_header "Generating coverage report"
    
    mkdir -p ./coverage
    
    go test ./... -coverprofile=./coverage/coverage.out
    go tool cover -html=./coverage/coverage.out -o ./coverage/coverage.html
    go tool cover -func=./coverage/coverage.out
    
    echo -e "${GREEN}Coverage report generated: ./coverage/coverage.html${NC}"
}

check_service_tests() {
    print_header "Checking service test coverage"
    
    for service in "${SERVICES[@]}"; do
        echo -e "Testing ${YELLOW}$service${NC} service..."
        go test ./internal/$service/... -cover
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ $service service tests passed${NC}"
        else
            echo -e "${RED}✗ $service service tests failed${NC}"
            EXIT_CODE=1
        fi
        echo ""
    done
    
    if [ "$EXIT_CODE" == "1" ]; then
        echo -e "${RED}Some service tests failed${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}All service tests passed${NC}"
}

run_benchmarks() {
    print_header "Running benchmarks"
    
    # Check if benchmarks should be skipped
    if [ "$SKIP_BENCHMARK" == "true" ]; then
        echo -e "${YELLOW}Benchmarks skipped due to SKIP_BENCHMARK=true${NC}"
        return 0
    fi
    
    go test ./... -run=^$ -bench=. -benchmem
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ All benchmarks completed${NC}"
    else
        echo -e "${RED}✗ Benchmarks failed${NC}"
        exit 1
    fi
}

run_race_detection() {
    print_header "Running race detection"
    
    go test ./... -race -short
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ No race conditions detected${NC}"
    else
        echo -e "${RED}✗ Race conditions detected${NC}"
        exit 1
    fi
}

parse_args() {
    for arg in "$@"; do
        case $arg in
            --skip-integration)
                SKIP_INTEGRATION=true
                ;;
            --skip-benchmark)
                SKIP_BENCHMARK=true
                ;;
            --unit-only)
                UNIT_ONLY=true
                ;;
            --coverage)
                GENERATE_COVERAGE=true
                ;;
            --race)
                CHECK_RACE=true
                ;;
            *)
                echo -e "${RED}Unknown argument: $arg${NC}"
                exit 1
                ;;
        esac
    done
}

# Main execution
EXIT_CODE=0
SKIP_INTEGRATION=false
SKIP_BENCHMARK=false
UNIT_ONLY=false
GENERATE_COVERAGE=false
CHECK_RACE=false

parse_args "$@"

echo -e "${GREEN}Enterprise Configuration Management System Test Script${NC}"
echo -e "Started at $(date)"

# Run appropriate tests based on flags
run_unit_tests

if [ "$UNIT_ONLY" != "true" ]; then
    run_integration_tests
    check_service_tests
    run_benchmarks
fi

if [ "$GENERATE_COVERAGE" == "true" ]; then
    run_coverage_report
fi

if [ "$CHECK_RACE" == "true" ]; then
    run_race_detection
fi

print_header "Test Summary"
echo -e "${GREEN}All tests completed successfully!${NC}"
echo -e "Testing completed at $(date)"