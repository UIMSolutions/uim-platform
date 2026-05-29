# NAFv4 Architecture Description
## Service: Market Rates Management – Bring Your Own Rates (BYOR)

---

## 1. Capability View (Strategic Architecture)

**Capability**: Financial Market Data Management  
**Sub-capability**: Market Rate Ingestion and Distribution  
**Alignment**: SAP BTP – SAP Market Rates Management, Bring Your Own Rates data option

The service provides a self-hosted, container-native implementation of the
SAP BYOR capability, enabling organisations to:

- Upload market rates from licensed third-party data providers
- Store them in a tenant-isolated data store
- Distribute them on demand to SAP S/4HANA systems or other consumers
- Maintain a full business audit trail

---

## 2. Service View (Operational Node Connectivity)

```
┌─────────────────────────────────────────────────────────────────────────┐
│  External Zone                                                           │
│                                                                         │
│  ┌──────────────────┐    ┌──────────────────┐    ┌───────────────────┐ │
│  │  Data Provider   │    │  SAP S/4HANA     │    │  Management UI    │ │
│  │  (e.g. ECB, TR)  │    │  (on-premise or  │    │  (Manage Market   │ │
│  │                  │    │   cloud)         │    │   Rates App)      │ │
│  └────────┬─────────┘    └────────▲─────────┘    └────────┬──────────┘ │
└───────────┼──────────────────────┼──────────────────────┼─────────────┘
            │ POST /upload          │ POST /download        │ GET /rates
            │                      │                        │ CRUD /providers
┌───────────▼──────────────────────┴────────────────────────▼─────────────┐
│  Platform Zone  (Kubernetes / Cloud Foundry)                             │
│                                                                         │
│  ┌──────────────────────────────────────────────────────────────────┐   │
│  │  uim-market-refinitiv-platform-service  (port 8097)                  │   │
│  │                                                                   │   │
│  │  ┌─────────────────────────────────────────────────────────────┐ │   │
│  │  │  HTTP Driving Adapters (Presentation Layer)                  │ │   │
│  │  │  MarketRateController  AuditLogController  HealthController  │ │   │
│  │  └───────────────────────────┬─────────────────────────────────┘ │   │
│  │                              │                                     │   │
│  │  ┌───────────────────────────▼─────────────────────────────────┐ │   │
│  │  │  Application Layer (Use Cases)                               │ │   │
│  │  │  ManageMarketRatesUseCase                                    │ │   │
│  │  │  ManageProvidersUseCase                                      │ │   │
│  │  │  ManageAuditLogsUseCase                                      │ │   │
│  │  └───────────────────────────┬─────────────────────────────────┘ │   │
│  │                              │                                     │   │
│  │  ┌───────────────────────────▼─────────────────────────────────┐ │   │
│  │  │  Domain Layer                                                 │ │   │
│  │  │  MarketRate · Provider · AuditLog                            │ │   │
│  │  │  MarketRateValidator · QuotaService                          │ │   │
│  │  │  Port interfaces (Repository contracts)                      │ │   │
│  │  └───────────────────────────┬─────────────────────────────────┘ │   │
│  │                              │                                     │   │
│  │  ┌───────────────────────────▼─────────────────────────────────┐ │   │
│  │  │  Infrastructure Layer (Driven Adapters)                      │ │   │
│  │  │  MemoryMarketRateRepository                                  │ │   │
│  │  │  MemoryProviderRepository                                    │ │   │
│  │  │  MemoryAuditLogRepository                                    │ │   │
│  │  └─────────────────────────────────────────────────────────────┘ │   │
│  └──────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 3. System View (Logical Data Architecture)

### 3.1 Core Entities

| Entity | Multiplicity | Description |
|--------|-------------|-------------|
| `MarketRate` | 0..* per tenant | A single financial rate record (exchange rate, interest rate, etc.) |
| `Provider` | 0..* per tenant | A registered market data provider (ECB, Thomson Reuters, etc.) |
| `AuditLog` | 0..* per tenant | Immutable business log entry for upload/download/delete operations |

### 3.2 Key Relationships

```
Provider  1──────<  MarketRate
           (providerCode)

Tenant    1──────<  MarketRate
          1──────<  Provider
          1──────<  AuditLog
```

### 3.3 Domain Constraints (Business Rules)

| Rule | Source |
|------|--------|
| `key1 + key2` ≤ 15 characters | SAP MRM BYOR restriction |
| Characters `~` and `:` are reserved | SAP MRM BYOR restriction |
| Max 1,500 records per request | SAP quota |
| Max 300,000 records per global account | SAP quota |
| Max 6,000 upload/download requests per month | SAP quota |
| Date-range requests must be sequential (no concurrency) | SAP restriction |

---

## 4. Technology View

| Concern | Technology |
|---------|-----------|
| Runtime language | D (dlang) |
| HTTP framework | vibe.d 0.10.x / vibe-http 1.4.x |
| Build tool | dub |
| Compiler | LDC 1.40.x |
| Container runtime | Docker / Podman |
| Container image base (build) | `dlang2/ldc-ubuntu:1.40.1` |
| Container image base (runtime) | `ubuntu:24.04` |
| Orchestration | Kubernetes (ClusterIP Service, Deployment, ConfigMap) |
| Persistence (current) | In-memory HashMap (swap with DB adapter behind port interface) |
| Architecture pattern | Hexagonal (Ports & Adapters) + Clean Architecture layers |

---

## 5. Deployment View

### Kubernetes Resources

| Resource | Name | Notes |
|----------|------|-------|
| `Deployment` | `market-refinitiv` | 1 replica; liveness + readiness on `/api/v1/health` |
| `Service` | `market-refinitiv` | ClusterIP, port 8097 |
| `ConfigMap` | `market-refinitiv-config` | `MARKET_RATES_HOST`, `MARKET_RATES_PORT` |

### Container

```
Image : uim-market-refinitiv-platform-service:latest
Port  : 8097 (TCP)
User  : appuser (UID 1000, non-root)
Health: GET /api/v1/health → { "status": "UP" }
```

---

## 6. Security View

| Concern | Implementation |
|---------|---------------|
| Non-root execution | Container runs as UID 1000 |
| Read-only root filesystem | `readOnlyRootFilesystem: true` in pod spec |
| No privilege escalation | `allowPrivilegeEscalation: false` |
| Input validation | Domain validator rejects bad keys, dates, reserved chars |
| Multi-tenancy | All repository operations are scoped to `tenantId` |
| Sensitive fields | No secrets stored; passwords/tokens are not persisted |

---

## 7. Information Exchange (API Surface)

| Endpoint | Method | Direction | Consumer |
|----------|--------|-----------|----------|
| `/api/v1/market_refinitiv/upload` | POST | Inbound | Data provider client |
| `/api/v1/market_refinitiv/download` | POST | Outbound | SAP S/4HANA / consumer |
| `/api/v1/market_refinitiv/rates` | GET | Query | Management UI |
| `/api/v1/market_refinitiv/rates/{id}` | GET/DELETE | Management | Management UI |
| `/api/v1/market_refinitiv/providers` | GET/POST | CRUD | Management UI |
| `/api/v1/market_refinitiv/providers/{id}` | GET/PUT/DELETE | CRUD | Management UI |
| `/api/v1/market_refinitiv/auditlogs` | GET | Query | Business logging |
| `/api/v1/health` | GET | Probe | Kubernetes liveness/readiness |

---

## 8. Compliance & Standards

- **SAP MRM BYOR API compatibility**: 12 market data type codes, key format conventions, payload field names
- **OWASP Top 10**: Input validation on all inbound data; no SQL injection surface (in-memory store); non-root container; no secrets in code
- **12-Factor App**: Config via environment variables; stateless process; single process per container
