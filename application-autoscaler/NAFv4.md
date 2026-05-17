# NAF v4 Architecture Description — Application Autoscaler Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Application Autoscaler Service — policy-driven automatic scaling of Cloud Foundry
> applications based on metrics, schedules, and custom thresholds.

---

## 1. NAF v4 Grid Mapping

| NAF View | Viewpoint | Covered Below |
|---|---|---|
| **NCV** | C1 Capability Taxonomy, C2 Enterprise Vision | §2 |
| **NSV** | NSOV-2 Service Definitions | §3 |
| **NOV** | NOV-2 Operational Node Connectivity | §4 |
| **NLV** | NLV-1 Logical Data Model | §5 |
| **NPV** | NPV-1 Physical Deployment | §6 |
| **NIV** | NIV-1 Information Structure | §7 |

---

## 2. Capability View (NCV)

### C1 – Capability Taxonomy

```
Application Autoscaler
├── C1.1  Scaling Policy Management
│   ├── C1.1.1  CPU / memory threshold rules
│   └── C1.1.2  Custom metric rules
│
├── C1.2  Schedule-Based Scaling
│   ├── C1.2.1  Recurring schedules (cron)
│   └── C1.2.2  Specific date/time schedules
│
├── C1.3  App Binding
│   └── C1.3.1  Bind autoscaler to CF application
│
├── C1.4  Scaling History
│   └── C1.4.1  Audit trail of scale-in/out events
│
└── C1.5  Cross-Cutting
    ├── C1.5.1  Tenant isolation
    └── C1.5.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide automatic application scaling modelled on SAP BTP Application Autoscaler. |
| **Vision** | Eliminate manual capacity management by automatically scaling CF applications based on configurable policies and schedules. |
| **Scope** | Scaling policies, schedules, app bindings, custom metrics, and scaling history. |
| **Stakeholders** | Application Developers, Platform Operators, DevOps Engineers. |

---

## 3. Service View (NSV)

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-POL-CRUD | Scaling Policy | `/api/v1/scaling-policies` | GET, POST, PUT, DELETE |
| SVC-REC-CRUD | Recurring Schedule | `/api/v1/recurring-schedules` | GET, POST, DELETE |
| SVC-SDS-CRUD | Specific Date Schedule | `/api/v1/specific-date-schedules` | GET, POST, DELETE |
| SVC-BIND-CRUD | App Binding | `/api/v1/app-bindings` | GET, POST, DELETE |
| SVC-RULE-CRUD | Scaling Rule | `/api/v1/scaling-rules` | GET, POST, DELETE |
| SVC-MET-CRUD | Custom Metric | `/api/v1/custom-metrics` | GET, POST |
| SVC-HIST-LIST | Scaling History | `/api/v1/scaling-history` | GET |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  CF Application /   │ ─────────────────> │  Application Autoscaler      │
│  Platform Operator  │                    │  port 8097                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `ScalingPolicy` | Root; defines min/max instances for an app |
| `RecurringSchedule` | Cron-based schedule linked to ScalingPolicy |
| `SpecificDateSchedule` | One-off schedule linked to ScalingPolicy |
| `AppBinding` | Links ScalingPolicy to a CF application |
| `ScalingRule` | Threshold-based rule within a ScalingPolicy |
| `CustomMetric` | Application-emitted metric for rule evaluation |
| `ScalingHistory` | Audit record of scaling events |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: application-autoscaler-config
│   APPLICATION_AUTOSCALER_HOST: "0.0.0.0"
│   APPLICATION_AUTOSCALER_PORT: "8097"
├── Deployment: application-autoscaler  port: 8097
└── Service: application-autoscaler (ClusterIP :8097)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Policy-centric model | Mirrors SAP Application Autoscaler policy concept |
| AD-2 | App binding separation | Decouples policy definition from binding |
| AD-3 | Custom metrics | Enables application-driven scaling signals |
| AD-4 | In-memory repositories | Fast testing; swap for metrics DB in production |
| AD-5 | Port 8097 | Consistent UIM platform port allocation |
