# Application Autoscaler — UIM Platform Service

A **SAP BTP Application Autoscaler**-compatible microservice built with **D (dlang)** and **vibe.d**, following **Hexagonal (Ports & Adapters)** and **Clean Architecture** principles.

---

## Overview

The Application Autoscaler automatically increases or decreases the number of application instances based on configurable scaling policies. It supports:

- **Dynamic scaling** — driven by live metric values (CPU, memory, response time, throughput, custom metrics)
- **Schedule-based scaling** — pre-defined recurring (weekly/monthly) or specific-date time windows
- **Custom metrics** — applications can submit their own metric values (e.g. job-queue depth)
- **Scaling history** — every scaling decision is recorded for audit and analysis

---

## Architecture

This service follows the **Hexagonal (Ports & Adapters)** pattern with four layers:

```
┌─────────────────────────────────────────────────┐
│  Presentation (Driving Adapters)                │
│  HTTP Controllers (vibe.d URLRouter)            │
├─────────────────────────────────────────────────┤
│  Application (Use Cases / Orchestration)        │
│  ManagePolicies · ManageBindings                │
│  ManageCustomMetrics · ScalingEngine            │
│  ManageScalingHistory                           │
├─────────────────────────────────────────────────┤
│  Domain (Pure Business Logic)                   │
│  Entities · Value Types · Domain Services       │
│  Ports (Repository Interfaces)                  │
├─────────────────────────────────────────────────┤
│  Infrastructure (Driven Adapters)               │
│  In-Memory Repositories · Config · Container   │
└─────────────────────────────────────────────────┘
```

---

## API Endpoints

| Method   | Path                                  | Description                          |
|----------|---------------------------------------|--------------------------------------|
| `POST`   | `/api/v1/policies`                    | Create scaling policy                |
| `GET`    | `/api/v1/policies`                    | List policies (by tenant)            |
| `GET`    | `/api/v1/policies/{id}`               | Get policy by ID                     |
| `PUT`    | `/api/v1/policies/{id}`               | Update scaling policy                |
| `DELETE` | `/api/v1/policies/{id}`               | Delete scaling policy                |
| `POST`   | `/api/v1/bindings`                    | Bind an application                  |
| `GET`    | `/api/v1/bindings`                    | List bindings (by tenant)            |
| `GET`    | `/api/v1/bindings/{id}`               | Get binding by ID                    |
| `DELETE` | `/api/v1/bindings/{id}`               | Unbind application                   |
| `POST`   | `/api/v1/bindings/{id}/policy`        | Attach policy to binding             |
| `POST`   | `/api/v1/apps/{appId}/metrics`        | Submit custom metric value(s)        |
| `GET`    | `/api/v1/apps/{appId}/metrics`        | Query custom metric values           |
| `POST`   | `/api/v1/scaling/trigger`             | Trigger scaling evaluation           |
| `GET`    | `/api/v1/apps/{appId}/scaling-history`| Get scaling history for app          |
| `GET`    | `/api/v1/scaling-history/{id}`        | Get a single scaling event           |
| `GET`    | `/api/v1/health`                      | Health check                         |

---

## Scaling Policy — Quick Reference

### Dynamic Scaling Rule

```json
{
  "instance_min_count": 1,
  "instance_max_count": 5,
  "scaling_rules": [
    {
      "metric_type": "cpu",
      "threshold": 80,
      "operator": ">=",
      "breach_duration_secs": 120,
      "cool_down_secs": 300,
      "adjustment": "+1"
    }
  ]
}
```

Supported `metric_type` values: `memoryused`, `memoryutil`, `cpu`, `cpuutil`, `disk`, `diskutil`, `throughput`, `responsetime`, or any custom name.

### Schedule-Based Scaling (Recurring)

```json
{
  "instance_min_count": 1,
  "instance_max_count": 10,
  "timezone": "Europe/Berlin",
  "recurring_schedules": [
    {
      "start_time": "08:00",
      "end_time": "18:00",
      "days_of_week": [1, 2, 3, 4, 5],
      "instance_min_count": 3,
      "instance_max_count": 10,
      "initial_min_instance_count": 3
    }
  ]
}
```

### Schedule-Based Scaling (Specific Date)

```json
{
  "specific_date_schedules": [
    {
      "start_date_time": "2026-06-01T08:00",
      "end_date_time": "2026-06-01T20:00",
      "instance_min_count": 5,
      "instance_max_count": 20,
      "initial_min_instance_count": 5
    }
  ]
}
```

---

## Custom Metrics

```json
POST /api/v1/apps/{appId}/metrics
{
  "metrics": [
    { "name": "jobqueue", "value": 142, "unit": "jobs", "timestamp": 1716700000000 }
  ]
}
```

A policy can reference a custom metric by name:

```json
{
  "scaling_rules": [
    {
      "metric_type": "jobqueue",
      "threshold": 100,
      "operator": ">=",
      "adjustment": "+1"
    }
  ]
}
```

---

## Configuration

| Environment Variable              | Default   | Description          |
|-----------------------------------|-----------|----------------------|
| `APPLICATION_AUTOSCALER_HOST`     | `0.0.0.0` | Bind address         |
| `APPLICATION_AUTOSCALER_PORT`     | `8097`    | Listen port          |

---

## Building

### Local (dub)

```bash
cd application-autoscaler
dub build --config=defaultRun
./build/uim-application-autoscaler-platform-service
```

### Docker / Podman

```bash
# Docker
docker build -t uim-platform/application-autoscaler:latest .

# Podman
podman build -t uim-platform/application-autoscaler:latest .

# Run
docker run -p 8097:8097 uim-platform/application-autoscaler:latest
```

### Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

---

## Health Check

```
GET /api/v1/health
```

Response:

```json
{ "status": "UP", "service": "application-autoscaler" }
```
