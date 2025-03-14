# Enterprise Configuration Management System

A scalable, distributed microservice architecture for ingesting, managing, and analyzing enterprise configuration items in a graph database.

## Overview

The Enterprise Configuration Management System (ECMS) is an advanced platform designed to help enterprises manage their configuration items (CI) across complex infrastructures. It supports ingesting data from various sources (initially CSV files), modeling relationships between configuration items, and storing them in a graph database for powerful querying and visualization.

## Key Features

- **Flexible Data Source Definition**: Define data sources with custom CI attributes and relationships
- **Complex Relationship Mapping**: Support for 1:1, 1:M, M:1, and M:M relationships between CIs
- **Event-Driven Architecture**: Asynchronous processing and real-time notifications
- **Extensible Framework**: Designed for future integrations with external systems
- **Scalable Processing**: Batch processing for large datasets with progress tracking
- **Graph-Based Storage**: Store configuration items in a graph database for powerful queries

## Architecture

ECMS follows a microservice architecture with these core components:

- **Data Source Management Service**: Define and manage data source configurations
- **File Upload Service**: Handle secure file uploads and validation
- **Data Ingestion Service**: Process and transform data into graph entities
- **Graph Database Service**: Store and manage graph entities and relationships
- **Reporting Service**: Generate reports and track ingestion status
- **Integration Framework**: Extensible system for future external integrations

## User Journey

1. **Define Data Source**: Create a data source that defines CI types, attributes, and relationships
2. **Upload Configuration Data**: Upload a CSV file containing CI data
3. **Monitor Ingestion**: Track the progress of the ingestion process
4. **View Results**: Review the ingestion report and explore the graph

## Technologies

- **Backend**: Go (Golang) for microservices
- **Message Queue**: Kafka for event-driven architecture
- **Graph Database**: Neo4j/Neptune for storing configuration items and relationships
- **Storage**: Object storage (S3-compatible) for file management
- **Containerization**: Docker and Kubernetes for deployment and scaling

## Getting Started

### Prerequisites

- Go 1.18+
- Docker and Docker Compose
- Kubernetes cluster (for production deployment)
- Neo4j (or compatible graph database)
- Kafka (or compatible message broker)

### Development Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/enterprise-config-mgmt.git
cd enterprise-config-mgmt

# Start the development environment
docker-compose up -d

# Run the services
go run ./cmd/datasource-service/main.go
go run ./cmd/fileupload-service/main.go
go run ./cmd/ingestion-service/main.go
# ... and so on for other services
```

## Deployment

The system is designed to be deployed as containerized microservices on Kubernetes:

```bash
# Build Docker images
docker build -t ecms/datasource-service:latest ./datasource-service
docker build -t ecms/fileupload-service:latest ./fileupload-service
# ... and so on for other services

# Deploy to Kubernetes
kubectl apply -f kubernetes/
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Graph database community for best practices
- Microservice architecture patterns
- Event-driven architecture patterns