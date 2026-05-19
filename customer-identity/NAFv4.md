# Customer Identity Service — NAFv4 Architecture Views

## NOV-1: High-Level Operational Concept

The Customer Identity Service (CIAM B2C) provides identity lifecycle management for Business-to-Consumer scenarios within the UIM Platform. It manages customer registration, authentication, social login federation, consent, audit, and policy enforcement.

```
┌─────────────────────────────────────────────────────────────┐
│                     UIM Platform                            │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           Customer Identity Service                  │   │
│  │                                                      │   │
│  │  ┌─────────────┐  ┌──────────────┐  ┌────────────┐  │   │
│  │  │  Customer   │  │ Social Login │  │  Consent   │  │   │
│  │  │  Lifecycle  │  │  Federation  │  │  Manager   │  │   │
│  │  └─────────────┘  └──────────────┘  └────────────┘  │   │
│  │                                                      │   │
│  │  ┌─────────────┐  ┌──────────────┐  ┌────────────┐  │   │
│  │  │  Screen Set │  │  Site Policy │  │  Audit Log │  │   │
│  │  │  Engine     │  │  Enforcement │  │  Service   │  │   │
│  │  └─────────────┘  └──────────────┘  └────────────┘  │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Key Capabilities:**
- B2C customer registration and self-service account management
- Multi-channel authentication (email/password, social, SSO, SAML, OIDC)
- Regulatory consent management (GDPR, CCPA)
- Configurable UI flows via screen sets
- Policy-driven security (password complexity, MFA, lockout)
- Complete audit trail for compliance

---

## NOV-2: Operational Node Connectivity

```
┌──────────────────────────────────────────────────────────────┐
│                   Operational Nodes                          │
│                                                              │
│  [Customer Browser / App]                                    │
│       │                                                      │
│       ▼  REST/HTTP (port 8119)                               │
│  [Customer Identity Service]                                 │
│       │                    │                                 │
│       ▼                    ▼                                 │
│  [Identity Store]     [Social IdP]                          │
│  (In-Memory/MongoDB)  (Google/FB/Apple/SAML/OIDC)           │
│       │                                                      │
│       ▼                                                      │
│  [Audit Log Store]                                           │
│       │                                                      │
│       ▼                                                      │
│  [Consent Store]                                             │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

**Node Descriptions:**

| Node | Role |
|------|------|
| Customer Browser/App | End-user client invoking REST APIs |
| Customer Identity Service | Core CIAM microservice (port 8119) |
| Identity Store | Persistent storage for customers, sessions, identities |
| Social IdP | External OAuth2/OIDC/SAML identity providers |
| Audit Log Store | Append-only audit event log |
| Consent Store | GDPR/CCPA consent records |

---

## SV-1: System Interface Description

```
┌─────────────────────────────────────────────────────────────────┐
│                  Customer Identity Service                      │
│                                                                 │
│  ┌──────────────────┐     ┌──────────────────────────────────┐  │
│  │  Presentation    │     │         Infrastructure           │  │
│  │  Layer (HTTP)    │     │                                  │  │
│  │                  │     │  MemoryCustomerRepository        │  │
│  │  CustomerCtrl    │────▶│  MemorySessionRepository         │  │
│  │  SessionCtrl     │     │  MemorySocialIdentityRepository  │  │
│  │  SocialIdCtrl    │     │  MemoryConsentRecordRepository   │  │
│  │  ConsentCtrl     │     │  MemoryAuditLogRepository        │  │
│  │  AuditLogCtrl    │     │  MemoryIdentityProviderRepository│  │
│  │  IdpCtrl         │     │  MemoryScreenSetRepository       │  │
│  │  ScreenSetCtrl   │     │  MemorySitePolicyRepository      │  │
│  │  SitePolicyCtrl  │     └──────────────────────────────────┘  │
│  │  HealthCtrl      │                                           │
│  └──────────────────┘                                           │
│           │                                                     │
│           ▼                                                     │
│  ┌──────────────────┐                                           │
│  │  Application     │                                           │
│  │  Use Cases       │                                           │
│  │                  │                                           │
│  │  ManageCustomers │                                           │
│  │  ManageSessions  │                                           │
│  │  ManageSocial    │                                           │
│  │  ManageConsents  │                                           │
│  │  ManageAuditLogs │                                           │
│  │  ManageIdps      │                                           │
│  │  ManageScreenSets│                                           │
│  │  ManagePolicies  │                                           │
│  └──────────────────┘                                           │
│           │                                                     │
│           ▼                                                     │
│  ┌──────────────────┐                                           │
│  │  Domain Layer    │                                           │
│  │                  │                                           │
│  │  Customer        │                                           │
│  │  CustomerSession │                                           │
│  │  SocialIdentity  │                                           │
│  │  ConsentRecord   │                                           │
│  │  AuditLog        │                                           │
│  │  IdentityProvider│                                           │
│  │  ScreenSet       │                                           │
│  │  SitePolicy      │                                           │
│  └──────────────────┘                                           │
└─────────────────────────────────────────────────────────────────┘
```

**External Interfaces:**

| Interface | Protocol | Direction | Description |
|-----------|----------|-----------|-------------|
| REST API | HTTP/JSON | Inbound | Client requests for all CRUD operations |
| Health Check | HTTP/JSON | Inbound | `GET /health` for liveness probe |
| Social IdP OAuth2 | HTTPS | Outbound | Token exchange with social providers |
| SAML IdP | HTTPS | Outbound | SAML assertion validation |
| OIDC IdP | HTTPS | Outbound | OIDC token introspection |

---

## SV-4: System Functional Flow

### Registration and First Login

```
1. Client           →  POST /api/v1/customer-identity/customers
2. CustomerCtrl     →  ManageCustomersUseCase.registerCustomer(dto)
3. UseCase          →  IdentityValidator.validateCustomer(customer)
4. UseCase          →  ICustomerRepository.findByEmail(tenantId, email) → null
5. UseCase          →  ICustomerRepository.add(customer)
6. UseCase          →  ManageAuditLogsUseCase.recordAuditEvent(REGISTER)
7. UseCase          →  CommandResult(success=true, id)
8. CustomerCtrl     →  201 Created {id}
```

### Social Login Linking

```
1. Client           →  POST /api/v1/customer-identity/social-identities
2. SocialIdCtrl     →  ManageSocialIdentitiesUseCase.linkSocialIdentity(dto)
3. UseCase          →  ICustomerRepository.findById(customerId) → Customer
4. UseCase          →  ISocialIdentityRepository.findByProvider(provider, uid) → null
5. UseCase          →  ISocialIdentityRepository.add(socialIdentity)
6. UseCase          →  ManageAuditLogsUseCase.recordAuditEvent(LINK_SOCIAL)
7. UseCase          →  CommandResult(success=true, id)
8. SocialIdCtrl     →  201 Created {id}
```

### Consent Grant

```
1. Client           →  POST /api/v1/customer-identity/consents
2. ConsentCtrl      →  ManageConsentRecordsUseCase.grantConsent(dto)
3. UseCase          →  IConsentRecordRepository.add(record)
4. UseCase          →  ManageAuditLogsUseCase.recordAuditEvent(GRANT_CONSENT)
5. UseCase          →  CommandResult(success=true, id)
6. ConsentCtrl      →  201 Created {id}
```

### Policy-Enforced Authentication Check

```
1. UseCase          →  ISitePolicyRepository.findActive(tenantId)
2. UseCase          →  Check maxLoginAttempts exceeded?
3. UseCase          →  Check accountLocked? (lockoutDurationSeconds elapsed?)
4. UseCase          →  Verify MFA if policy.mfaRequired
5. UseCase          →  Validate password against passwordComplexity
6. UseCase          →  Create CustomerSession
7. UseCase          →  ManageAuditLogsUseCase.recordAuditEvent(LOGIN)
```

---

## Technology Stack

| Layer | Technology |
|-------|-----------|
| Language | D (LDC2 compiler) |
| HTTP Framework | vibe.d 0.10.x |
| Architecture | Hexagonal / Clean |
| Containerization | Docker / Podman (Alpine 3.20) |
| Orchestration | Kubernetes |
| Persistence | In-Memory (default) / File / MongoDB |
| Port | 8119 |
| Namespace | uim-platform |
