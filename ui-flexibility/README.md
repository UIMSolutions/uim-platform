# UIM UI Flexibility Platform Service

A SAP BTP-compatible **UI Flexibility** service built with **D language** and **vibe.d**, following a strict **Hexagonal + Clean Architecture**. It manages SAPUI5 flexibility artefacts — change records, variants, versions, drafts, and end-user personalizations — across multiple tenants, with pluggable storage backends (memory, files, MongoDB).

---

## Features

- Key User Adaptation API (`/keyuser/v2/`)
- End-User Personalization API (`/user/v2/`)
- Application Registry API (`/api/v2/`)
- Multi-tenant isolation
- Three storage backends: **memory** (default), **files** (JSON), **MongoDB** (stub)
- MVC pattern in CLI, Web, and GUI presentation layers
- Docker / Podman / Kubernetes ready

---

## API Endpoints

### Key User API

| Method   | Path                                    | Description                            |
|----------|-----------------------------------------|----------------------------------------|
| `POST`   | `/keyuser/v2/changes`                   | Create a flex change record            |
| `GET`    | `/keyuser/v2/changes`                   | List changes (filter: `?appId=`, `?layer=`) |
| `GET`    | `/keyuser/v2/changes/{id}`              | Get a single change                    |
| `PUT`    | `/keyuser/v2/changes/{id}`              | Update a change                        |
| `DELETE` | `/keyuser/v2/changes/{id}`              | Delete a change                        |
| `POST`   | `/keyuser/v2/variants`                  | Create a variant                       |
| `GET`    | `/keyuser/v2/variants`                  | List variants (`?appId=`, `?public=true`) |
| `GET`    | `/keyuser/v2/variants/{id}`             | Get a variant                          |
| `PUT`    | `/keyuser/v2/variants/{id}`             | Update a variant                       |
| `DELETE` | `/keyuser/v2/variants/{id}`             | Delete a variant                       |
| `POST`   | `/keyuser/v2/versions`                  | Create a version                       |
| `GET`    | `/keyuser/v2/versions`                  | List versions (`?appId=`)              |
| `GET`    | `/keyuser/v2/versions/{id}`             | Get a version                          |
| `PUT`    | `/keyuser/v2/versions/{id}`             | Update a version                       |
| `POST`   | `/keyuser/v2/versions/{id}/activate`    | Activate a version (archives current)  |
| `DELETE` | `/keyuser/v2/versions/{id}`             | Delete a version                       |
| `POST`   | `/keyuser/v2/drafts`                    | Create a draft (one per app/tenant)    |
| `GET`    | `/keyuser/v2/drafts`                    | List drafts                            |
| `GET`    | `/keyuser/v2/drafts/{id}`               | Get a draft by ID                      |
| `PUT`    | `/keyuser/v2/drafts/{id}`               | Update draft (add/remove change IDs)   |
| `DELETE` | `/keyuser/v2/drafts/{id}`               | Discard a draft                        |

### User Personalization API

| Method   | Path                                       | Description                         |
|----------|--------------------------------------------|-------------------------------------|
| `POST`   | `/user/v2/personalizations`                | Create personalization               |
| `GET`    | `/user/v2/personalizations`                | List (`?appId=&userId=`)             |
| `GET`    | `/user/v2/personalizations/{id}`           | Get by ID                            |
| `PUT`    | `/user/v2/personalizations/{id}`           | Update                               |
| `DELETE` | `/user/v2/personalizations/{id}`           | Delete single personalization        |

### Application Registry API

| Method   | Path                          | Description                   |
|----------|-------------------------------|-------------------------------|
| `POST`   | `/api/v2/applications`        | Register an application        |
| `GET`    | `/api/v2/applications`        | List apps (`?active=true`)     |
| `GET`    | `/api/v2/applications/{id}`   | Get an app                     |
| `PUT`    | `/api/v2/applications/{id}`   | Update an app                  |
| `DELETE` | `/api/v2/applications/{id}`   | Delete an app                  |

### Observability

| Method | Path              | Description          |
|--------|-------------------|----------------------|
| `GET`  | `/api/v1/health`  | Health check (UP/DOWN) |

---

## Environment Variables

| Variable                   | Default              | Description                          |
|----------------------------|----------------------|--------------------------------------|
| `UIFLEXIBILITY_HOST`       | `0.0.0.0`            | Bind address                         |
| `UIFLEXIBILITY_PORT`       | `8098`               | HTTP port                            |
| `UIFLEXIBILITY_STORAGE`    | `memory`             | `memory` / `files` / `mongodb`       |
| `UIFLEXIBILITY_DATA_PATH`  | `/data/ui-flexibility` | File storage base directory        |
| `UIFLEXIBILITY_MONGO_URI`  | _(empty)_            | MongoDB connection URI               |

---

## Architecture

Hexagonal + Clean Architecture with four layers:

```
domain/          — Entities, value objects, repository ports, domain services
application/     — DTOs, use-case orchestration
infrastructure/  — Config, DI container, persistence (memory/files/mongodb)
presentation/    — HTTP controllers, CLI MVC, Web MVC, GUI MVC
```

---

## Build & Run

### Prerequisites

- [dlang](https://dlang.org/) with ldc or dmd
- [dub](https://dub.pm/) package manager

### Local

```sh
cd ui-flexibility
dub run
```

### Docker / Podman

```sh
# Docker
docker build -t uim-ui-flexibility-platform-service:2.0.0 .
docker run -p 8098:8098 uim-ui-flexibility-platform-service:2.0.0

# Podman
podman build -t uim-ui-flexibility-platform-service:2.0.0 .
podman run -p 8098:8098 uim-ui-flexibility-platform-service:2.0.0
```

### Kubernetes

```sh
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

### File storage mode

```sh
UIFLEXIBILITY_STORAGE=files UIFLEXIBILITY_DATA_PATH=/tmp/flex dub run
```

---

## Testing

```sh
dub test
```

---

## License

Apache 2.0 — see [LICENSE](../LICENSE).
