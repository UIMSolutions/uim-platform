# UIM Identity Platform Service

SAP Cloud Identity Services equivalent built with D (dlang), vibe.d, and hexagonal/clean architecture. Covers the four core components of SAP Cloud Identity Services:

- **Identity Authentication Service (IAS)** — user lifecycle, group management, application registration, identity provider federation
- **Identity Provisioning Service (IPS)** — provisioning job orchestration
- **Identity Directory** — canonical user/group store
- **Authorization Management** — application auth schemes and group-based access control

---

## Features

| Entity | Description | Endpoints |
|---|---|---|
| **Users** | Full user lifecycle (create, update, delete, search by email/status/type) | `/api/v1/ias/users` |
| **Groups** | User groups and authorization groups with member management | `/api/v1/ias/groups` |
| **Applications** | OIDC/SAML application registration with client credentials | `/api/v1/ias/applications` |
| **Identity Providers** | Corporate IdP federation (OIDC/SAML) with default IdP support | `/api/v1/ias/identity-providers` |
| **Provisioning Jobs** | Async provisioning orchestration with start/cancel lifecycle | `/api/v1/ips/provisioning-jobs` |

---

## Architecture

```
identity/
  source/
    app.d                              # Entry point
    uim/platform/identity/
      domain/                          # Entities, repository interfaces, domain services
        entities/                      # User, Group, Application, IdentityProvider, ProvisioningJob
        repositories/                  # Repository port interfaces
        services/                      # IdentityValidator
        enumerations.d
        types.d
      application/                     # Use cases and DTOs (business logic)
        dto.d
        usecases/manage/
      presentation/
        http/controllers/              # vibe.d REST controllers (HTTP adapter)
        cli/                           # CLI MVC (stdout rendering)
        web/                           # HTML MVC (browser-facing routes)
        gui/                           # Desktop GUI stub
      infrastructure/
        config.d                       # SrvConfig + loadConfig()
        container.d                    # buildContainer() dependency injection
        persistence/
          memory/                      # In-memory adapters (TenantRepository)
          file_/                       # File-based adapters (JSON on disk)
          mongo/                       # MongoDB adapters (vibe.db.mongo)
```

Hexagonal architecture — domain and application layers have **no** infrastructure dependencies. Adapters are selected at startup via `IDENTITY_BACKEND`.

---

## API Reference

### Health
| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/health` | Service health check |

### Identity Authentication Service (IAS)
| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/ias/users` | List users (tenant-scoped) |
| POST | `/api/v1/ias/users` | Create user |
| GET | `/api/v1/ias/users/:id` | Get user by ID |
| PUT | `/api/v1/ias/users/:id` | Update user |
| DELETE | `/api/v1/ias/users/:id` | Delete user |
| GET | `/api/v1/ias/groups` | List groups |
| POST | `/api/v1/ias/groups` | Create group |
| GET | `/api/v1/ias/groups/:id` | Get group |
| PUT | `/api/v1/ias/groups/:id` | Update group |
| DELETE | `/api/v1/ias/groups/:id` | Delete group |
| GET | `/api/v1/ias/applications` | List applications |
| POST | `/api/v1/ias/applications` | Register application |
| GET | `/api/v1/ias/applications/:id` | Get application |
| PUT | `/api/v1/ias/applications/:id` | Update application |
| DELETE | `/api/v1/ias/applications/:id` | Delete application |
| GET | `/api/v1/ias/identity-providers` | List identity providers |
| POST | `/api/v1/ias/identity-providers` | Add identity provider |
| GET | `/api/v1/ias/identity-providers/:id` | Get identity provider |
| PUT | `/api/v1/ias/identity-providers/:id` | Update identity provider |
| DELETE | `/api/v1/ias/identity-providers/:id` | Remove identity provider |

### Identity Provisioning Service (IPS)
| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/ips/provisioning-jobs` | List provisioning jobs |
| POST | `/api/v1/ips/provisioning-jobs` | Create provisioning job |
| GET | `/api/v1/ips/provisioning-jobs/:id` | Get provisioning job |
| DELETE | `/api/v1/ips/provisioning-jobs/:id` | Delete provisioning job |
| POST | `/api/v1/ips/provisioning-jobs/:id/start` | Start a job |
| POST | `/api/v1/ips/provisioning-jobs/:id/cancel` | Cancel a job |

### Web UI
| Method | Path | Description |
|---|---|---|
| GET | `/web/identity/users` | HTML user list |
| GET | `/web/identity/groups` | HTML group list |
| GET | `/web/identity/applications` | HTML application list |

---

## Hexagonal Port/Adapter Map

| Port (Interface) | Memory Adapter | File Adapter | MongoDB Adapter |
|---|---|---|---|
| `UserRepository` | `MemoryUserRepository` | `FileUserRepository` | `MongoUserRepository` |
| `GroupRepository` | `MemoryGroupRepository` | `FileGroupRepository` | `MongoGroupRepository` |
| `ApplicationRepository` | `MemoryApplicationRepository` | `FileApplicationRepository` | `MongoApplicationRepository` |
| `IdentityProviderRepository` | `MemoryIdentityProviderRepository` | `FileIdentityProviderRepository` | `MongoIdentityProviderRepository` |
| `ProvisioningJobRepository` | `MemoryProvisioningJobRepository` | `FileProvisioningJobRepository` | `MongoProvisioningJobRepository` |

---

## Configuration

| Environment Variable | Default | Description |
|---|---|---|
| `IDENTITY_HOST` | `0.0.0.0` | Bind address |
| `IDENTITY_PORT` | `8121` | Listen port |
| `IDENTITY_BACKEND` | `memory` | Persistence backend (`memory`, `file`, `mongodb`) |
| `IDENTITY_DATA_DIR` | `/data/identity` | Data directory for file backend |
| `IDENTITY_MONGO_URI` | `mongodb://localhost:27017` | MongoDB connection URI |
| `IDENTITY_MONGO_DB` | `uim_identity` | MongoDB database name |

---

## Docker / Podman

```bash
# Build
docker build -t uim-platform/identity:latest .
# or
podman build -t uim-platform/identity:latest .

# Run (memory backend)
docker run -p 8121:8121 uim-platform/identity:latest

# Run (file backend)
docker run -p 8121:8121 -v /host/data:/data/identity \
  -e IDENTITY_BACKEND=file uim-platform/identity:latest

# Run (MongoDB backend)
docker run -p 8121:8121 \
  -e IDENTITY_BACKEND=mongodb \
  -e IDENTITY_MONGO_URI=mongodb://mongo:27017 \
  uim-platform/identity:latest
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
