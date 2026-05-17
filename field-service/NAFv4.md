# NAF v4 Architecture Description — Field Service Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Field Service Service — technician scheduling, service call management,
> equipment tracking, skill matching, and smartform-based field workflows
> modelled on SAP Field Service Management.

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
Field Service
├── C1.1  Service Call Management
│   ├── C1.1.1  Create and dispatch service calls
│   └── C1.1.2  Service call lifecycle
│
├── C1.2  Technician Management
│   ├── C1.2.1  Technician profile and skill management
│   └── C1.2.2  Availability tracking
│
├── C1.3  Customer Management
│   └── C1.3.1  Customer and contact management
│
├── C1.4  Equipment Management
│   └── C1.4.1  Equipment registration and tracking
│
├── C1.5  Activity Management
│   └── C1.5.1  Technician activity logging
│
├── C1.6  Assignment Management
│   └── C1.6.1  Match technicians to service calls by skill
│
├── C1.7  Smartforms
│   └── C1.7.1  Digital checklist / inspection form management
│
└── C1.8  Cross-Cutting
    ├── C1.8.1  Tenant isolation
    └── C1.8.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide field service management modelled on SAP Field Service Management. |
| **Vision** | Optimise field operations by matching skilled technicians to service calls, tracking equipment, and digitising field workflows with smartforms. |
| **Scope** | Service calls, technicians, skills, customers, equipment, activities, assignments, and smartforms. |
| **Stakeholders** | Field Operations Managers, Dispatchers, Field Technicians. |

---

## 3. Service View (NSV)

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-SC-CRUD | Service Call | `/api/v1/service-calls` | GET, POST, PUT, DELETE |
| SVC-TECH-CRUD | Technician | `/api/v1/technicians` | GET, POST, PUT, DELETE |
| SVC-SKL-CRUD | Skill | `/api/v1/skills` | GET, POST, DELETE |
| SVC-CUST-CRUD | Customer | `/api/v1/customers` | GET, POST, PUT, DELETE |
| SVC-EQP-CRUD | Equipment | `/api/v1/equipment` | GET, POST, DELETE |
| SVC-ACT-CRUD | Activity | `/api/v1/activities` | GET, POST |
| SVC-ASN-CRUD | Assignment | `/api/v1/assignments` | GET, POST, DELETE |
| SVC-SF-CRUD | Smartform | `/api/v1/smartforms` | GET, POST, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Dispatcher /       │ ─────────────────> │  Field Service Service       │
│  Mobile Technician  │                    │  port 8107                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `ServiceCall` | Root work order; assigned to Technician |
| `Technician` | Field worker with Skills |
| `Skill` | Competency required for ServiceCall |
| `Customer` | Requester of ServiceCall |
| `Equipment` | Asset associated with ServiceCall |
| `Activity` | Time-logged task within a ServiceCall |
| `Assignment` | Links Technician to ServiceCall |
| `Smartform` | Digital inspection / checklist |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: field-service-config
│   FIELD_SERVICE_HOST: "0.0.0.0"
│   FIELD_SERVICE_PORT: "8107"
├── Deployment: field-service  port: 8107
└── Service: field-service (ClusterIP :8107)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Skill-based assignment | Mirrors SAP FSM scheduling engine concept |
| AD-2 | Smartform integration | Digitises paper-based field checklists |
| AD-3 | Activity logging | Enables time-and-material billing |
| AD-4 | In-memory repositories | Fast testing |
| AD-5 | Port 8107 | Consistent UIM platform port allocation |
