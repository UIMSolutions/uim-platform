# UIM HANA Spatial Platform Service

A microservice for SAP BTP-compatible spatial and geolocation capabilities, modeled on **SAP HANA Spatial Services for SAP BTP**. Built with D Language and vibe.d using hexagonal (ports & adapters) architecture.

## Overview

This service provides geocoding, reverse geocoding, routing, Points of Interest (POI), isoline calculation, geofence zone management, spatial layer/feature management, provider management, and batch geocoding jobs.

Port: **8098**

## Features

| Feature | Endpoint | Description |
|---|---|---|
| Forward Geocoding | `POST /api/v1/spatial/geocode` | Convert address to coordinates |
| Reverse Geocoding | `POST /api/v1/spatial/reverseGeocode` | Convert coordinates to address |
| Geocoding Results | `GET/DELETE /api/v1/spatial/geocode` | List and manage geocoding results |
| Route Calculation | `CRUD /api/v1/spatial/routes` | Calculate and store routes |
| Points of Interest | `CRUD /api/v1/spatial/poi` | Manage POI database |
| Isoline Calculation | `CRUD /api/v1/spatial/isolines` | Reachability area calculation |
| Geofence Zones | `CRUD /api/v1/spatial/geofences` | Define and manage geofence zones |
| Geofence Check | `POST /api/v1/spatial/geofences/check` | Check if a point is inside a zone |
| Spatial Layers | `CRUD /api/v1/spatial/layers` | Manage geographic data layers |
| Spatial Features | `CRUD /api/v1/spatial/features` | Manage GeoJSON features |
| Providers | `CRUD /api/v1/spatial/providers` | Manage geolocation provider configs |
| Batch Geocoding | `CRUD /api/v1/spatial/geocodingJobs` | Batch geocoding job management |
| Job Action | `POST /api/v1/spatial/geocodingJobs/:id/action` | Start/cancel a batch job |
| Health | `GET /api/v1/health` | Health check endpoint |

## Architecture

Hexagonal (Ports and Adapters) architecture with 4 layers:

```
presentation/   ← HTTP controllers, CLI, Web, GUI (MVC stubs)
application/    ← Use cases, DTOs
domain/         ← Entities, value objects, port interfaces, domain services
infrastructure/ ← Memory/file/MongoDB repositories, DI container, config
```

## Running Locally

### Prerequisites

- [D Language](https://dlang.org/) with LDC2 compiler
- [dub](https://dub.pm/) build tool

### Build and Run

```bash
cd hana-spatial
dub run --config=executable
```

Service starts on `http://0.0.0.0:8098`.

### Environment Variables

| Variable | Default | Description |
|---|---|---|
| `HANA_SPATIAL_HOST` | `0.0.0.0` | Bind address |
| `HANA_SPATIAL_PORT` | `8098` | Listening port |

## Docker / Podman

```bash
# Build
docker build -t uim-platform/hana-spatial:latest .
# or
podman build -t uim-platform/hana-spatial:latest .

# Run
docker run -p 8098:8098 uim-platform/hana-spatial:latest
# or
podman run -p 8098:8098 uim-platform/hana-spatial:latest
```

## Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## API Examples

### Forward Geocoding

```http
POST /api/v1/spatial/geocode
Content-Type: application/json
X-Tenant-ID: tenant-1

{
  "address": "Dietmar-Hopp-Allee 16, 69190 Walldorf, Germany",
  "providerId": "here-maps",
  "language": "en"
}
```

### Reverse Geocoding

```http
POST /api/v1/spatial/reverseGeocode
Content-Type: application/json
X-Tenant-ID: tenant-1

{
  "latitude": 49.2986,
  "longitude": 8.6456,
  "providerId": "here-maps"
}
```

### Geofence Check

```http
POST /api/v1/spatial/geofences/check
Content-Type: application/json
X-Tenant-ID: tenant-1

{
  "zoneId": "zone-campus",
  "latitude": 49.2986,
  "longitude": 8.6456
}
```

### Create Batch Geocoding Job

```http
POST /api/v1/spatial/geocodingJobs
Content-Type: application/json
X-Tenant-ID: tenant-1

{
  "name": "Customer Addresses Import",
  "providerId": "here-maps",
  "countryCode": "DE",
  "addresses": [
    "Dietmar-Hopp-Allee 16, 69190 Walldorf",
    "Hasso-Plattner-Ring 7, 69190 Walldorf"
  ]
}
```

## License

Apache 2.0 — see [LICENSE](../LICENSE)
