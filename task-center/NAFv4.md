# NAF v4 Architecture Description — Task Center Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Task Center Service — unified inbox for human tasks aggregated from SAP and
> third-party providers, including task definitions, actions, comments,
> attachments, filters, and substitution rules modelled on SAP Task Center.

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
Task Center
├── C1.1  Task Aggregation
│   ├── C1.1.1  Pull tasks from multiple task providers
│   └── C1.1.2  Task definition registry
│
├── C1.2  Task Execution
│   ├── C1.2.1  Claim, approve, reject tasks
│   └── C1.2.2  Custom task actions
│
├── C1.3  Task Collaboration
│   ├── C1.3.1  Task comments
│   └── C1.3.2  Task attachments
│
├── C1.4  Task Organisation
│   └── C1.4.1  User-defined task filters
│
├── C1.5  Substitution
│   └── C1.5.1  User absence and substitution rules
│
└── C1.6  Cross-Cutting
    ├── C1.6.1  Tenant isolation
    └── C1.6.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide a unified task inbox modelled on SAP Task Center. |
| **Vision** | Eliminate task silos by aggregating human tasks from SAP S/4HANA, Ariba, SuccessFactors, and custom applications into a single multi-source inbox. |
| **Scope** | Tasks, task definitions, providers, actions, comments, attachments, filters, and substitution rules. |
| **Stakeholders** | End Users, Line Managers, IT Administrators. |

---

## 3. Service View (NSV)

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-TASK-CRUD | Task | `/api/v1/tasks` | GET, POST, PUT, DELETE |
| SVC-TD-CRUD | Task Definition | `/api/v1/task-definitions` | GET, POST, DELETE |
| SVC-TP-CRUD | Task Provider | `/api/v1/task-providers` | GET, POST, DELETE |
| SVC-TA-CRUD | Task Action | `/api/v1/task-actions` | GET, POST |
| SVC-TC-CRUD | Task Comment | `/api/v1/task-comments` | GET, POST, DELETE |
| SVC-TATT-CRUD | Task Attachment | `/api/v1/task-attachments` | GET, POST, DELETE |
| SVC-TF-CRUD | User Task Filter | `/api/v1/user-task-filters` | GET, POST, DELETE |
| SVC-SUB-CRUD | Substitution Rule | `/api/v1/substitution-rules` | GET, POST, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌──────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  End User /           │ ─────────────────> │  Task Center Service         │
│  Workflow System      │                    │  port 8103                    │
└──────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `Task` | Human task from a TaskProvider |
| `TaskDefinition` | Template defining a task type |
| `TaskProvider` | Source system registering tasks |
| `TaskAction` | Executable action on a Task |
| `TaskComment` | User comment on a Task |
| `TaskAttachment` | File attached to a Task |
| `UserTaskFilter` | Saved filter for task inbox views |
| `SubstitutionRule` | Delegation of tasks during absence |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: task-center-config
│   TASK_CENTER_HOST: "0.0.0.0"
│   TASK_CENTER_PORT: "8103"
├── Deployment: task-center  port: 8103
└── Service: task-center (ClusterIP :8103)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Multi-provider model | Aggregates tasks from any system |
| AD-2 | Substitution rules | Compliance with absence workflows |
| AD-3 | Task filters | Personalised inbox management |
| AD-4 | In-memory repositories | Fast testing |
| AD-5 | Port 8103 | Consistent UIM platform port allocation |
