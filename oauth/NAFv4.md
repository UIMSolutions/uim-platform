# NAF v4 Architecture Description — OAuth Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> OAuth Service — OAuth 2.0 client management, access and refresh token lifecycle,
> authorization codes, scope definitions, and branding configuration modelled on
> SAP Authorization and Trust Management Service OAuth flows.

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
OAuth
├── C1.1  Client Management
│   ├── C1.1.1  Register OAuth clients
│   └── C1.1.2  Client secret management
│
├── C1.2  Token Management
│   ├── C1.2.1  Access token issuance and revocation
│   └── C1.2.2  Refresh token management
│
├── C1.3  Authorization Code Flow
│   └── C1.3.1  Authorization code issuance and exchange
│
├── C1.4  Scope Management
│   └── C1.4.1  Define and publish OAuth scopes
│
├── C1.5  Branding
│   └── C1.5.1  Custom consent page branding
│
└── C1.6  Cross-Cutting
    ├── C1.6.1  Tenant isolation
    └── C1.6.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide OAuth 2.0 server capabilities modelled on SAP XSUAA OAuth flows. |
| **Vision** | Enable all UIM Platform services to delegate authentication and authorisation to a central standards-compliant OAuth provider. |
| **Scope** | OAuth clients, access tokens, refresh tokens, authorization codes, scopes, and branding configurations. |
| **Stakeholders** | Platform Architects, Application Developers, Security Administrators. |

---

## 3. Service View (NSV)

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-CLIENT-CRUD | OAuth Client | `/api/v1/oauth-clients` | GET, POST, PUT, DELETE |
| SVC-AT-CRUD | Access Token | `/api/v1/access-tokens` | GET, POST, DELETE |
| SVC-RT-CRUD | Refresh Token | `/api/v1/refresh-tokens` | GET, DELETE |
| SVC-AC-CRUD | Authorization Code | `/api/v1/authorization-codes` | GET, POST |
| SVC-SCOPE-CRUD | OAuth Scope | `/api/v1/oauth-scopes` | GET, POST, DELETE |
| SVC-BRAND-CRUD | Branding Config | `/api/v1/branding-configs` | GET, POST, PUT |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Client Application │ ─────────────────> │  OAuth Service               │
│  / User Agent       │                    │  port 8114                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `OAuthClient` | Registered application with scopes |
| `OAuthScope` | Permission scope definition |
| `AccessToken` | Short-lived bearer token |
| `RefreshToken` | Long-lived token for access token renewal |
| `AuthorizationCode` | One-time code exchanged for tokens |
| `BrandingConfig` | Custom consent page styling |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: oauth-config
│   OAUTH_HOST: "0.0.0.0"
│   OAUTH_PORT: "8114"
├── Deployment: oauth  port: 8114
└── Service: oauth (ClusterIP :8114)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | RFC 6749 compliant model | Standards-based OAuth 2.0 |
| AD-2 | Separate refresh token entity | Enables sliding-window token renewal |
| AD-3 | Branding configuration | Whitelabel consent page support |
| AD-4 | In-memory repositories | Fast testing |
| AD-5 | Port 8114 | Consistent UIM platform port allocation |
