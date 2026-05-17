# NAF v4 Architecture Description — Service Manager Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Service Manager Service — service catalogue, broker federation, instance
> provisioning, service bindings, platform registration, and long-running
> operations modelled on SAP Service Manager.

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
Service Manager
├── C1.1  Service Catalogue
│   ├── C1.1.1  Service offering and plan registry
│   └── C1.1.2  Service broker federation
│
├── C1.2  Instance Provisioning
│   ├── C1.2.1  Create and update service instances
│   └── C1.2.2  Long-running operation tracking
│
├── C1.3  Service Bindings
│   └── C1.3.1  Bind and unbind credentials
│
├── C1.4  Platform Management
│   └── C1.4.1  Register platforms with environments
│
└── C1.5  Cross-Cutting
    ├── C1.5.1  Label-based filtering
    └── C1.5.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide service catalogue and provisioning modelled on SAP Service Manager. |
| **Vision** | Give every BTP environment a central broker-agnostic service manager that tracks all service instances and bindings. |
| **Scope** | Service offerings, plans, brokers, instances, bindings, platforms, operations, and labels. |
| **Stakeholders** | Platform Operators, Application Developers, Environment Managers. |

---

## 3. Service View (NSV)

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-SO-LIST | Service Offering | `/v1/service-offerings` | GET |
| SVC-SP-LIST | Service Plan | `/v1/service-plans` | GET |
| SVC-SB-CRUD | Service Broker | `/v1/service-brokers` | GET, POST, PUT, DELETE |
| SVC-SI-CRUD | Service Instance | `/v1/service-instances` | GET, POST, PATCH, DELETE |
| SVC-BIND-CRUD | Service Binding | `/v1/service-bindings` | GET, POST, DELETE |
| SVC-PLAT-CRUD | Platform | `/v1/platforms` | GET, POST, DELETE |
| SVC-OP-LIST | Operation | `/v1/operations` | GET |
| SVC-HLTH | Health Check | `/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Platform Operator /│ ─────────────────> │  Service Manager             │
│  Application Dev    │                    │  port 8113                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `ServiceBroker` | Registered OSB-compliant broker |
| `ServiceOffering` | Service advertised by a ServiceBroker |
| `ServicePlan` | Plan variant of a ServiceOffering |
| `ServiceInstance` | Provisioned instance of a ServicePlan |
| `ServiceBinding` | Credential binding to a ServiceInstance |
| `Platform` | Registered environment platform |
| `Operation` | Long-running provisioning/deprovisioning |
| `Label` | Key-value metadata on any entity |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: service-manager-config
│   SERVICE_MANAGER_HOST: "0.0.0.0"
│   SERVICE_MANAGER_PORT: "8113"
├── Deployment: service-manager  port: 8113
└── Service: service-manager (ClusterIP :8113)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | OSB API alignment | Open Service Broker standard compatibility |
| AD-2 | Long-running operations | Supports async provisioning |
| AD-3 | Label-based filtering | Flexible multi-environment queries |
| AD-4 | In-memory repositories | Fast testing |
| AD-5 | Port 8113 | Consistent UIM platform port allocation |
