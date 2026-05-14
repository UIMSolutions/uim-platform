# NAFv4 Architecture Description — Application Autoscaler Service

## 1. Introduction

This document describes the architecture of the **Application Autoscaler** microservice in the **UIM Platform** using the NATO Architecture Framework version 4 (NAFv4) viewpoints.

**Service:** `uim-application-autoscaler-platform-service`  
**Domain:** Cloud Platform Services — Elastic Compute Management  
**Standard Reference:** SAP BTP Application Autoscaler (Cloud Foundry)  
**Technology Stack:** D (dlang), vibe.d, Hexagonal Architecture, Clean Architecture  
**Runtime Targets:** Docker, Podman, Kubernetes (K8s)

---

## 2. NAFv4 Viewpoints

### 2.1 Capability View (C1) — Strategic Capabilities

| Capability                         | Description                                                              |
|------------------------------------|--------------------------------------------------------------------------|
| Dynamic Auto-Scaling               | Scale application instances automatically based on real-time metrics     |
| Schedule-Based Scaling             | Pre-configure scale-out/in for known peak or off-peak periods            |
| Custom Metric Ingestion            | Accept and evaluate application-defined metrics for scaling decisions    |
| Scaling Policy Management          | Create, update, delete, and query scaling policies per application        |
| Application Binding                | Bind and unbind applications to/from the autoscaler service              |
| Scaling Audit Trail                | Record and query a complete history of all scaling events                |
| Health Monitoring                  | Expose liveness/readiness endpoint for container orchestration           |

---

### 2.2 Operational Node Connectivity (NOC / C2)

```
┌──────────────────┐         REST/HTTP         ┌──────────────────────────┐
│  Platform Client  │ ─────────────────────────> │ Application Autoscaler   │
│  (CF CLI / API)   │                            │ Service (:8097)          │
└──────────────────┘                            └──────────────┬───────────┘
                                                               │
                                         ┌─────────────────────▼──────────────────────┐
                                         │  UIM Platform Kubernetes / Cloud Foundry   │
                                         │  (App instances managed via binding API)   │
                                         └────────────────────────────────────────────┘
```

---

### 2.3 Systems Interface (S1) — Interfaces

| Interface                   | Protocol | Direction  | Description                                  |
|-----------------------------|----------|------------|----------------------------------------------|
| Scaling Policy API          | HTTP/JSON| Inbound    | CRUD for scaling policies                    |
| App Binding API             | HTTP/JSON| Inbound    | Bind/unbind applications                     |
| Custom Metrics API          | HTTP/JSON| Inbound    | Submit custom metric values from applications|
| Scaling Trigger API         | HTTP/JSON| Inbound    | Trigger scaling evaluation (metric + value)  |
| Scaling History API         | HTTP/JSON| Inbound    | Query scaling event audit log                |
| Health API                  | HTTP/JSON| Inbound    | Liveness/readiness probe for orchestrators   |

---

### 2.4 Service Decomposition (Sv1) — Service Layers

#### 2.4.1 Presentation Layer (Driving Adapters)

| Controller                   | Endpoint Prefix                     | Responsibility                    |
|------------------------------|-------------------------------------|-----------------------------------|
| `ScalingPolicyController`    | `/api/v1/policies`                  | CRUD for scaling policies         |
| `AppBindingController`       | `/api/v1/bindings`                  | Bind/unbind applications          |
| `CustomMetricController`     | `/api/v1/apps/{id}/metrics`         | Submit and query custom metrics   |
| `ScalingEngineController`    | `/api/v1/scaling/trigger`           | Trigger scaling evaluation        |
| `ScalingHistoryController`   | `/api/v1/apps/{id}/scaling-history` | Query audit history               |
| `HealthController`           | `/api/v1/health`                    | Health check                      |

#### 2.4.2 Application Layer (Use Cases)

| Use Case                         | Responsibility                                                       |
|----------------------------------|----------------------------------------------------------------------|
| `ManageScalingPoliciesUseCase`   | Create/update/delete/query scaling policies                          |
| `ManageAppBindingsUseCase`       | Create/update/delete bindings, attach policy to binding             |
| `ManageCustomMetricsUseCase`     | Submit metric samples, query latest value per metric name            |
| `ScalingEngineUseCase`           | Evaluate policies against metric values, trigger instance adjustment|
| `ManageScalingHistoryUseCase`    | Query scaling history by app or time range                           |

#### 2.4.3 Domain Layer (Core)

| Element                        | Type              | Description                                          |
|--------------------------------|-------------------|------------------------------------------------------|
| `ScalingPolicyEntity`          | Aggregate Root    | Policy with rules, schedules, and bounds             |
| `ScalingRuleEntity`            | Value Object      | A single dynamic scaling rule (metric + threshold)   |
| `RecurringScheduleEntity`      | Value Object      | Weekly/monthly schedule window                       |
| `SpecificDateScheduleEntity`   | Value Object      | One-time date/time schedule window                   |
| `AppBindingEntity`             | Entity            | Application registered with the autoscaler           |
| `CustomMetricEntity`           | Event / Record    | A submitted metric sample                            |
| `ScalingHistoryEntity`         | Immutable Record  | Audit record of a scaling event                      |
| `ScalingEvaluatorService`      | Domain Service    | Pure function: evaluate rules against metric value   |
| Repository Interfaces          | Ports             | `ScalingPolicyRepository`, `AppBindingRepository`, etc. |

#### 2.4.4 Infrastructure Layer (Driven Adapters)

| Component                           | Description                                                |
|-------------------------------------|------------------------------------------------------------|
| `MemoryScalingPolicyRepository`     | In-memory policy store (port implementation)               |
| `MemoryAppBindingRepository`        | In-memory binding store                                    |
| `MemoryCustomMetricRepository`      | In-memory metric sample store                              |
| `MemoryScalingHistoryRepository`    | In-memory history store                                    |
| `SrvConfig` / `loadConfig()`        | Environment-variable-driven configuration                  |
| `Container` / `buildContainer()`   | Manual dependency injection container                      |

---

### 2.5 Technology Standards (Tv1) — Technology

| Category           | Technology / Standard                                |
|--------------------|------------------------------------------------------|
| Language           | D (dlang), LDC 1.40.1                               |
| Web Framework      | vibe.d 0.10.x / vibe-http 1.4.x                    |
| Build System       | DUB                                                  |
| Container Image    | OCI (Docker/Podman), Ubuntu 24.04 runtime           |
| Container Registry | Docker Hub / custom registry                        |
| Orchestration      | Kubernetes (K8s), with ConfigMap/Deployment/Service |
| API Style          | REST over HTTP/1.1, JSON payloads                   |
| Authentication     | Tenant-header pattern (X-Tenant-Id)                 |
| Health Standard    | Kubernetes liveness/readiness probes                |
| Port               | 8097                                                 |

---

### 2.6 Architecture Decisions (AD)

| ID   | Decision                                             | Rationale                                                              |
|------|------------------------------------------------------|------------------------------------------------------------------------|
| AD-1 | Hexagonal (Ports & Adapters) architecture            | Decouples business logic from transport and persistence                |
| AD-2 | In-memory repositories as initial persistence       | Enables fast startup, testing, and container portability              |
| AD-3 | Pure domain service (`ScalingEvaluatorService`)      | Keeps scaling logic testable without framework dependencies            |
| AD-4 | Manual DI via `Container` struct                     | Zero reflection overhead, explicit wiring, aligned with D idioms       |
| AD-5 | Port 8097 (service-specific)                        | Consistent port allocation across the UIM platform namespace           |
| AD-6 | Multi-stage Dockerfile/Containerfile                | Minimal runtime image; works with both Docker and Podman (OCI)        |
| AD-7 | Percentage adjustments in scaling rules             | Mirrors SAP BTP Autoscaler `+100%` / `-50%` syntax                    |
| AD-8 | Scaling history immutable once written              | Guarantees audit trail integrity                                       |

---

### 2.7 Deployment View (D1) — Deployment on Kubernetes

```
Kubernetes Cluster
│
├── Namespace: uim-platform
│   │
│   ├── ConfigMap: application-autoscaler-config
│   │   APPLICATION_AUTOSCALER_HOST: "0.0.0.0"
│   │   APPLICATION_AUTOSCALER_PORT: "8097"
│   │
│   ├── Deployment: application-autoscaler
│   │   replicas: 1
│   │   image: uim-platform/application-autoscaler:latest
│   │   ports: 8097
│   │   resources: { req: 64Mi/100m, limit: 256Mi/500m }
│   │   livenessProbe:  GET /api/v1/health :8097
│   │   readinessProbe: GET /api/v1/health :8097
│   │   securityContext: runAsNonRoot, readOnlyRootFilesystem
│   │
│   └── Service: application-autoscaler (ClusterIP :8097)
```
