# NAF v4 Architecture Description — Integration Automation Service


## Documentation update

This document is maintained alongside the implementation, deployment manifests, and tests for the same package so the service documentation stays aligned with the codebase.

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Integration Automation Service — integration scenario management, workflow
> orchestration, system connections, destinations, workflow steps, and execution
> log modelled on SAP Integration Automation.

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
Integration Automation
├── C1.1  Scenario Management
│   ├── C1.1.1  Define integration scenarios
│   └── C1.1.2  Activate and deactivate scenarios
│
├── C1.2  Workflow Orchestration
│   ├── C1.2.1  Define and sequence workflow steps
│   └── C1.2.2  Execute and monitor workflows
│
├── C1.3  System Connections
│   └── C1.3.1  Register and test system connections
│
├── C1.4  Destination Management
│   └── C1.4.1  Configure target destinations
│
├── C1.5  Execution Logging
│   └── C1.5.1  Record execution results per scenario
│
└── C1.6  Cross-Cutting
    ├── C1.6.1  Tenant isolation
    └── C1.6.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide integration automation modelled on SAP Integration Automation. |
| **Vision** | Accelerate the activation of SAP integration scenarios by automating the configuration of system connections, destinations, and workflow steps. |
| **Scope** | Integration scenarios, workflows, workflow steps, system connections, destinations, and execution logs. |
| **Stakeholders** | Integration Consultants, Platform Operators, Basis Administrators. |

---

## 3. Service View (NSV)

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-IS-CRUD | Integration Scenario | `/api/v1/integration-scenarios` | GET, POST, PUT, DELETE |
| SVC-WF-CRUD | Workflow | `/api/v1/workflows` | GET, POST, PUT, DELETE |
| SVC-WS-CRUD | Workflow Step | `/api/v1/workflow-steps` | GET, POST, DELETE |
| SVC-SC-CRUD | System Connection | `/api/v1/system-connections` | GET, POST, DELETE |
| SVC-DEST-CRUD | Destination | `/api/v1/destinations` | GET, POST, DELETE |
| SVC-EL-LIST | Execution Log | `/api/v1/execution-logs` | GET |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Integration Cons. /│ ─────────────────> │  Integration Automation      │
│  Platform Operator  │                    │  port 8090                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `IntegrationScenario` | Named integration use case |
| `Workflow` | Ordered set of WorkflowSteps |
| `WorkflowStep` | Individual automation step |
| `SystemConnection` | Source or target system |
| `Destination` | Configured endpoint for a SystemConnection |
| `ExecutionLog` | Result record for a Workflow execution |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: integration-automation-config
│   INTEGRATION_AUTOMATION_HOST: "0.0.0.0"
│   INTEGRATION_AUTOMATION_PORT: "8090"
├── Deployment: integration-automation  port: 8090
└── Service: integration-automation (ClusterIP :8090)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Scenario-first model | Groups related workflows logically |
| AD-2 | Workflow step abstraction | Reusable automation steps |
| AD-3 | Execution log | Full audit trail of automations |
| AD-4 | In-memory repositories | Fast testing |
| AD-5 | Port 8090 | Consistent UIM platform port allocation |
