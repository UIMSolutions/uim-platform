# Credential Store Service

A credential store service for the UIM Platform, inspired by the SAP Credential Store Service for SAP BTP. Built with D language (dlang), vibe.d HTTP framework, and clean/hexagonal architecture.

## Features

- **Namespaces** - Logical isolation of credentials with validated naming (letters, digits, special chars, up to 100 chars)
- **Password Credentials** - Store text-based secrets (up to 4096 chars) with name, value, metadata, format, username
- **Key Credentials** - Store binary keys (up to 32 KB base64-encoded) with name, value, metadata, format
- **Keyring Credentials** - Key Encryption Keys (KEKs) for envelope encryption with auto-versioning
- **Conditional Operations** - If-Match / If-None-Match headers for optimistic concurrency control
- **DEK Encryption** - Generate, encrypt, and decrypt Data Encryption Keys using keyring KEKs
- **Keyring Rotation** - Multi-version keyrings with configurable auto-rotation period (30-365 days)
- **Deletion Protection** - Keyrings must be disabled for 7+ days before deletion
- **Service Bindings** - Client credentials with permission levels (readOnly, readWrite, admin)
- **Audit Logging** - All operations logged with tenant, namespace, resource, and actor details
- **Multi-Tenancy** - Full tenant isolation via X-Tenant-Id header
- **Health Monitoring** - Health check endpoint for container orchestration

## Architecture

```
Clean Architecture + Hexagonal Architecture (Ports and Adapters)

Domain Layer (innermost)
  - Entities: Namespace, Credential, KeyringVersion, ServiceBinding, AuditLogEntry
  - Ports: Repository interfaces (driven adapter contracts)
  - Services: CredentialValidator, KeyringManager, EncryptionService

Application Layer
  - DTOs: Request/Response data transfer objects
  - Use Cases: ManageNamespaces, ManageCredentials, ManageKeyrings,
               EncryptDek, ManageServiceBindings, GetAuditLogs, GetOverview

Infrastructure Layer
  - Config: Environment-based configuration
  - Container: Dependency injection wiring
  - Persistence: In-memory repository implementations

Presentation Layer (outermost)
  - HTTP Controllers: vibe.d REST API handlers
  - JSON Utils: Serialization helpers
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| CRUD | `/api/v1/namespaces` | Manage namespaces |
| CRUD | `/api/v1/passwords` | Manage password credentials |
| CRUD | `/api/v1/keys` | Manage key credentials |
| CRUD | `/api/v1/keyrings` | Manage keyring credentials |
| POST | `/api/v1/keyrings/rotate` | Rotate a keyring (create new version) |
| POST | `/api/v1/keyrings/disable` | Disable a keyring for deletion |
| POST | `/api/v1/encryption/generate` | Generate a new DEK and encrypt it |
| POST | `/api/v1/encryption/encrypt` | Encrypt an existing DEK |
| POST | `/api/v1/encryption/decrypt` | Decrypt an encrypted DEK |
| CRUD | `/api/v1/bindings` | Manage service bindings |
| GET | `/api/v1/audit-logs` | List audit log entries |
| GET | `/api/v1/audit-logs/{id}` | Get audit log entry by ID |
| GET | `/api/v1/overview` | Get system overview summary |
| GET | `/api/v1/health` | Health check |

### Conditional Operations

- **Create only if not exists**: `POST /api/v1/passwords` with `If-None-Match: *`
- **Update only if version matches**: `POST /api/v1/passwords` with `If-Match: <version>`
- **Read only if changed**: `GET /api/v1/passwords/{id}` with `If-None-Match: <version>` (returns 304 if unchanged)

All endpoints expect `X-Tenant-Id` header for multi-tenancy. Credential endpoints also accept `X-Namespace-Id`.

## Build

```bash
# Build
dub build --config=defaultRun

# Run
./build/uim-credential-store-platform-service

# Test
dub test
```

## Container

```bash
# Docker
docker build -t uim-platform/credential-store:latest .
docker run -p 8095:8095 uim-platform/credential-store:latest

# Podman
podman build -f Containerfile -t uim-platform/credential-store:latest .
podman run -p 8095:8095 uim-platform/credential-store:latest
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `CREDSTORE_HOST` | `0.0.0.0` | Bind address |
| `CREDSTORE_PORT` | `8095` | Listen port |

## License

Apache 2.0 - See [LICENSE](../LICENSE) for details.
