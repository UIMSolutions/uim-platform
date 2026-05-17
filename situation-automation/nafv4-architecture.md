# NAF v4 Architecture Description — Situation Automation Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Situation Automation Service — entity-type based situation detection, automation rule
> evaluation, action execution, and multi-channel notification delivery.

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
Situation Automation
├── C1.1  Entity Modelling
│   └── C1.1.1  Define observable entity types and attributes
│
├── C1.2  Situation Templates
│   ├── C1.2.1  Condition authoring
│   └── C1.2.2  Template versioning
│
├── C1.3  Data Ingestion
│   └── C1.3.1  Entity data context push
│
├── C1.4  Situation Detection
│   ├── C1.4.1  Condition evaluation against live data contexts
│   └── C1.4.2  Situation instance lifecycle (open / resolved)
│
├── C1.5  Automation Rules
│   ├── C1.5.1  Trigger-action rule design
│   └── C1.5.2  Rule activation / deactivation
│
├── C1.6  Actions
│   └── C1.6.1  Action execution and audit
│
├── C1.7  Notifications
│   └── C1.7.1  Multi-channel notification delivery
│
├── C1.8  Dashboards
│   └── C1.8.1  Situation overview dashboards
│
└── C1.9  Cross-Cutting
    ├── C1.9.1  Tenant isolation
    └── C1.9.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide situation awareness and automation modelled on SAP Situation Handling and SAP Intelligent Scenario Lifecycle Management. |
| **Vision** | Allow platform operators to define observable entity types, author detection templates, and automatically respond to detected business situations with rules-driven actions and notifications. |
| **Scope** | Entity type definitions, situation templates, data contexts, situation instance lifecycle, automation rules, actions, notifications, and dashboards. |
| **Stakeholders** | Business Analysts, Operations Teams, Application Developers. |

---

## 3. Service View (NSV)

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-ET-CRUD | Entity Type | `/api/v1/entity-types` | GET, POST, DELETE |
| SVC-ST-CRUD | Situation Template | `/api/v1/situation-templates` | GET, POST, DELETE |
| SVC-AR-CRUD | Automation Rule | `/api/v1/automation-rules` | GET, POST, PUT, DELETE |
| SVC-DC-INGEST | Data Context | `/api/v1/data-contexts` | GET, POST |
| SVC-SI-LIST | Situation Instance | `/api/v1/situation-instances` | GET |
| SVC-SA-LIST | Situation Action | `/api/v1/situation-actions` | GET |
| SVC-NOT-LIST | Notification | `/api/v1/notifications` | GET |
| SVC-DASH-CRUD | Dashboard | `/api/v1/dashboards` | GET, POST, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Business System /  │ ─────────────────> │  Situation Automation Service │
│  Operator / Agent   │                    │  port 8100                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `EntityType` | Root observable model; parent of SituationTemplates and DataContexts |
| `SituationTemplate` | Condition pattern for detecting situations; parent of SituationInstances |
| `AutomationRule` | Trigger-action rule linked to SituationTemplate |
| `DataContext` | Live entity data feed triggering evaluation |
| `SituationInstance` | Detected situation with lifecycle (open/resolved) |
| `SituationAction` | Executed action within a SituationInstance |
| `Notification` | Alert delivered to a recipient via a channel |
| `Dashboard` | Aggregated situation view |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: situation-automation-config
│   SITUATION_AUTOMATION_HOST: "0.0.0.0"
│   SITUATION_AUTOMATION_PORT: "8100"
├── Deployment: situation-automation  port: 8100
└── Service: situation-automation (ClusterIP :8100)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Entity-type model | Matches SAP Situation Handling observable entity concept |
| AD-2 | Template-based detection | Enables reuse across similar situation patterns |
| AD-3 | Rules engine separation | Decouples detection logic from execution |
| AD-4 | In-memory repositories | Fast testing; swap for stream processing in production |
| AD-5 | Port 8100 | Consistent UIM platform port allocation |
