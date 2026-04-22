# UIM Platform — Keystore Service

A SAP BTP Keystore Service-compatible microservice built with **D** (dlang), **vibe.d**, and **Hexagonal / Clean Architecture**. Deployable with Docker, Podman, and Kubernetes.

---

## Overview

The Keystore Service provides a repository for cryptographic keys and certificates. Applications can store keystores in JKS, JCEKS, P12, or PEM format, retrieve them by name using a three-level scope hierarchy, list their entries, and securely store the passwords that protect them.

This service mirrors the SAP BTP Neo Keystore Service API:
- `list-keystores` → `GET /api/v1/keystores`
- `upload-keystore` → `POST /api/v1/keystores`
- `download-keystore` → `GET /api/v1/keystores/{id}` or `GET /api/v1/keystores/resolve?name=…`
- `delete-keystore` → `DELETE /api/v1/keystores/{id}`
- Password Storage API → `/api/v1/passwords`

---

## Supported Keystore Formats

| Format | Description |
|--------|-------------|
| JKS    | Java KeyStore — password-protected, password-based integrity |
| JCEKS  | Extended JKS — stronger private-key protection |
| P12    | PKCS#12 — password-based symmetric encryption |
| PEM    | Privacy Enhanced Mail — no integrity validation, plain entries |

---

## Keystore Scope Hierarchy

When resolving a keystore by name the service searches in the following order (most specific wins):

```
Subscription level → Application level → Account level
```

---

## API Endpoints

### Keystores

| Method | Path | Description |
|--------|------|-------------|
| POST   | `/api/v1/keystores` | Upload a new keystore (upload-keystore) |
| GET    | `/api/v1/keystores?accountId=&applicationId=` | List keystores (list-keystores) |
| GET    | `/api/v1/keystores/{id}` | Download keystore by ID |
| PUT    | `/api/v1/keystores/{id}` | Update description or content |
| DELETE | `/api/v1/keystores/{id}` | Delete a keystore (delete-keystore) |
| GET    | `/api/v1/keystores/resolve?name=&accountId=&applicationId=&subscriptionId=` | Resolve by name using scope hierarchy |

### Key Entries

| Method | Path | Description |
|--------|------|-------------|
| POST   | `/api/v1/keystores/{id}/entries` | Import a key or certificate entry |
| GET    | `/api/v1/keystores/{id}/entries` | List entries in a keystore |
| GET    | `/api/v1/keystores/{id}/entries/{entryId}` | Get a single entry |
| DELETE | `/api/v1/keystores/{id}/entries/{entryId}` | Remove an entry |

### Password Storage

| Method | Path | Description |
|--------|------|-------------|
| PUT    | `/api/v1/passwords/{alias}` | Store or update a password |
| GET    | `/api/v1/passwords/{alias}?accountId=&applicationId=` | Retrieve password metadata |
| DELETE | `/api/v1/passwords/{alias}?accountId=&applicationId=` | Delete a stored password |
| GET    | `/api/v1/passwords?accountId=&applicationId=` | List stored passwords |

### Health

| Method | Path | Description |
|--------|------|-------------|
| GET    | `/api/v1/health` | Liveness / readiness probe |

---

## Configuration

| Environment Variable | Default   | Description |
|----------------------|-----------|-------------|
| `KEYSTORE_HOST`      | `0.0.0.0` | Bind address |
| `KEYSTORE_PORT`      | `8115`    | HTTP listen port |

---

## Running Locally

```bash
# Build
dub build --config=defaultRun

# Run
./build/uim-keystore-platform-service
```

---

## Docker / Podman

```bash
# Docker
docker build -t uim-platform/keystore:latest .
docker run -p 8115:8115 uim-platform/keystore:latest

# Podman
podman build -t uim-platform/keystore:latest -f Containerfile .
podman run -p 8115:8115 uim-platform/keystore:latest
```

---

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

---

## Architecture

See [UML.md](UML.md) for structural diagrams and [NAFv4.md](NAFv4.md) for architectural viewpoints.

---

## Security Notes

- Passwords stored via the Password Storage API are **never returned in plain text** — only metadata (alias, timestamps) is exposed.
- The service runs as a non-root `appuser` inside the container.
- The container filesystem is read-only (`readOnlyRootFilesystem: true`).
- Keystore `content` fields carry base64-encoded binary data — no raw binary transmission.
