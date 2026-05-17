# NAF v4 Architecture Description — Automation Pilot Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Automation Pilot Service — operation automation, command execution, catalog
> management, and scheduled execution modelled on SAP Automation Pilot.

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
Automation Pilot
├── C1.1  Command Management
│   ├── C1.1.1  Build and version automation commands
│   └── C1.1.2  Input parameter schema
│
├── C1.2  Catalog Management
│   └── C1.2.1  Group commands into catalogs
│
├── C1.3  Execution Management
│   ├── C1.3.1  Trigger ad-hoc executions
│   └── C1.3.2  View execution history and logs
│
├── C1.4  Scheduled Execution
│   └── C1.4.1  Cron-based scheduled triggers
│
├── C1.5  Trigger Management
│   └── C1.5.1  Event-driven and API triggers
│
├── C1.6  Content Connectors
│   └── C1.6.1  Pre-built SAP system connectors
│
└── C1.7  Cross-Cutting
    ├── C1.7.1  Tenant isolation
    └── C1.7.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide operation automation modelled on SAP Automation Pilot. |
| **Vision** | Eliminate manual runbook execution by encapsulating complex operational procedures in versioned commands with scheduled and event-driven execution. |
| **Scope** | Commands, catalogs, executions, scheduled executions, triggers, service accounts, and content connectors. |
| **Stakeholders** | Platform Operators, DevOps Engineers, SAP BASIS Admins. |

---

## 3. Service View (NSV)

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-CMD-CRUD | Command | `/api/v1/commands` | GET, POST, PUT, DELETE |
| SVC-CAT-CRUD | Catalog | `/api/v1/catalogs` | GET, POST, DELETE |
| SVC-EXEC-CRUD | Execution | `/api/v1/executions` | GET, POST |
| SVC-SCHED-CRUD | Scheduled Execution | `/api/v1/scheduled-executions` | GET, POST, DELETE |
| SVC-TRG-CRUD | Trigger | `/api/v1/triggers` | GET, POST, DELETE |
| SVC-SA-CRUD | Service Account | `/api/v1/service-accounts` | GET, POST, DELETE |
| SVC-CC-CRUD | Content Connector | `/api/v1/content-connectors` | GET, POST |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Operator /         │ ─────────────────> │  Automation Pilot Service    │
│  Scheduler          │                    │  port 8110                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `Command` | Automation step with input parameters |
| `CommandInput` | Named input parameter of a Command |
| `Catalog` | Logical grouping of Commands |
| `Execution` | Runtime instance of a Command |
| `ScheduledExecution` | Cron-triggered Execution |
| `Trigger` | Event-based initiator |
| `ServiceAccount` | Execution identity |
| `ContentConnector` | Pre-built integration to SAP systems |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: automation-pilot-config
│   AUTOMATION_PILOT_HOST: "0.0.0.0"
│   AUTOMATION_PILOT_PORT: "8110"
├── Deployment: automation-pilot  port: 8110
└── Service: automation-pilot (ClusterIP :8110)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Command-centric model | Mirrors SAP Automation Pilot command concept |
| AD-2 | Catalog grouping | Enables library-style reuse |
| AD-3 | Content connectors | Pre-built SAP integration |
| AD-4 | In-memory repositories | Fast testing |
| AD-5 | Port 8110 | Consistent UIM platform port allocation |
