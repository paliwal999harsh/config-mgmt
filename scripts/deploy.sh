#!/bin/bash
# deploy.sh - Deployment script for Enterprise Configuration Management System

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default configuration
ENVIRONMENT="development"
DOCKER_REGISTRY="ecms"
DOCKER_TAG="latest"
K8S_NAMESPACE="ecms"
K8S_CONTEXT="minikube"
SERVICES=("cmdb" "discovery" "integration" "visualization" "change")

# Functions
print_header() {
    echo -e "${YELLOW}=================================================${NC}"
    echo -e "${YELLOW}$1${NC}"
    echo -e "${YELLOW}=================================================${NC}"
}

show_help() {
    echo -e "${GREEN}Enterprise Configuration Management System Deploy Script${NC}"
    echo ""
    echo "Usage: ./deploy.sh [options]"
    echo ""
    echo "Options:"
    echo "  -e, --environment ENV    Deployment environment (development, staging, production)"
    echo "  -r, --registry REG       Docker registry to use"
    echo "  -t, --tag TAG            Docker image tag"
    echo "  -n, --namespace NS       Kubernetes namespace"
    echo "  -c, --context CTX        Kubernetes context"
    echo "  -s, --service SVC        Deploy specific service (can be repeated)"
    echo "  --docker-only            Only build and push Docker images"
    echo "  --k8s-only               Only deploy to Kubernetes"
    echo "  -h, --help               Show this help message"
    exit 0
}

parse_args() {
    SPECIFIC_SERVICES=()
    DOCKER_ONLY=false
    K8S_ONLY=false
    
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
            -e|--environment)
                ENVIRONMENT="$2"
                shift
                shift
                ;;
            -r|--registry)
                DOCKER_REGISTRY="$2"
                shift
                shift
                ;;
            -t|--tag)
                DOCKER_TAG="$2"
                shift
                shift
                ;;
            -n|--namespace)
                K8S_NAMESPACE="$2"
                shift
                shift
                ;;
            -c|--context)
                K8S_CONTEXT="$2"
                shift
                shift
                ;;
            -s|--service)
                SPECIFIC_SERVICES+=("$2")
                shift
                shift
                ;;
            --docker-only)
                DOCKER_ONLY=true
                shift
                ;;
            --k8s-only)
                K8S_ONLY=true
                shift
                ;;
            -h|--help)
                show_help
                ;;
            *)
                echo -e "${RED}Unknown argument: $key${NC}"
                exit 1
                ;;
        esac
    done
    
    # If specific services are specified, override SERVICES
    if [ ${#SPECIFIC_SERVICES[@]} -gt 0 ]; then
        SERVICES=("${SPECIFIC_SERVICES[@]}")
    fi
}

validate_environment() {
    print_header "Validating environment"
    
    if [[ ! "$ENVIRONMENT" =~ ^(development|staging|production)$ ]]; then
        echo -e "${RED}Invalid environment: $ENVIRONMENT${NC}"
        echo -e "Valid options: development, staging, production"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Environment: $ENVIRONMENT${NC}"
    
    # Check Docker
    if [ "$K8S_ONLY" != "true" ]; then
        if ! command -v docker &> /dev/null; then
            echo -e "${RED}Docker is not installed. Please install Docker.${NC}"
            exit 1
        fi
        echo -e "${GREEN}✓ Docker installed${NC}"
    fi
    
    # Check Kubernetes
    if [ "$DOCKER_ONLY" != "true" ]; then
        if ! command -v kubectl &> /dev/null; then
            echo -e "${RED}kubectl is not installed. Please install kubectl.${NC}"
            exit 1
        fi
        echo -e "${GREEN}✓ kubectl installed${NC}"
        
        # Check if context exists
        if ! kubectl config get-contexts $K8S_CONTEXT &> /dev/null; then
            echo -e "${RED}Kubernetes context '$K8S_CONTEXT' not found${NC}"
            echo -e "Available contexts:"
            kubectl config get-contexts
            exit 1
        fi
        echo -e "${GREEN}✓ Kubernetes context: $K8S_CONTEXT${NC}"
    fi
}

build_docker_images() {
    print_header "Building Docker images"
    
    for service in "${SERVICES[@]}"; do
        echo -e "Building ${YELLOW}$service${NC} service image..."
        docker build \
            -t ${DOCKER_REGISTRY}/${service}-service:${DOCKER_TAG} \
            -f ./deployments/docker/${service}/Dockerfile \
            --build-arg ENVIRONMENT=${ENVIRONMENT} \
            .
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ $service service image built successfully${NC}"
        else
            echo -e "${RED}✗ Failed to build $service service image${NC}"
            exit 1
        fi
    done
    
    echo -e "${GREEN}All Docker images built successfully.${NC}"
}

push_docker_images() {
    print_header "Pushing Docker images"
    
    # Check if user is logged into registry
    echo "Checking Docker registry login..."
    if [[ "$DOCKER_REGISTRY" != "localhost"* ]] && [[ "$DOCKER_REGISTRY" != "127.0.0.1"* ]]; then
        docker info | grep "Username" > /dev/null || { echo -e "${RED}Not logged into Docker registry. Please run 'docker login' first.${NC}"; exit 1; }
    fi
    
    for service in "${SERVICES[@]}"; do
        echo -e "Pushing ${YELLOW}$service${NC} service image..."
        docker push ${DOCKER_REGISTRY}/${service}-service:${DOCKER_TAG}
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ $service service image pushed successfully${NC}"
        else
            echo -e "${RED}✗ Failed to push $service service image${NC}"
            exit 1
        fi
    done
    
    echo -e "${GREEN}All Docker images pushed successfully.${NC}"
}

deploy_kubernetes() {
    print_header "Deploying to Kubernetes"
    
    echo "Switching to Kubernetes context: $K8S_CONTEXT"
    kubectl config use-context $K8S_CONTEXT
    
    # Create namespace if it doesn't exist
    kubectl get namespace $K8S_NAMESPACE > /dev/null 2>&1 || {
        echo "Creating namespace: $K8S_NAMESPACE"
        kubectl create namespace $K8S_NAMESPACE
    }
    
    # Apply ConfigMaps and Secrets
    echo "Applying ConfigMaps and Secrets..."
    kubectl apply -f ./deployments/kubernetes/base/configmaps -n $K8S_NAMESPACE
    kubectl apply -f ./deployments/kubernetes/environments/$ENVIRONMENT/configmaps -n $K8S_NAMESPACE
    
    # Apply CRDs and infrastructure components
    echo "Applying infrastructure components..."
    kubectl apply -f ./deployments/kubernetes/base/crds -n $K8S_NAMESPACE
    kubectl apply -f ./deployments/kubernetes/base/infrastructure -n $K8S_NAMESPACE
    
    # Deploy each service
    for service in "${SERVICES[@]}"; do
        echo -e "Deploying ${YELLOW}$service${NC} service..."
        
        # Update image in deployment file if needed
        if [[ "$DOCKER_REGISTRY" != "ecms" || "$DOCKER_TAG" != "latest" ]]; then
            echo "Updating image reference for $service..."
            # Use yq or sed to update the image reference in the deployment file
            # This is a simplified example - you may need to adjust based on your actual file structure
            sed -i.bak "s|image: ecms/${service}-service:latest|image: ${DOCKER_REGISTRY}/${service}-service:${DOCKER_TAG}|g" \
                ./deployments/kubernetes/environments/$ENVIRONMENT/deployments/${service}-deployment.yaml
        fi
        
        # Apply service-specific resources
        kubectl apply -f ./deployments/kubernetes/environments/$ENVIRONMENT/deployments/${service}-deployment.yaml -n $K8S_NAMESPACE
        kubectl apply -f ./deployments/kubernetes/environments/$ENVIRONMENT/services/${service}-service.yaml -n $K8S_NAMESPACE
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ $service service deployed successfully${NC}"
        else
            echo -e "${RED}✗ Failed to deploy $service service${NC}"
            exit 1
        fi
    done
    
    # Apply ingress resources
    echo "Applying ingress resources..."
    kubectl apply -f ./deployments/kubernetes/environments/$ENVIRONMENT/ingress -n $K8S_NAMESPACE
    
    echo -e "${GREEN}All services deployed successfully to Kubernetes.${NC}"
}

wait_for_deployment() {
    print_header "Waiting for deployments to be ready"
    
    for service in "${SERVICES[@]}"; do
        echo -e "Waiting for ${YELLOW}$service${NC} deployment..."
        kubectl rollout status deployment/${service}-deployment -n $K8S_NAMESPACE --timeout=300s
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ $service deployment is ready${NC}"
        else
            echo -e "${RED}✗ $service deployment failed or timed out${NC}"
            echo -e "Check deployment status with: kubectl get pods -n $K8S_NAMESPACE | grep $service"
            exit 1
        fi
    done
    
    echo -e "${GREEN}All deployments are ready.${NC}"
}

show_endpoint_info() {
    print_header "Deployment Information"
    
    echo "Services deployed to namespace: $K8S_NAMESPACE"
    echo ""
    
    # Get ingress information if available
    if kubectl get ingress -n $K8S_NAMESPACE &> /dev/null; then
        echo "Ingress endpoints:"
        kubectl get ingress -n $K8S_NAMESPACE -o=custom-columns=NAME:.metadata.name,HOSTS:.spec.rules[*].host
        echo ""
    fi
    
    # Get service information
    echo "Service endpoints:"
    kubectl get services -n $K8S_NAMESPACE -o=custom-columns=NAME:.metadata.name,TYPE:.spec.type,CLUSTER-IP:.spec.clusterIP,EXTERNAL-IP:.status.loadBalancer.ingress[*].ip
    echo ""
    
    # Show how to port-forward for local access
    echo -e "${YELLOW}To access services locally, use:${NC}"
    echo "kubectl port-forward -n $K8S_NAMESPACE svc/<service-name> <local-port>:<service-port>"
    echo "Example: kubectl port-forward -n $K8S_NAMESPACE svc/cmdb-service 8080:80"
}

# Main execution
parse_args "$@"

echo -e "${GREEN}Enterprise Configuration Management System Deploy Script${NC}"
echo -e "Started at $(date)"

validate_environment

if [ "$K8S_ONLY" != "true" ]; then
    build_docker_images
    push_docker_images
fi

if [ "$DOCKER_ONLY" != "true" ]; then
    deploy_kubernetes
    wait_for_deployment
    show_endpoint_info
fi

print_header "Deployment Summary"
echo -e "${GREEN}Deployment completed successfully!${NC}"
echo -e "Environment: ${YELLOW}$ENVIRONMENT${NC}"
echo -e "Services: ${YELLOW}${SERVICES[*]}${NC}"
echo -e "Deployment completed at $(date)"