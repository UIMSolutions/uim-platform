# NAFv4 Architecture — UIM HANA Spatial Platform Service

NATO Architecture Framework version 4 (NAFv4) documentation for the UIM HANA Spatial Platform Service.

---

## C1 — Capability Taxonomy

| Capability | Description |
|---|---|
| C-GEO | Geocoding — convert postal addresses to geographic coordinates |
| C-RGEO | Reverse Geocoding — convert coordinates to postal addresses |
| C-ROUTE | Routing — calculate travel routes between coordinates |
| C-POI | Points of Interest — discover and manage geo-referenced POI |
| C-ISO | Isoline Calculation — compute reachability areas (time/distance) |
| C-GEO-FENCE | Geofence Management — define zones and check coordinate containment |
| C-SLAYER | Spatial Layer Management — manage geographic data layers |
| C-SFEAT | Spatial Feature Management — manage GeoJSON features within layers |
| C-PROV | Provider Management — configure and manage geolocation data providers |
| C-BATCH | Batch Geocoding — process large address datasets asynchronously |

---

## C2 — Enterprise Vision

The UIM HANA Spatial Platform Service provides a cloud-native, tenant-aware geospatial microservice compatible with the SAP BTP service portfolio. It enables SAP BTP applications to perform geolocation operations without direct dependency on proprietary SAP HANA Spatial engine instances. It exposes standardized REST APIs and is deployed as a container on Kubernetes.

---

## L1 — Logical Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                   UIM HANA Spatial Service                       │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Presentation Layer                                       │   │
│  │  HTTP REST API · CLI (stub) · Web UI (stub) · GUI (stub) │   │
│  └───────────────────────┬──────────────────────────────────┘   │
│                          │                                       │
│  ┌───────────────────────▼──────────────────────────────────┐   │
│  │  Application Layer                                        │   │
│  │  Use Cases · DTOs · Orchestration                        │   │
│  └───────────────────────┬──────────────────────────────────┘   │
│                          │                                       │
│  ┌───────────────────────▼──────────────────────────────────┐   │
│  │  Domain Layer                                             │   │
│  │  Entities · Value Objects · Repository Ports · Enums     │   │
│  │  Domain Services (SpatialValidator, Haversine calc)      │   │
│  └───────────────────────┬──────────────────────────────────┘   │
│                          │                                       │
│  ┌───────────────────────▼──────────────────────────────────┐   │
│  │  Infrastructure Layer                                     │   │
│  │  Memory Repositories · DI Container · Config             │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## L2 — Logical Node Types

| Node | Role |
|---|---|
| `GeocodingController` | Handles HTTP geocoding and reverse geocoding requests |
| `RoutingController` | Handles route calculation and retrieval |
| `PoiController` | Handles POI CRUD operations |
| `IsolineController` | Handles isoline calculation and retrieval |
| `GeofenceController` | Handles geofence CRUD and point-in-zone checks |
| `SpatialLayerController` | Handles spatial layer CRUD |
| `SpatialFeatureController` | Handles spatial feature CRUD and layer-scoped queries |
| `ProviderController` | Handles spatial provider CRUD |
| `GeocodingJobController` | Handles batch geocoding job lifecycle |
| `HealthController` | Provides health check endpoint |
| `ManageXxxUseCase` | Orchestrates domain operations per resource type |
| `MemoryXxxRepository` | In-memory implementation of domain repository port |
| `SpatialValidator` | Domain validation service |
| `Container` | Dependency injection container |

---

## P1 — Physical Deployment

```
┌──────────────────────────────────────────────┐
│  Kubernetes Cluster                           │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │  Deployment: cloud-hana-spatial      │   │
│  │  Image: uim-platform/hana-spatial    │   │
│  │  Port: 8098                          │   │
│  │  Memory: 64Mi req / 256Mi limit      │   │
│  │  CPU: 50m req / 500m limit           │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │  Service: cloud-hana-spatial         │   │
│  │  Type: ClusterIP                     │   │
│  │  Port: 8098                          │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │  ConfigMap: cloud-hana-spatial-config│   │
│  │  HANA_SPATIAL_HOST: 0.0.0.0          │   │
│  │  HANA_SPATIAL_PORT: 8098             │   │
│  └──────────────────────────────────────┘   │
└──────────────────────────────────────────────┘
```

---

## Ar — Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-001 | Hexagonal architecture | Decouples business logic from I/O concerns; enables multiple repository backends (memory, file, MongoDB) |
| AD-002 | Tenant-aware repositories | All data is scoped by tenant ID enabling multi-tenancy |
| AD-003 | In-memory repositories as default | Allows running without external databases for development and testing |
| AD-004 | vibe.d HTTP framework | High-performance async I/O, native D language integration |
| AD-005 | LDC2 compiler in Docker | Better optimization and smaller binaries than DMD |
| AD-006 | Port 8098 | Avoids conflicts with common SAP BTP service ports |
| AD-007 | MVC stubs for CLI/Web/GUI | Establishes architectural contract for future UI layers |
| AD-008 | Haversine formula for circular geofence checks | Accurate great-circle distance calculation without external library dependency |

---

## StV — Standards

| Standard | Usage |
|---|---|
| OpenAPI / REST | HTTP API design |
| GeoJSON | Geometry representation for spatial features |
| WGS84 | Default coordinate reference system |
| ISO 3166-1 alpha-2 | Country codes |
| RFC 7519 (JWT) | Tenant identification via HTTP headers |
| OCI / Docker | Container image format |
| Kubernetes API v1 / apps/v1 | Deployment, Service, ConfigMap manifests |
