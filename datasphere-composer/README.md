# Datasphere Data Composer — UIM Platform Service

A D-language microservice implementing the **SAP BDC Datasphere Data Composer** feature set, built with [vibe.d](https://vibed.org) and structured around **Hexagonal (Ports & Adapters)** and **Clean Architecture** principles.

---

## Overview

Datasphere Data Composer enables business users and administrators to:

- Register **Data Providers** (e.g. S/4 HANA Cloud Private Edition) and their **Data Products**
- Configure **Unification Rules** (deterministic/probabilistic) for identity resolution
- Define **Data Source Configs** and **Attribute Mappings** per product
- Trigger and monitor **Composition Runs** that produce unified **Customer Profiles**
- Manage **Tenant Users** with role-based access

---

## Architecture

```
presentation/
  http/         — REST API controllers (vibe.d)
  cli/          — CLI MVC (stub)
  web/          — Web MVC (stub)
  gui/          — GUI MVC (stub)
application/
  usecases/     — Use case classes per domain aggregate
  dto.d         — Request/response DTOs
domain/
  entities/     — Core entity structs
  ports/        — Repository interfaces
  services/     — Domain validation
  enumerations/ — Domain enums
  types/        — Value types and ID structs
infrastructure/
  config.d      — SrvConfig + loadConfig()
  container.d   — Dependency injection container
  persistence/
    memory/     — In-memory repository implementations
source/
  app.d         — Entry point
```

---

## Quick Start

### Build

```bash
cd datasphere-composer
dub build
```

### Run

```bash
./uim-datasphere-composer-platform-service
```

Or with custom port/host:

```bash
DATASPHERE_COMPOSER_HOST=127.0.0.1 DATASPHERE_COMPOSER_PORT=9000 ./uim-datasphere-composer-platform-service
```

### Docker / Podman

```bash
docker build -t cloud-datasphere-composer .
docker run -p 8099:8099 cloud-datasphere-composer

# Podman
podman build -t cloud-datasphere-composer -f Containerfile .
podman run -p 8099:8099 cloud-datasphere-composer
```

---

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/health` | Health check |
| GET/POST/PUT/DELETE | `/api/v1/composer/providers` | Data Providers CRUD |
| GET/POST/PUT/DELETE | `/api/v1/composer/products` | Data Products CRUD |
| GET | `/api/v1/composer/providers/*/products` | Products by provider |
| GET/POST/PUT/DELETE | `/api/v1/composer/rules` | Unification Rules CRUD |
| POST | `/api/v1/composer/rules/reorder` | Reorder rule priority |
| GET/POST/PUT/DELETE | `/api/v1/composer/configs` | Data Source Configs CRUD |
| POST | `/api/v1/composer/configs/*/identifierMappings` | Add identifier mapping |
| GET/POST/PUT/DELETE | `/api/v1/composer/mappings` | Attribute Mappings CRUD |
| GET | `/api/v1/composer/profiles` | List customer profiles |
| GET | `/api/v1/composer/profiles/*` | Get customer profile |
| POST | `/api/v1/composer/profiles/search` | Search profiles |
| POST | `/api/v1/composer/runs` | Start composition run |
| GET | `/api/v1/composer/runs` | List composition runs |
| GET | `/api/v1/composer/runs/*` | Get composition run |
| DELETE | `/api/v1/composer/runs/*` | Delete composition run |
| POST | `/api/v1/composer/runs/*/action` | Cancel run |
| GET/POST/PUT/DELETE | `/api/v1/composer/users` | Tenant Users CRUD |

All requests require the `X-Tenant-ID` header.

---

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DATASPHERE_COMPOSER_HOST` | `0.0.0.0` | Bind address |
| `DATASPHERE_COMPOSER_PORT` | `8099` | HTTP port |

---

## References

- [SAP BDC Data Composer Documentation](https://help.sap.com/docs/business-data-cloud/data-composer/data-composer?locale=en-US)
- [vibe.d](https://vibed.org)
- [D Language](https://dlang.org)
