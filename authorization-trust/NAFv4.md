# NAF v4 Architecture Description — Authorization and Trust Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Authorization and Trust Management Service — OAuth clients, identity providers,
> scopes, roles, role collections, and user assignments modelled on SAP Authorization
> and Trust Management Service (XSUAA).

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
Authorization and Trust
├── C1.1  OAuth Client Management
│   ├── C1.1.1  Register OAuth clients
│   └── C1.1.2  Client secret rotation
│
├── C1.2  Identity Provider Management
│   └── C1.2.1  SAML / OIDC IdP configuration
│
├── C1.3  Scope Management
│   └── C1.3.1  Define and publish authorization scopes
│
├── C1.4  Role Management
│   ├── C1.4.1  Role creation with scope assignments
│   └── C1.4.2  Role collection aggregation
│
├── C1.5  User Assignments
│   └── C1.5.1  Assign role collections to users
│
└── C1.6  Cross-Cutting
    ├── C1.6.1  Tenant isolation
    └── C1.6.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide authorization and trust management modelled on SAP XSUAA. |
| **Vision** | Centralise OAuth 2.0 client registration, identity provider trust, and fine-grained RBAC across all BTP services. |
| **Scope** | OAuth clients, IdP configurations, scopes, roles, role collections, and user assignments. |
| **Stakeholders** | Security Architects, Platform Admins, Application Developers. |

---

## 3. Service View (NSV)

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-IDP-CRUD | Identity Provider | `/api/v1/identity-providers` | GET, POST, DELETE |
| SVC-SCOPE-CRUD | Scope | `/api/v1/scopes` | GET, POST, DELETE |
| SVC-ROLE-CRUD | Role | `/api/v1/roles` | GET, POST, DELETE |
| SVC-RC-CRUD | Role Collection | `/api/v1/role-collections` | GET, POST, DELETE |
| SVC-OA-CRUD | OAuth Client | `/api/v1/oauth-clients` | GET, POST, DELETE |
| SVC-UA-CRUD | User Assignment | `/api/v1/user-assignments` | GET, POST, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Platform Admin /   │ ─────────────────> │  Authorization Trust Service │
│  Application        │                    │  port 8116                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `IdentityProvider` | External IdP trust configuration |
| `OAuthClient` | Application OAuth 2.0 client |
| `ScopeEntity` | Authorization scope definition |
| `RoleEntity` | Role aggregating scopes |
| `RoleCollection` | Role collection aggregating roles |
| `UserAssignment` | Links user to RoleCollection |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: authorization-trust-config
│   AUTHORIZATION_TRUST_HOST: "0.0.0.0"
│   AUTHORIZATION_TRUST_PORT: "8116"
├── Deployment: authorization-trust  port: 8116
└── Service: authorization-trust (ClusterIP :8116)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | XSUAA-aligned model | Mirrors SAP platform authorization service |
| AD-2 | Scope → Role → RoleCollection hierarchy | Fine-grained RBAC |
| AD-3 | IdP federation support | Enables corporate SSO |
| AD-4 | In-memory repositories | Fast testing |
| AD-5 | Port 8116 | Consistent UIM platform port allocation |
