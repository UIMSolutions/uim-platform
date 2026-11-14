# NAF v4 Architecture Description — Account Management Service


## Documentation update

This document is maintained alongside the implementation, deployment manifests, and tests for the same package so the service documentation stays aligned with the codebase.

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
│   ├── C1.1.2  AccountDirectory creation and nesting
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

| Service ID | Name | Interface | Operations |
|---|---|---|---|
| SVC-ODATA | Management OData v4 | `/odata/v4/management/` | `$metadata`, query options, CRUD on 8 entity sets, `Overview` singleton, 8 unbound actions |
| SVC-GA | Global Account | `/api/v1/accounts`, OData `GlobalAccounts` | create, read, update, suspend, reactivate, delete |
| SVC-DIR | Directory | `/api/v1/directories`, OData `Directories` | create, read, update, delete |
| SVC-SA | Subaccount | `/api/v1/subaccounts`, OData `Subaccounts` | create, read, update, move, suspend, reactivate, delete |
| SVC-ENT | Entitlement | `/api/v1/entitlements`, OData `Entitlements` | assign, read, change quota, revoke, delete |
| SVC-ENV | Environment Instance | `/api/v1/environments`, OData `Environments` | provision, read, update, deprovision |
| SVC-SUB | Subscription | `/api/v1/subscriptions`, OData `Subscriptions` | subscribe, read, change plan, unsubscribe |
| SVC-SP | Service Plan | `/api/v1/service-plans`, OData `ServicePlans` | create, read, update, delete |
| SVC-LBL | Label | `/api/v1/labels`, OData `Labels` | create, read, update, delete |
| SVC-PE | Platform Event | `/api/v1/events`, OData `Events` | read, query, prune (worker / CLI) |
| SVC-OV | Overview | `/api/v1/overview`, `/rest/v1/overview`, OData `Overview` | tenant and global account KPIs |
| SVC-REST | Typed REST | `/rest/v1/*` | read API for all resources, directory creation |
| SVC-CLI | Command line | `uim-management-cli` | all operations, JSON output, demo seed |
| SVC-GUI | Desktop GUI | `uim-management-gui` (GtkD) | all operations with dialogs |
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
| `AccountDirectory` | Organisational unit; self-referential nesting |
| `Subaccount` | Deployment unit; owns Subscriptions, Entitlements, Environments |
| `Subscription` | Application subscription in a Subaccount |
| `ServicePlan` | Catalogue entry; referenced by Entitlements |
| `Entitlement` | Quota assignment linking Subaccount to ServicePlan |
| `Environment` | CF or Kyma runtime in a Subaccount |
| `EnvironmentEvent` | Lifecycle event for audit |
| `Label` | Polymorphic key-value metadata for any resource |

---

## 6. Physical View (NPV)

### SAP BTP, Cloud Foundry (mta.yaml)

```text
MTA uim-management
├── management-approuter   (approuter.nodejs)   public route, XSUAA login, serves frontend/
│     └── destination management-srv → management-srv (forwardAuthToken)
├── management-srv         (binary_buildpack)   uim-management-platform-service :$PORT
│     └── data/*.json      snapshot storage (ephemeral container disk)
├── management-xsuaa       (xsuaa / application) scopes Viewer, Admin
└── management-config      (user-provided)      runtime overrides via VCAP_SERVICES
```

### Local / workstation

```text
backend/build/uim-management-platform-service   :8098  REST + OData + Fiori (frontendDir)
backend/build/uim-management-cli                       same dataDir
backend/build/uim-management-gui                       same dataDir (GTK 3)
approuter (npm run start:local)                 :5000  → http://localhost:8098
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Hierarchical account model | Mirrors SAP BTP global account → directory → subaccount structure |
| AD-2 | Entitlement quota model | Matches SAP BTP entitlement assignment API |
| AD-3 | Platform events audit | Provides immutable account change history |
| AD-4 | Snapshot persistence (memory / JSON file) behind `ISnapshotStorage` | Shared by server, CLI and GUI without a database; swap the storage adapter for a database in production |
| AD-5 | Port 8098 | Consistent UIM platform port allocation |
| AD-6 | Hexagonal architecture with `ManagementPorts` | All five driving adapters (JSON API, REST, OData, CLI, GUI) use the same use cases and rules |
| AD-7 | Business rules on the entities | Lifecycle transitions and limits live in the domain (`InvalidStateTransition`, `LimitExceeded`) |
| AD-8 | Provisioning behind `IProvisioningGateway` | Simulated client today; CF Cloud Controller / Kyma / SaaS registry clients can be plugged in |
| AD-9 | OData v4 without `$batch` | The UI5 model uses `$direct`; keeps the endpoint small and predictable |
| AD-10 | Approuter as single entry point | XSUAA authentication and CSRF protection; the backend does not verify JWT signatures itself |
