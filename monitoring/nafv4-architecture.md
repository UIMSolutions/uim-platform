# NAF v4 Architecture Description — Monitoring Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Monitoring Service — resource health monitoring, metric ingestion, alert rules,
> health checks, and notification channel management.

---

## 1. NAF v4 Grid Mapping

| NAF View | Viewpoint | Covered Below |
|---|---|---|
| **NCV** – NATO Capability View | C1 Capability Taxonomy, C2 Enterprise Vision | §2 |
| **NSV** – NATO Service View | NSOV-1 Service Taxonomy, NSOV-2 Service Definitions | §3 |
| **NOV** – NATO Operational View | NOV-2 Operational Node Connectivity | §4 |
| **NLV** – NATO Logical View | NLV-1 Logical Data Model | §5 |
| **NPV** – NATO Physical View | NPV-1 Physical Deployment | §6 |
| **NIV** – NATO Information View | NIV-1 Information Structure | §7 |

---

## 2. Capability View (NCV)

### C1 – Capability Taxonomy

```
Monitoring
├── C1.1  Resource Discovery
│   └── C1.1.1  Register and classify monitored resources
│
├── C1.2  Metric Management
│   ├── C1.2.1  Define metric types and units
│   └── C1.2.2  Ingest time-series metric values
│
├── C1.3  Alerting
│   ├── C1.3.1  Threshold-based alert rules
│   └── C1.3.2  Alert lifecycle (firing / resolved)
│
├── C1.4  Notification
│   └── C1.4.1  Multi-channel alert delivery (webhook / email / Slack)
│
├── C1.5  Health Checks
│   ├── C1.5.1  HTTP and TCP health check configuration
│   └── C1.5.2  Health check result recording
│
└── C1.6  Cross-Cutting
    ├── C1.6.1  Tenant isolation
    └── C1.6.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide platform monitoring modelled on SAP Cloud ALM and BTP Alerting services. |
| **Vision** | Give platform operators complete visibility into BTP resource health with metric ingestion, configurable alert rules, and multi-channel notifications. |
| **Scope** | Monitored resource lifecycle, metric definitions and ingestion, alert rules, health checks, and notification channels. |
| **Stakeholders** | Platform Operators, DevOps Engineers, Application Owners. |

---

## 3. Service View (NSV)

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-RES-CRUD | Monitored Resource | `/api/v1/monitored-resources` | GET, POST, DELETE |
| SVC-MD-CRUD | Metric Definition | `/api/v1/metric-definitions` | GET, POST, DELETE |
| SVC-MET-CRUD | Metric | `/api/v1/metrics` | GET, POST |
| SVC-AR-CRUD | Alert Rule | `/api/v1/alert-rules` | GET, POST, DELETE |
| SVC-AL-LIST | Alert | `/api/v1/alerts` | GET |
| SVC-NC-CRUD | Notification Channel | `/api/v1/notification-channels` | GET, POST, DELETE |
| SVC-HC-CRUD | Health Check | `/api/v1/health-checks` | GET, POST, DELETE |
| SVC-HCR-LIST | Health Check Result | `/api/v1/health-check-results` | GET |
| SVC-HLTH | Service Health | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Monitoring Agent / │ ─────────────────> │  Monitoring Service          │
│  Platform Operator  │                    │  port 8093                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `MonitoredResource` | Root observable; emits Metrics, has HealthChecks, raises Alerts |
| `MetricDefinition` | Typed metric descriptor; parent of Metrics and AlertRules |
| `Metric` | Time-series observation for a MonitoredResource |
| `AlertRule` | Threshold condition watching a MetricDefinition |
| `Alert` | Fired event; linked to AlertRule and MonitoredResource |
| `NotificationChannel` | Delivery endpoint for alerts |
| `HealthCheck` | Probe configuration for a MonitoredResource |
| `HealthCheckResult` | Individual probe outcome |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: monitoring-config
│   MONITORING_HOST: "0.0.0.0"
│   MONITORING_PORT: "8093"
├── Deployment: monitoring  port: 8093
└── Service: monitoring (ClusterIP :8093)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Resource-centric model | Aligns with SAP Cloud ALM managed object concept |
| AD-2 | Metric definitions catalogue | Enables typed metric governance |
| AD-3 | Alert rule engine | Threshold evaluation with severity classification |
| AD-4 | In-memory repositories | Fast testing; swap for time-series DB in production |
| AD-5 | Port 8093 | Consistent UIM platform port allocation |
