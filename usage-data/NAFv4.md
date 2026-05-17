# NAFv4 Architecture — Usage Data Management Service

## 1. Architecture Overview (Ar)

The **Usage Data Management Service** is a BTP-aligned microservice responsible for collecting, aggregating, and exposing platform consumption data across global accounts, subaccounts, services, and environments. It mirrors the capabilities of the **SAP Usage Data Management Service for SAP BTP** (reporting-ga-admin plan).

The service is implemented in **D / vibe.d** using a **Clean + Hexagonal (Ports & Adapters)** architecture, deployed as a container on Docker, Podman, or Kubernetes.

---

## 2. Operational Node View (NOV-2)

```
┌─────────────────────────────────────────────────┐
│  BTP Global Account Consumer                    │
│  (FinOps / Platform Admin / Analytics Tool)     │
└──────────────────────┬──────────────────────────┘
                       │ HTTPS / REST
                       ▼
┌─────────────────────────────────────────────────┐
│  UIM Platform — Kubernetes Cluster              │
│                                                 │
│  ┌───────────────────────────────────────────┐  │
│  │  usage-data Deployment (Pod)              │  │
│  │  uim-usage-data-platform-service :10004   │  │
│  │                                           │  │
│  │  ClusterIP Service → port 10004           │  │
│  └───────────────────────────────────────────┘  │
│                                                 │
│  ConfigMap: uim-usage-data-config               │
│    USAGE_DATA_HOST, USAGE_DATA_PORT             │
└─────────────────────────────────────────────────┘
```

---

## 3. System/Service Context (SV-1)

| Actor | Interaction |
|---|---|
| Platform Admin | Queries monthly/daily usage reports to audit consumption |
| FinOps Tool | Reads monthly cost reports for chargeback calculation |
| Monitoring Service | Polls `/api/v1/health` for liveness |
| Data Ingestion Pipeline | POSTs raw usage records per billing cycle |
| Service Registry | Reads and writes service metric definitions |

---

## 4. Logical Data Model (DIV-1)

```
GlobalAccount ─── 1:N ──► MonthlyUsageReport ─── 1:N ──► MetricUsageItem
             ─── 1:N ──► DailyUsageReport    ─── 1:N ──► MetricUsageItem
             ─── 1:N ──► UsageRecord (raw)

Subaccount   ─── 1:N ──► DailyUsageReport
             ─── 1:N ──► MonthlyCostReport  ─── 1:N ──► CostItem
             ─── 1:N ──► UsageRecord

ServiceMetric  <─────(defines metric structure for)──── MetricUsageItem, CostItem
```

Core value objects:
- `UsageRecordId`, `MonthlyUsageReportId`, `DailyUsageReportId`, `MonthlyCostReportId`, `ServiceMetricId`

Core enumerations:
- `ReportStatus`: `pending` | `processing` | `ready` | `failed` | `archived`
- `Environment`: `cloudFoundry` | `kyma` | `neo` | `other`
- `MetricUnit`: requests | hours | gigabytes | items | users | instances | calls | gigabyteHours | blocks | documents | executions | connections
- `CommercialModel`: `cpea` | `payg` | `subscription` | `free`
- `AccountType`: `globalAccount` | `directory` | `subaccount`

---

## 5. Service Functionality View (SV-4)

### 5.1 Usage Record Ingestion

Raw usage records submitted by services / pipelines per metric occurrence. Stored per global account / subaccount / service / environment / chargeback period.

### 5.2 Monthly Usage Aggregation

Reports aggregated at global account level, broken down by service, plan, metric, subaccount, and environment. Status lifecycle: `pending → processing → ready`.

### 5.3 Daily Subaccount Usage

Granular consumption per subaccount per calendar day. Enables trend analysis and anomaly detection.

### 5.4 Monthly Cost Reports

Cost distribution per subaccount aligned to CPEA / PAYG commercial models. Includes total cost, currency, and per-metric `CostItem` entries.

### 5.5 Service Metric Catalog

Discoverable registry of billable and non-billable metrics per service and plan. Supports commercial model filtering.

---

## 6. Standards and Technical Choices (StdV-1)

| Concern | Choice |
|---|---|
| Language | D (dlang) |
| HTTP Framework | vibe.d 0.10.x / vibe-http 1.4.x |
| Architecture Pattern | Clean + Hexagonal (Ports & Adapters) |
| Persistence (MVP) | In-memory (MemoryXxxRepository) |
| Serialisation | vibe-data Json |
| Container Runtime | Docker / Podman |
| Orchestration | Kubernetes (Deployment + ClusterIP + ConfigMap) |
| Build System | DUB |
| Base Port | 10004 |
| API Style | REST JSON |
| Health Check | GET /api/v1/health |

---

## 7. Deployment View (DIV-2)

```
Dockerfile / Containerfile
  Stage 1 (build):  dlang2/ldc-ubuntu:1.40.1
    dub build --config=default
  Stage 2 (runtime): ubuntu:24.04
    COPY binary → /app/uim-usage-data-platform-service
    USER appuser (non-root)
    EXPOSE 10004
    HEALTHCHECK GET /api/v1/health

Kubernetes manifests (k8s/):
  configmap.yaml   — USAGE_DATA_HOST, USAGE_DATA_PORT
  deployment.yaml  — 1 replica, resource limits, liveness/readiness probes
  service.yaml     — ClusterIP :10004
```

---

## 8. Alignment with SAP BTP Capability

| SAP BTP Feature | Service Equivalent |
|---|---|
| Monthly usage report (ga-admin) | `MonthlyUsageReport` entity + `/reports/monthly` endpoints |
| Subaccount daily usage | `DailyUsageReport` entity + `/reports/daily` endpoints |
| Monthly subaccount costs | `MonthlyCostReport` entity + `/reports/costs` endpoints |
| Service consumption details | `UsageRecord` + `MetricUsageItem` embedded in reports |
| Metric definitions | `ServiceMetric` entity + `/metrics` endpoints |
| CPEA / PAYG model | `CommercialModel` enum on `MonthlyCostReport` and `ServiceMetric` |
