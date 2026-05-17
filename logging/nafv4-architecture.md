# NAF v4 Architecture Description — Logging Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Logging Service — centralised log ingestion, distributed trace collection,
> pipeline management, alert rules, dashboards, and retention policies.

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
Logging
├── C1.1  Log Ingestion
│   ├── C1.1.1  Structured log stream ingestion
│   └── C1.1.2  Ingestion token authentication
│
├── C1.2  Log Management
│   ├── C1.2.1  Log stream lifecycle
│   └── C1.2.2  Log entry query and retrieval
│
├── C1.3  Distributed Tracing
│   └── C1.3.1  Span collection and trace correlation
│
├── C1.4  Pipeline Configuration
│   ├── C1.4.1  Log forwarder pipeline setup
│   └── C1.4.2  Source and destination configuration
│
├── C1.5  Alerting
│   ├── C1.5.1  Alert rule definition (query + threshold)
│   └── C1.5.2  Alert firing and notification
│
├── C1.6  Dashboards
│   └── C1.6.1  Panel-based log and metric dashboards
│
├── C1.7  Retention
│   └── C1.7.1  Per-stream retention policies
│
└── C1.8  Cross-Cutting
    ├── C1.8.1  Tenant isolation
    └── C1.8.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide centralised logging modelled on SAP Application Logging Service and Cloud Logging for BTP. |
| **Vision** | Give platform operators full observability through structured log ingestion, distributed tracing, configurable alert rules, and retention governance. |
| **Scope** | Log streams, entries, traces, pipelines, ingestion tokens, alert rules, dashboards, and retention policies. |
| **Stakeholders** | Platform Operators, Application Developers, Security Auditors. |

---

## 3. Service View (NSV)

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-LS-CRUD | Log Stream | `/api/v1/log-streams` | GET, POST, PUT, DELETE |
| SVC-LE-CRUD | Log Entry | `/api/v1/log-entries` | GET, POST |
| SVC-SP-CRUD | Span | `/api/v1/spans` | GET, POST |
| SVC-PL-CRUD | Pipeline | `/api/v1/pipelines` | GET, POST, DELETE |
| SVC-IT-CRUD | Ingestion Token | `/api/v1/ingestion-tokens` | GET, POST, DELETE |
| SVC-AR-CRUD | Alert Rule | `/api/v1/alert-rules` | GET, POST, DELETE |
| SVC-AL-LIST | Alert | `/api/v1/alerts` | GET |
| SVC-NC-CRUD | Notification Channel | `/api/v1/notification-channels` | GET, POST, DELETE |
| SVC-DB-CRUD | Dashboard | `/api/v1/dashboards` | GET, POST, PUT, DELETE |
| SVC-RP-CRUD | Retention Policy | `/api/v1/retention-policies` | GET, POST, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Application /      │ ─────────────────> │  Logging Service             │
│  Platform Operator  │                    │  port 8094                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `LogStream` | Named channel; governed by RetentionPolicy; parent of LogEntries |
| `LogEntry` | Timestamped structured log; correlated by traceId |
| `Span` | Distributed trace segment; correlated to LogEntries via traceId |
| `Pipeline` | Log forwarder config; parent of IngestionTokens |
| `IngestionToken` | Bearer credential for pipeline ingestion |
| `AlertRule` | Query-based threshold rule; fires Alerts |
| `Alert` | Fired event; links to AlertRule |
| `NotificationChannel` | Webhook/email/Slack endpoint for alert delivery |
| `Dashboard` | Panel collection for visualisation |
| `RetentionPolicy` | Governs log retention for a LogStream |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: logging-config
│   LOGGING_HOST: "0.0.0.0"
│   LOGGING_PORT: "8094"
├── Deployment: logging  port: 8094
└── Service: logging (ClusterIP :8094)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Structured log streams | Matches SAP Application Logging Service's structured log concept |
| AD-2 | Ingestion token auth | Secure pipeline authentication pattern |
| AD-3 | Distributed trace spans | Supports OpenTelemetry-style tracing |
| AD-4 | Retention policies | Compliance and cost governance |
| AD-5 | Port 8094 | Consistent UIM platform port allocation |
