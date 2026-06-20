# NAF v4 Architecture Description — Identity Directory Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Identity Directory Service — SCIM 2.0-compliant user and group directory,
> schema management, API client administration, password policies, and audit
> events modelled on SAP Identity Directory.

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
Identity Directory
├── C1.1  User Management
│   ├── C1.1.1  Create, read, update, delete users
│   └── C1.1.2  IAMGroup membership management
│
├── C1.2  IAMGroup Management
│   └── C1.2.1  Create and manage groups
│
├── C1.3  Schema Management
│   └── C1.3.1  Custom attribute schema extensions
│
├── C1.4  API Client Management
│   └── C1.4.1  Manage SCIM API clients
│
├── C1.5  Password Policy
│   └── C1.5.1  Enforce password rules
│
├── C1.6  Audit Events
│   └── C1.6.1  Log directory changes
│
└── C1.7  Cross-Cutting
    ├── C1.7.1  Tenant isolation
    └── C1.7.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide identity directory modelled on SAP Identity Directory (SCIM 2.0). |
| **Vision** | Provide a standards-compliant central directory for all BTP users and groups, extensible with custom schemas. |
| **Scope** | Users, groups, schemas, API clients, password policies, and audit events. |
| **Stakeholders** | Identity Administrators, Security Architects, Application Developers. |

---

## 3. Service View (NSV)

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-USER-CRUD | User | `/api/v1/users` | GET, POST, PUT, DELETE |
| SVC-GRP-CRUD | IAMGroup | `/api/v1/groups` | GET, POST, PUT, DELETE |
| SVC-SCH-CRUD | Schema | `/api/v1/schemas` | GET, POST, DELETE |
| SVC-AC-CRUD | API Client | `/api/v1/api-clients` | GET, POST, DELETE |
| SVC-PP-CRUD | Password Policy | `/api/v1/password-policies` | GET, POST, PUT |
| SVC-AE-LIST | Audit Event | `/api/v1/audit-events` | GET |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Identity Admin /   │ ─────────────────> │  Identity Directory Service  │
│  Provisioning App   │                    │  port 8082                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `User` | Directory user with group memberships |
| `IAMGroup` | Collection of Users |
| `Schema` | Custom attribute schema extension |
| `ApiClient` | SCIM API access credential |
| `PasswordPolicy` | Password strength rules |
| `AuditEvent` | Log of directory changes |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: identity-directory-config
│   IDENTITY_DIRECTORY_HOST: "0.0.0.0"
│   IDENTITY_DIRECTORY_PORT: "8082"
├── Deployment: identity-directory  port: 8082
└── Service: identity-directory (ClusterIP :8082)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | SCIM 2.0 alignment | Industry-standard directory protocol |
| AD-2 | Schema extension | Custom attributes without core changes |
| AD-3 | Password policy entity | Centralised policy enforcement |
| AD-4 | In-memory repositories | Fast testing |
| AD-5 | Port 8082 | Consistent UIM platform port allocation |
