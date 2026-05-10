# UIM Platform — Authorization and Trust Management Service

A SAP BTP Authorization and Trust Management Service-compatible microservice built with **D** (dlang), **vibe.d**, and **Hexagonal / Clean Architecture**. Deployable with Docker, Podman, and Kubernetes.

---

## Overview

The Authorization and Trust Management Service (XSUAA-compatible) provides OAuth 2.0-based authorization and identity provider trust management for cloud applications. It mirrors the core capabilities of the SAP BTP Authorization and Trust Management Service (formerly XSUAA):

- **OAuth 2.0 Client Management** — Register and manage OAuth 2.0 client applications
- **Scope Management** — Define fine-grained authorization scopes
- **Role Management** — Bundle scopes into named role templates
- **Role Collection Management** — Aggregate roles into business-level role collections
- **User Authorization** — Assign role collections to users and groups
- **Trust Management** — Configure and manage trusted SAML 2.0 / OIDC identity providers
- **Token Endpoint** — Issue JWT access tokens (client credentials, authorization code flows)

Reference: [SAP Authorization and Trust Management Service](https://help.sap.com/viewer/product/CP_AUTHORIZ_TRUST_MNG/Cloud/en-US)

---

## Architecture

This service implements **Hexagonal (Ports & Adapters) Architecture** combined with **Clean Architecture** layering:

```
Presentation (Driving Adapters)
  └── HTTP REST Controllers (vibe.d)
Application Layer
  └── Use Cases + DTOs
Domain Layer
  └── Entities, Repository Ports, Domain Services
Infrastructure (Driven Adapters)
  └── In-Memory Repositories, Config, DI Container
```

---

## API Endpoints

### OAuth 2.0 Clients

| Method | Path | Description |
|--------|------|-------------|
| POST   | `/api/v1/oauth/clients` | Register a new OAuth 2.0 client |
| GET    | `/api/v1/oauth/clients` | List all OAuth 2.0 clients |
| GET    | `/api/v1/oauth/clients/*` | Get a client by ID |
| PUT    | `/api/v1/oauth/clients/*` | Update client configuration |
| DELETE | `/api/v1/oauth/clients/*` | Delete an OAuth 2.0 client |

### Scopes

| Method | Path | Description |
|--------|------|-------------|
| POST   | `/api/v1/scopes` | Create a new authorization scope |
| GET    | `/api/v1/scopes` | List all scopes |
| GET    | `/api/v1/scopes/*` | Get a scope by ID |
| PUT    | `/api/v1/scopes/*` | Update a scope |
| DELETE | `/api/v1/scopes/*` | Delete a scope |

### Roles

| Method | Path | Description |
|--------|------|-------------|
| POST   | `/api/v1/roles` | Create a role template |
| GET    | `/api/v1/roles` | List all roles |
| GET    | `/api/v1/roles/*` | Get a role by ID |
| PUT    | `/api/v1/roles/*` | Update a role |
| DELETE | `/api/v1/roles/*` | Delete a role |

### Role Collections

| Method | Path | Description |
|--------|------|-------------|
| POST   | `/api/v1/role-collections` | Create a role collection |
| GET    | `/api/v1/role-collections` | List all role collections |
| GET    | `/api/v1/role-collections/*` | Get a role collection by ID |
| PUT    | `/api/v1/role-collections/*` | Update a role collection |
| DELETE | `/api/v1/role-collections/*` | Delete a role collection |

### User Assignments

| Method | Path | Description |
|--------|------|-------------|
| POST   | `/api/v1/user-assignments` | Assign a role collection to a user |
| GET    | `/api/v1/user-assignments` | List all user-role assignments |
| GET    | `/api/v1/user-assignments/*` | Get an assignment by ID |
| DELETE | `/api/v1/user-assignments/*` | Remove a user assignment |

### Identity Providers (Trust)

| Method | Path | Description |
|--------|------|-------------|
| POST   | `/api/v1/identity-providers` | Register a trusted identity provider |
| GET    | `/api/v1/identity-providers` | List all identity providers |
| GET    | `/api/v1/identity-providers/*` | Get an identity provider by ID |
| PUT    | `/api/v1/identity-providers/*` | Update an identity provider |
| DELETE | `/api/v1/identity-providers/*` | Delete an identity provider |

### Token

| Method | Path | Description |
|--------|------|-------------|
| POST   | `/api/v1/oauth/token` | Issue an OAuth 2.0 access token |

### Health

| Method | Path | Description |
|--------|------|-------------|
| GET    | `/api/v1/health` | Service liveness / readiness check |

---

## Configuration

| Environment Variable | Default | Description |
|---------------------|---------|-------------|
| `AUTHORIZATION_TRUST_HOST` | `0.0.0.0` | Bind address |
| `AUTHORIZATION_TRUST_PORT` | `8116` | Listen port |

---

## Running with Docker

```bash
docker build -t uim-authorization-trust .
docker run -p 8116:8116 uim-authorization-trust
```

## Running with Podman

```bash
podman build -f Containerfile -t uim-authorization-trust .
podman run -p 8116:8116 uim-authorization-trust
```

## Deploying to Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

---

## Building from Source

```bash
dub build --config=defaultRun
./build/uim-authorization-trust-platform-service
```

---

## License

Apache-2.0 — Copyright 2018-2026, Ozan Nurettin Süel
