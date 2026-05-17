# NAF v4 Architecture Description — Process Automation Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Process Automation Service — business process modelling, human task management,
> decision automation, RPA orchestration, and process visibility.

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
Process Automation
├── C1.1  Process Modelling
│   ├── C1.1.1  BPMN process design and versioning
│   └── C1.1.2  Form and decision embedding
│
├── C1.2  Process Execution
│   ├── C1.2.1  Process instance lifecycle
│   └── C1.2.2  Trigger-based process initiation
│
├── C1.3  Human Tasks
│   ├── C1.3.1  Task assignment and deadline management
│   └── C1.3.2  Task form rendering
│
├── C1.4  Decisions
│   └── C1.4.1  DMN-style decision rule evaluation
│
├── C1.5  Actions
│   └── C1.5.1  External system integration actions
│
├── C1.6  Automations (RPA)
│   └── C1.6.1  Robot task scheduling and lifecycle
│
├── C1.7  Artifacts
│   └── C1.7.1  Reusable process artefact catalogue
│
├── C1.8  Visibility
│   └── C1.8.1  Process instance tracking and dashboard
│
└── C1.9  Cross-Cutting
    ├── C1.9.1  Tenant isolation
    └── C1.9.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide process automation modelled on SAP Process Automation (formerly SAP Workflow Management + SAP RPA). |
| **Vision** | Enable business users and developers to automate end-to-end processes combining forms, decisions, human tasks, and robotic automation without deep coding. |
| **Scope** | Process lifecycle, instance execution, human tasks, decisions, actions, automations, artefacts, and visibility. |
| **Stakeholders** | Business Analysts, Process Designers, IT Operations. |

---

## 3. Service View (NSV)

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-PROC-CRUD | Process | `/api/v1/processes` | GET, POST, PUT, DELETE |
| SVC-PI-CRUD | Process Instance | `/api/v1/process-instances` | GET, POST, DELETE |
| SVC-TSK-CRUD | Task | `/api/v1/tasks` | GET, PUT, DELETE |
| SVC-TSK-COMP | Complete Task | `/api/v1/tasks/{id}/complete` | POST |
| SVC-FORM-CRUD | Form | `/api/v1/forms` | GET, POST, DELETE |
| SVC-DEC-CRUD | Decision | `/api/v1/decisions` | GET, POST, DELETE |
| SVC-ACT-CRUD | Action | `/api/v1/actions` | GET, POST, DELETE |
| SVC-ART-CRUD | Artifact | `/api/v1/artifacts` | GET, POST, DELETE |
| SVC-TRG-CRUD | Trigger | `/api/v1/triggers` | GET, POST, DELETE |
| SVC-AUTO-CRUD | Automation | `/api/v1/automations` | GET, POST, DELETE |
| SVC-VIS-LIST | Visibility | `/api/v1/visibility` | GET |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Business User /    │ ─────────────────> │  Process Automation Service  │
│  Process Designer   │                    │  port 8099                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `Process` | Root definition; parent of ProcessInstances, Forms, Decisions, Triggers |
| `ProcessInstance` | Running execution of a Process; parent of Tasks and Visibility |
| `Task` | Human work item within a ProcessInstance |
| `Form` | JSON-schema-driven UI linked to Process |
| `Decision` | Rule set linked to Process |
| `Action` | Integration call step |
| `Artifact` | Reusable content package |
| `Trigger` | Process initiation source (manual, timer, event) |
| `Automation` | RPA robot linked to Process |
| `Visibility` | Process monitoring data point |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: process-automation-config
│   PROCESS_AUTOMATION_HOST: "0.0.0.0"
│   PROCESS_AUTOMATION_PORT: "8099"
├── Deployment: process-automation  port: 8099
└── Service: process-automation (ClusterIP :8099)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Unified process + RPA model | Mirrors SAP Process Automation combining Workflow + RPA |
| AD-2 | Form JSON schema | Enables no-code form design |
| AD-3 | DMN decision rules | Supports externalised business rule management |
| AD-4 | In-memory repositories | Fast testing; swap for process engine DB in production |
| AD-5 | Port 8099 | Consistent UIM platform port allocation |
