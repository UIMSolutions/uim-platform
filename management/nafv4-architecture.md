# NAF v4 Architecture Description — Account Management Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Account Management Service — global account and subaccount hierarchy, directory
> management, service entitlements, subscriptions, and environment instances.

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
Account Management
├── C1.1  Account Hierarchy
│   ├── C1.1.1  Global account lifecycle
│   ├── C1.1.2  Directory creation and nesting
│   └── C1.1.3  Subaccount provisioning
│
├── C1.2  Subscriptions
│   ├── C1.2.1  Subscribe to BTP applications
│   └── C1.2.2  Subscription state lifecycle
│
├── C1.3  Service Plans
│   └── C1.3.1  Available service plan catalogue
│
├── C1.4  Entitlements
│   ├── C1.4.1  Assign service plan quotas to subaccounts
│   └── C1.4.2  Quota redistribution
│
├── C1.5  Environment Instances
│   └── C1.5.1  Cloud Foundry and Kyma environment lifecycle
│
├── C1.6  Platform Events
│   └── C1.6.1  Account lifecycle event audit log
│
├── C1.7  Labels
│   └── C1.7.1  Key-value labels for resources
│
└── C1.8  Cross-Cutting
    ├── C1.8.1  Tenant isolation
    └── C1.8.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide BTP account management modelled on SAP BTP Accounts Service (Cloud Management APIs). |
| **Vision** | Enable platform administrators to manage the full BTP account hierarchy, govern entitlements, and provision environments programmatically. |
| **Scope** | Global accounts, directories, subaccounts, subscriptions, service plans, entitlements, environment instances, platform events, and labels. |
| **Stakeholders** | Platform Administrators, IT Operations, Finance Controllers. |

---

## 3. Service View (NSV)

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-GA-CRUD | Global Account | `/api/v1/global-accounts` | GET, POST, PUT, DELETE |
| SVC-DIR-CRUD | Directory | `/api/v1/directories` | GET, POST, PUT, DELETE |
| SVC-SA-CRUD | Subaccount | `/api/v1/subaccounts` | GET, POST, PUT, DELETE |
| SVC-SUB-CRUD | Subscription | `/api/v1/subscriptions` | GET, POST, DELETE |
| SVC-SP-LIST | Service Plan | `/api/v1/service-plans` | GET |
| SVC-ENT-CRUD | Entitlement | `/api/v1/entitlements` | GET, POST, PUT, DELETE |
| SVC-ENV-CRUD | Environment Instance | `/api/v1/environment-instances` | GET, POST, DELETE |
| SVC-PE-LIST | Platform Event | `/api/v1/platform-events` | GET |
| SVC-LBL-CRUD | Label | `/api/v1/labels` | GET, POST, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Platform Admin /   │ ─────────────────> │  Account Management Service  │
│  IT Operations      │                    │  port 8098                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `GlobalAccount` | Root; parent of Directories and Subaccounts |
| `Directory` | Organisational unit; self-referential nesting |
| `Subaccount` | Deployment unit; owns Subscriptions, Entitlements, EnvironmentInstances |
| `Subscription` | Application subscription in a Subaccount |
| `ServicePlan` | Catalogue entry; referenced by Entitlements |
| `Entitlement` | Quota assignment linking Subaccount to ServicePlan |
| `EnvironmentInstance` | CF or Kyma runtime in a Subaccount |
| `PlatformEvent` | Lifecycle event for audit |
| `Label` | Polymorphic key-value metadata for any resource |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: management-config
│   MANAGEMENT_HOST: "0.0.0.0"
│   MANAGEMENT_PORT: "8098"
├── Deployment: management  port: 8098
└── Service: management (ClusterIP :8098)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Hierarchical account model | Mirrors SAP BTP global account → directory → subaccount structure |
| AD-2 | Entitlement quota model | Matches SAP BTP entitlement assignment API |
| AD-3 | Platform events audit | Provides immutable account change history |
| AD-4 | In-memory repositories | Fast testing; swap for SAP BTP APIs in production |
| AD-5 | Port 8098 | Consistent UIM platform port allocation |
