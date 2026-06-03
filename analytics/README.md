# Analytics Service

Analytics microservice with D and vibe.d that follows a hybrid of Clean Architecture and Hexagonal Architecture, inspired by capability domains of SAP Analytics Cloud in SAP Business Data Cloud.

The implementation focuses on feature categories (data preparation, modeling, visualization assets, sharing lifecycle, API access) and does not replicate SAP proprietary implementations.

## Core Capabilities

- Insight asset lifecycle (create, read, update, delete)
- Asset metadata for stories, dashboards, data models, and planning views
- Publish action for collaborative consumption
- Tenant-aware APIs via `tenantId` query parameter
- Storage backends: memory, files, MongoDB
- HTTP API plus MVC components in CLI, Web, and GUI presentation channels

## Architecture

```text
source/
  uim/platform/analytics/
    domain/            # Entities, value types, repository ports, validation rules
    application/       # DTOs, use case orchestration
    infrastructure/    # Config, DI container, persistence adapters
    presentation/
      http/            # REST API controllers
      cli/             # CLI MVC
      web/             # Web MVC
      gui/             # GUI MVC
```

## REST Endpoints

| Method | Path | Description |
| --- | --- | --- |
| `GET` | `/api/v1/health` | Health probe |
| `GET` | `/api/v1/analytics/assets?tenantId=<t>` | List assets |
| `POST` | `/api/v1/analytics/assets?tenantId=<t>` | Create asset |
| `GET` | `/api/v1/analytics/assets/<id>?tenantId=<t>` | Get asset |
| `PUT` | `/api/v1/analytics/assets/<id>?tenantId=<t>` | Update asset |
| `DELETE` | `/api/v1/analytics/assets/<id>?tenantId=<t>` | Delete asset |
| `POST` | `/api/v1/analytics/assets/<id>/publish?tenantId=<t>` | Publish asset |
| `GET` | `/web?tenantId=<t>` | Web dashboard |
| `GET` | `/gui?tenantId=<t>` | GUI tile view |

## Example Payload

```json
{
  "name": "Revenue Pulse Q2",
  "kind": "story",
  "sourceSystem": "sap-datasphere",
  "dimensions": ["region", "segment", "product"],
  "measures": ["revenue", "margin"]
}
```

## Configuration

| Variable | Default | Description |
| --- | --- | --- |
| `ANALYTICS_HOST` | `0.0.0.0` | Bind host |
| `ANALYTICS_PORT` | `8112` | Bind port |
| `ANALYTICS_STORAGE` | `memory` | `memory`, `files`, `mongodb` |
| `ANALYTICS_DATA_PATH` | `/data/analytics` | File persistence directory |
| `ANALYTICS_MONGO_URI` | empty | MongoDB URI |
| `ANALYTICS_MONGO_DB` | `analytics` | MongoDB database name |

## Run Locally

```bash
cd analytics
dub run
```

CLI mode (prints overview and exits):

```bash
cd analytics
dub run -- --cli --tenant myTenant
```

Or via environment variable:

```bash
ANALYTICS_RUN_MODE=cli dub run
```

## Run Tests

```bash
cd analytics
dub test
```

To run integration tests against a real MongoDB instance:

```bash
ANALYTICS_TEST_MONGO_URI=mongodb://localhost:27017 dub test
```

## Docker

```bash
cd analytics
docker build -t uim-platform/analytics .
docker run --rm -p 8112:8112 \
  -e ANALYTICS_STORAGE=files \
  -e ANALYTICS_DATA_PATH=/data/analytics \
  uim-platform/analytics
```

## Podman

```bash
cd analytics
podman build -t uim-platform/analytics -f Containerfile .
podman run --rm -p 8112:8112 uim-platform/analytics
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

To enable MongoDB in Kubernetes, create `analytics-secrets` with key `mongo-uri` and set `ANALYTICS_STORAGE=mongodb` in the ConfigMap.

## SAP Feature Inspiration Mapping

| SAP Analytics Cloud Feature | This Service |
| --- | --- |
| Data preparation and connections | `sourceSystem`, dimensions, measures metadata |
| Stories and dashboards | `kind` field: `story`, `dashboard`, `model`, `planning` |
| Collaboration and sharing | Publish endpoint and lifecycle timestamping |
| API and automation | REST endpoint model for automation and embedding |
| Multi-tenancy | Tenant scoping via `tenantId` parameter |
| Persistence options | Pluggable memory / file / MongoDB adapters |

## License

See repository root LICENSE.
