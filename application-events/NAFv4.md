# NAFv4 Architecture Description — SAP Cloud Application Event Hub Service

## 1. Architecture Overview (Ar3 — Architecture Overview)

This service is a microservice adapter for **SAP Cloud Application Event Hub** capabilities within the UIM Platform. It enables event-driven integration by distributing business events between SAP cloud applications in a customer's BTP landscape. The service follows **Clean Architecture** combined with **Hexagonal Architecture** (Ports & Adapters pattern) implemented in D/vibe.d.

## 2. Capability View (Cv2 — Capability Definition)

| Capability | Description |
|---|---|
| Event Subscription Management | Create, enable, disable and filter subscriptions between producer and consumer systems |
| Event Topic Registry | Define and version event topics/types |
| Event Channel Management | Manage transport channels (queue, topic, webhook) |
| Event Publishing and Routing | Publish event messages and route them to consumer channels |
| Filter Management | Apply include/exclude filters to control event delivery |
| Dead-Letter Queue | Track, inspect and replay failed event deliveries |
| Formation Management | Manage SAP BTP landscape formations grouping producer/consumer systems |
| System Registration | Register SAP cloud systems as producers, consumers or both |
| Health Monitoring | Expose service health endpoint for orchestration platforms |

## 3. Operational Node View (NOV-2)

```
[SAP BTP Subaccount]
  └─ [UIM Platform Kubernetes Cluster]
       └─ [application-events Deployment] port 8132
            ├─ REST API  → /api/v1/appevents/*
            ├─ Web UI   → /web/appevents/*
            └─ Health   → /api/v1/health
  └─ [MongoDB (optional)] ← file/memory fallback
```

## 4. System Interface View (SV-1)

| Interface | Protocol | Direction | Description |
|---|---|---|---|
| REST API | HTTP/JSON | Inbound | Subscription, topic, channel, message management |
| Web UI | HTTP/HTML | Inbound | Browser-based management console |
| MongoDB | TCP/BSON | Outbound (optional) | Persistent event storage |
| File System | I/O | Outbound (optional) | JSON file persistence |
| Health Endpoint | HTTP/JSON | Inbound | Kubernetes liveness/readiness |

## 5. Service Policy (SvcV-4)

- Max event payload size: 1 MB (enforced in HTTP controller)
- Multi-tenant data isolation via `TenantId` header (`X-Tenant-ID`)
- Retry limit configurable per subscription (`maxRetries`)
- Dead-letter entries created automatically on delivery failure
- Formation must exist before system registration

## 6. Technology Standards (StdV-1)

| Layer | Technology |
|---|---|
| Language | D (dlang) with LDC compiler |
| HTTP Framework | vibe.d 0.10.x / vibe-http 1.4.0 |
| Persistence | In-memory (default), JSON files, MongoDB |
| Containerization | Docker, Podman (OCI) |
| Orchestration | Kubernetes (k8s manifests included) |
| Build | dub (D package manager) |

## 7. Architecture Decisions

| ADR | Decision |
|---|---|
| ADR-001 | Clean + Hexagonal architecture to decouple domain from infrastructure |
| ADR-002 | Module: `uim.platform.appevents` (shortened from application-events for D compatibility) |
| ADR-003 | Port 8132 (redis=8130, postgres=8131, appevents=8132) |
| ADR-004 | Persistence selected at startup via `APPEVENTS_PERSISTENCE` env var |
| ADR-005 | CloudEvents-compatible message envelope for interoperability |
| ADR-006 | Four presentation layers: HTTP (REST), CLI, Web (HTML), GUI (JSON descriptors) |
