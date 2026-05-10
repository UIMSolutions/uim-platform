# NAFv4 — Authorization and Trust Management Service

NATO Architecture Framework v4 — Architectural Viewpoints

---

## 1. Capability View (CV-1) — Capability Overview

| Capability | Description |
|------------|-------------|
| OAuth 2.0 Client Management | Register, update, and delete OAuth 2.0 client applications; manage client secrets, grant types, scopes, and redirect URIs |
| Scope Management | Define and manage fine-grained authorization scopes for applications |
| Role Management | Create role templates that bundle scopes into reusable authorization units |
| Role Collection Management | Aggregate roles into business-level role collections for large-scale authorization scenarios |
| User Authorization | Assign role collections to users and user groups; query effective authorizations for a user |
| Trust Management | Register and manage trusted identity providers (SAML 2.0 / OIDC); configure SSO metadata |
| Token Issuance | Issue OAuth 2.0 JWT access tokens via client credentials and authorization code flows |
| Token Validation | Validate JWT tokens against registered clients and active scopes |
| Health Monitoring | Expose `/api/v1/health` for liveness and readiness probes |

---

## 2. Architecture Viewpoints

### 2.1 Logical Architecture View

The service is structured using **Hexagonal (Ports & Adapters) Architecture** combined with **Clean Architecture** layering:

```
┌────────────────────────────────────────────────────────────────────┐
│  Driving Adapters (Presentation)                                   │
│  HTTP REST Controllers (vibe.d URLRouter)                          │
│    OAuthClientController  ScopeController  RoleController          │
│    RoleCollectionController  UserAssignmentController              │
│    IdentityProviderController  TokenController  HealthController   │
└──────────────────────────┬─────────────────────────────────────────┘
                           │ calls use cases
┌──────────────────────────▼─────────────────────────────────────────┐
│  Application Layer                                                 │
│  Use Cases:                                                        │
│    ManageOAuthClientsUseCase    ManageScopesUseCase                │
│    ManageRolesUseCase           ManageRoleCollectionsUseCase       │
│    ManageUserAssignmentsUseCase ManageIdentityProvidersUseCase     │
│  DTOs: CreateOAuthClientRequest, CreateScopeRequest,              │
│        CreateRoleRequest, CreateRoleCollectionRequest,            │
│        CreateUserAssignmentRequest, CreateIdentityProviderRequest, │
│        IssueTokenRequest, CommandResult                           │
└──────────────────────────┬─────────────────────────────────────────┘
                           │ uses domain ports
┌──────────────────────────▼─────────────────────────────────────────┐
│  Domain Layer                                                      │
│  Entities: OAuthClientEntity, ScopeEntity, RoleEntity,            │
│            RoleCollectionEntity, UserAssignmentEntity,            │
│            IdentityProviderEntity                                  │
│  Value Types / Enums: GrantType, ClientType, IdpType              │
│  Repository Interfaces (Ports):                                   │
│    OAuthClientRepository, ScopeRepository, RoleRepository,        │
│    RoleCollectionRepository, UserAssignmentRepository,            │
│    IdentityProviderRepository                                      │
│  Domain Service: TokenService                                      │
└──────────────────────────┬─────────────────────────────────────────┘
                           │ implements ports
┌──────────────────────────▼─────────────────────────────────────────┐
│  Driven Adapters (Infrastructure)                                  │
│  In-Memory Repositories:                                           │
│    MemoryOAuthClientRepository  MemoryScopeRepository             │
│    MemoryRoleRepository         MemoryRoleCollectionRepository    │
│    MemoryUserAssignmentRepository  MemoryIdentityProviderRepository│
│  Config: SrvConfig (env-var based, port 8116)                     │
│  DI Container: buildContainer(SrvConfig)                          │
└────────────────────────────────────────────────────────────────────┘
```

**Dependency Rule**: dependencies point strictly inward (presentation → application → domain ← infrastructure).

---

### 2.2 System Context View (AV-2)

```
┌─────────────┐      REST / HTTP          ┌──────────────────────────────┐
│  Client App │ ───────────────────────►  │  Authorization & Trust Mgmt  │
│  (consumer) │                           │  Service  :8116              │
└─────────────┘                           └────────────┬─────────────────┘
                                                        │ in-memory store
┌─────────────┐      SAML / OIDC Metadata│      ┌───────▼──────────┐
│  Identity   │ ───────────────────────► │      │  MemoryRepos     │
│  Provider   │                           │      │  (volatile)      │
└─────────────┘                           │      └──────────────────┘
                                          │
                External Orchestrators:
                ┌──────────────┐    ┌─────────────────┐
                │  Docker /    │    │  Kubernetes      │
                │  Podman      │    │  (k8s manifests) │
                └──────────────┘    └─────────────────┘
```

---

### 2.3 Information View (DIV-1)

| Entity | Key Attributes | Relationships |
|--------|---------------|---------------|
| OAuthClientEntity | id, clientId, clientSecret, grantTypes, scopes, redirectUris, clientType, appId | has many scopes |
| ScopeEntity | id, name, description, appId | referenced by RoleEntity |
| RoleEntity | id, name, description, scopeReferences, appId | referenced by RoleCollectionEntity |
| RoleCollectionEntity | id, name, description, roleReferences | assigned to UserAssignmentEntity |
| UserAssignmentEntity | id, userId, userEmail, roleCollectionId, origin | links user to RoleCollectionEntity |
| IdentityProviderEntity | id, alias, displayName, idpType, metadataUrl, entityId, ssoUrl, sloUrl, signingCert, isActive, isDefault | standalone trust configuration |

---

### 2.4 Service View (SvcV-1) — REST API Surface

| Service | Endpoint | HTTP Method | Description |
|---------|----------|-------------|-------------|
| OAuth Client | `/api/v1/oauth/clients` | POST | Register OAuth 2.0 client |
| OAuth Client | `/api/v1/oauth/clients` | GET | List clients |
| OAuth Client | `/api/v1/oauth/clients/*` | GET | Get client by ID |
| OAuth Client | `/api/v1/oauth/clients/*` | PUT | Update client |
| OAuth Client | `/api/v1/oauth/clients/*` | DELETE | Delete client |
| Scope | `/api/v1/scopes` | POST | Create scope |
| Scope | `/api/v1/scopes` | GET | List scopes |
| Scope | `/api/v1/scopes/*` | GET / PUT / DELETE | Manage scope |
| Role | `/api/v1/roles` | POST | Create role |
| Role | `/api/v1/roles` | GET | List roles |
| Role | `/api/v1/roles/*` | GET / PUT / DELETE | Manage role |
| Role Collection | `/api/v1/role-collections` | POST | Create role collection |
| Role Collection | `/api/v1/role-collections` | GET | List role collections |
| Role Collection | `/api/v1/role-collections/*` | GET / PUT / DELETE | Manage role collection |
| User Assignment | `/api/v1/user-assignments` | POST | Assign role collection to user |
| User Assignment | `/api/v1/user-assignments` | GET | List assignments |
| User Assignment | `/api/v1/user-assignments/*` | GET / DELETE | Manage assignment |
| Identity Provider | `/api/v1/identity-providers` | POST | Register IdP |
| Identity Provider | `/api/v1/identity-providers` | GET | List IdPs |
| Identity Provider | `/api/v1/identity-providers/*` | GET / PUT / DELETE | Manage IdP |
| Token | `/api/v1/oauth/token` | POST | Issue OAuth 2.0 token |
| Health | `/api/v1/health` | GET | Liveness / readiness |

---

### 2.5 Operational View (OV-1) — Deployment

```
┌─────────────────────────────────────────────────────────────────────┐
│  Kubernetes Cluster                                                 │
│                                                                     │
│  ┌───────────────────────────────────────────────────────────────┐ │
│  │  Deployment: authorization-trust  (1 replica)                 │ │
│  │  ┌──────────────────────────────────────────────────────────┐ │ │
│  │  │  Container: uim-authorization-trust-platform-service     │ │ │
│  │  │  Image: uim-platform/authorization-trust:latest          │ │ │
│  │  │  Port: 8116                                              │ │ │
│  │  │  Resources: req 64Mi/100m, limit 256Mi/500m              │ │ │
│  │  │  Probes: GET /api/v1/health (liveness + readiness)       │ │ │
│  │  │  Security: runAsNonRoot=true, readOnlyRootFilesystem=true │ │ │
│  │  └──────────────────────────────────────────────────────────┘ │ │
│  └───────────────────────────────────────────────────────────────┘ │
│                                                                     │
│  ConfigMap: authorization-trust-config                             │
│  Service:   authorization-trust (ClusterIP :8116)                 │
└─────────────────────────────────────────────────────────────────────┘
```

---

### 2.6 Standards View (StdV-1)

| Standard | Application |
|----------|-------------|
| OAuth 2.0 (RFC 6749) | Token issuance: client credentials, authorization code |
| JWT (RFC 7519) | Access token format |
| SAML 2.0 | Identity provider trust / federation |
| OpenID Connect 1.0 | OIDC identity provider integration |
| REST / HTTP 1.1 | API transport |
| Apache 2.0 | Software license |
| Docker / OCI Image Spec | Container packaging |
| Kubernetes API | Orchestration manifests |

---

## 3. Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Language | D (dlang) | Type-safe, compiled, memory-efficient |
| HTTP Framework | vibe.d 0.10.x | Async I/O, production-grade, integrates with dub |
| Architecture | Hexagonal + Clean | Testability, replaceability of adapters |
| Persistence | In-memory (initial) | Portable, zero external dependencies; replace with DB adapter later |
| Token format | JWT (simplified) | Stateless, industry standard |
| DI | Manual container | Transparent wiring, no reflection |
| Container | Docker / Podman (multi-stage) | Small runtime image, security hardened |
| Orchestration | Kubernetes | Cloud-native horizontal scaling |
