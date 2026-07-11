# NAF v4 Architecture Description — Identity Authentication Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Identity Authentication Service — user authentication, application configuration,
> identity provider federation, session management, and adaptive risk policies.

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
Identity Authentication
├── C1.1  IAUser Management
│   ├── C1.1.1  IAUser CRUD and status lifecycle
│   └── C1.1.2  Group membership management
│
├── C1.2  Application Configuration
│   ├── C1.2.1  Register client applications
│   ├── C1.2.2  Redirect URI and branding
│   └── C1.2.3  Application status lifecycle
│
├── C1.3  Identity Provider Federation
│   ├── C1.3.1  Corporate IdP SAML/OIDC configuration
│   └── C1.3.2  IdP metadata management
│
├── C1.4  Authentication Policies
│   ├── C1.4.1  MFA and password policy management
│   ├── C1.4.2  Risk-based authentication rules
│   └── C1.4.3  Session lifetime policies
│
├── C1.5  Session Management
│   └── C1.5.1  Session tracking and termination
│
├── C1.6  Token Issuance
│   ├── C1.6.1  Access and refresh token lifecycle
│   └── C1.6.2  Token revocation
│
└── C1.7  Cross-Cutting
    ├── C1.7.1  Tenant isolation
    └── C1.7.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide identity authentication modelled on SAP Identity Authentication Service (IAS) for BTP. |
| **Vision** | Enable secure, federated, and policy-governed authentication for all BTP applications. |
| **Scope** | IAUser/group lifecycle, application config, IdP federation, policies, sessions, and token issuance. |
| **Stakeholders** | Identity Administrators, Security Officers, Application Owners. |

---

## 3. Service View (NSV)

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-USR-CRUD | IAUser | `/api/v1/users` | GET, POST, PUT, DELETE |
| SVC-GRP-CRUD | Group | `/api/v1/groups` | GET, POST, PUT, DELETE |
| SVC-APP-CRUD | Application | `/api/v1/applications` | GET, POST, PUT, DELETE |
| SVC-IDP-CRUD | IdP Config | `/api/v1/idp-configs` | GET, POST, PUT, DELETE |
| SVC-POL-CRUD | Policy | `/api/v1/policies` | GET, POST, DELETE |
| SVC-RISK-CRUD | Risk Rule | `/api/v1/risk-rules` | GET, POST, DELETE |
| SVC-SESS-LIST | Session | `/api/v1/sessions` | GET, DELETE |
| SVC-TOK-CRUD | Token | `/api/v1/tokens` | GET, POST, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  End IAUser /         │ ─────────────────> │  Identity Authentication     │
│  Application        │                    │  Service — port 8080          │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `IAUser` | Core principal; member of Groups; creates Sessions and Tokens |
| `Group` | Collection of Users |
| `Application` | Registered client; owns IdpConfigs, Policies, RiskRules |
| `IdpConfig` | SAML/OIDC federation metadata linked to Application |
| `Policy` | Authentication / MFA / session policy linked to Application |
| `RiskRule` | Conditional action (step-up / block) linked to Application |
| `Session` | Active user login session |
| `Token` | Issued access/refresh token |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: identity_authentication-config
│   IDENTITY_AUTHENTICATION_HOST: "0.0.0.0"
│   IDENTITY_AUTHENTICATION_PORT: "8080"
├── Deployment: identity_authentication  port: 8080
└── Service: identity_authentication (ClusterIP :8080)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Application-centric policy model | Mirrors SAP IAS per-application configuration |
| AD-2 | Risk rule engine | Supports adaptive authentication as in SAP IAS |
| AD-3 | IdP federation metadata | Enables SAML/OIDC corporate IdP trust |
| AD-4 | In-memory repositories | Fast testing; swap for production IdP store |
| AD-5 | Port 8080 | Standard web/OIDC port |
