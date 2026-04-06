# Custom Domain Service

A cloud-native custom domain management service built with **D language** and **vibe.d**, following clean/hexagonal architecture principles. This service provides features similar to the SAP Custom Domain Service, enabling organizations to manage custom domains, TLS/SSL certificates, DNS records, and route mappings for their cloud applications.

## Features

- **Custom Domain Management** - Register, activate, deactivate, and share custom domains across organizations
- **Private Key Management** - Create RSA/ECDSA key pairs and generate Certificate Signing Requests (CSR)
- **Certificate Lifecycle** - Upload certificate chains, activate/deactivate certificates, track expirations
- **TLS Configuration** - Configure TLS protocol versions, cipher suites, HSTS, and HTTP/2
- **Domain-to-Route Mapping** - Map standard application routes to custom domain routes
- **Client Authentication** - Manage trusted CA certificates for mutual TLS (mTLS) authentication
- **DNS Record Management** - Create and validate DNS records (CNAME, A, TXT) for domain verification
- **Dashboard & KPIs** - Aggregate domain health metrics, certificate expiration warnings, and overview statistics

## Architecture

```
custom-domain/
  source/
    app.d                           # Entry point
    uim/platform/custom_domain/
      package.d                     # Root module
      domain/                       # Domain Layer (entities, ports, services)
        types.d                     # Shared types and enums
        entities/                   # Domain entities (8 entities)
        ports/repositories/         # Repository interfaces (driven ports)
        services/                   # Domain services (validation)
      application/                  # Application Layer (use cases, DTOs)
        dto.d                       # Request/response DTOs
        usecases/manage/            # Use case implementations (8 use cases)
      infrastructure/               # Infrastructure Layer (adapters)
        config.d                    # Application configuration
        container.d                 # Dependency injection container
        persistence/memory/         # In-memory repository implementations
        persistence/files/          # File-based persistence (placeholder)
        persistence/mongo/          # MongoDB persistence (placeholder)
      presentation/                 # Presentation Layer (HTTP controllers)
        http/json_utils.d           # JSON helper utilities
        http/controllers/           # HTTP controllers (8 controllers)
  Dockerfile                        # Docker multi-stage build
  Containerfile                     # Podman container build
  k8s/                              # Kubernetes manifests
    deployment.yaml
    service.yaml
    configmap.yaml
```

## API Endpoints

| Resource | Method | Path | Description |
|----------|--------|------|-------------|
| **Domains** | GET | `/api/v1/custom-domain/domains` | List all custom domains |
| | GET | `/api/v1/custom-domain/domains/{id}` | Get domain details |
| | POST | `/api/v1/custom-domain/domains` | Create a new custom domain |
| | PUT | `/api/v1/custom-domain/domains/{id}` | Update a custom domain |
| | POST | `/api/v1/custom-domain/domains/{id}/activate` | Activate a domain |
| | POST | `/api/v1/custom-domain/domains/{id}/deactivate` | Deactivate a domain |
| | DELETE | `/api/v1/custom-domain/domains/{id}` | Delete a domain |
| **Private Keys** | GET | `/api/v1/custom-domain/keys` | List all private keys |
| | GET | `/api/v1/custom-domain/keys/{id}` | Get key details |
| | POST | `/api/v1/custom-domain/keys` | Create a new key pair |
| | DELETE | `/api/v1/custom-domain/keys/{id}` | Delete a key |
| **Certificates** | GET | `/api/v1/custom-domain/certificates` | List all certificates |
| | GET | `/api/v1/custom-domain/certificates/{id}` | Get certificate details |
| | POST | `/api/v1/custom-domain/certificates` | Create (request) a certificate |
| | POST | `/api/v1/custom-domain/certificates/{id}/upload-chain` | Upload certificate chain |
| | POST | `/api/v1/custom-domain/certificates/{id}/activate` | Activate certificate on domains |
| | POST | `/api/v1/custom-domain/certificates/{id}/deactivate` | Deactivate a certificate |
| | DELETE | `/api/v1/custom-domain/certificates/{id}` | Delete a certificate |
| **TLS Configs** | GET | `/api/v1/custom-domain/tls-configurations` | List TLS configurations |
| | GET | `/api/v1/custom-domain/tls-configurations/{id}` | Get TLS config details |
| | POST | `/api/v1/custom-domain/tls-configurations` | Create a TLS configuration |
| | PUT | `/api/v1/custom-domain/tls-configurations/{id}` | Update a TLS configuration |
| | DELETE | `/api/v1/custom-domain/tls-configurations/{id}` | Delete a TLS configuration |
| **Mappings** | GET | `/api/v1/custom-domain/mappings` | List domain mappings |
| | GET | `/api/v1/custom-domain/mappings/{id}` | Get mapping details |
| | POST | `/api/v1/custom-domain/mappings` | Create a domain mapping |
| | DELETE | `/api/v1/custom-domain/mappings/{id}` | Delete a mapping |
| **Trusted Certs** | GET | `/api/v1/custom-domain/trusted-certificates` | List trusted certificates |
| | GET | `/api/v1/custom-domain/trusted-certificates/{id}` | Get trusted cert details |
| | POST | `/api/v1/custom-domain/trusted-certificates` | Upload a trusted certificate |
| | DELETE | `/api/v1/custom-domain/trusted-certificates/{id}` | Delete a trusted certificate |
| **DNS Records** | GET | `/api/v1/custom-domain/dns-records` | List DNS records |
| | GET | `/api/v1/custom-domain/dns-records/{id}` | Get DNS record details |
| | POST | `/api/v1/custom-domain/dns-records` | Create a DNS record |
| | PUT | `/api/v1/custom-domain/dns-records/{id}` | Update a DNS record |
| | DELETE | `/api/v1/custom-domain/dns-records/{id}` | Delete a DNS record |
| **Dashboard** | GET | `/api/v1/custom-domain/dashboard` | Get dashboard overview |
| | POST | `/api/v1/custom-domain/dashboard/refresh` | Refresh dashboard metrics |
| **Health** | GET | `/api/v1/health` | Service health check |

## Build & Run

### Prerequisites

- D compiler (LDC 1.40+)
- DUB package manager

### Local Development

```bash
# Build
dub build --config=defaultRun

# Run
./build/uim-custom-domain-platform-service

# Run tests
dub test
```

### Docker

```bash
# Build image
docker build -t uim-platform/cloud-custom-domain:latest .

# Run container
docker run -p 8101:8101 uim-platform/cloud-custom-domain:latest
```

### Podman

```bash
# Build image
podman build -t uim-platform/cloud-custom-domain:latest -f Containerfile .

# Run container
podman run -p 8101:8101 uim-platform/cloud-custom-domain:latest
```

### Kubernetes

```bash
# Apply manifests
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `CUSTOM_DOMAIN_HOST` | `0.0.0.0` | Bind address |
| `CUSTOM_DOMAIN_PORT` | `8101` | Listen port |

## Certificate Workflow

The typical workflow for setting up a custom domain with TLS:

1. **Create Domain** - Register the custom domain name
2. **Create Private Key** - Generate a key pair (RSA-2048, RSA-4096, ECDSA-P256, ECDSA-P384)
3. **Create Certificate** - Generate a CSR from the private key
4. **Upload Chain** - Upload the signed certificate chain from your CA
5. **Activate Certificate** - Activate the certificate on one or more domains
6. **Configure TLS** - Set protocol versions, cipher suites, HSTS, HTTP/2
7. **Create DNS Records** - Configure CNAME/A records pointing to the platform
8. **Map Routes** - Map standard application routes to the custom domain
9. **Enable Client Auth** (optional) - Upload trusted CA certificates for mTLS

## License

Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
