# Identity Directory – NAF v4 Architecture Description

This document describes the **UIM Identity Directory Platform Service**
using the **NATO Architecture Framework v4 (NAF v4)** viewpoints, adapted for
a microservice based on SAP Cloud Identity Directory / SCIM 2.0 concepts.

---

## 1. NAF v4 Grid Mapping

| Viewpoint | View | Section |
|---|---|---|
| **NCV** – Capability | C1 – Capability Taxonomy | §2 |
| **NCV** – Capability | C2 – Enterprise Vision | §2 |
| **NSOV** – Service | NSOV-1 – Service Taxonomy | §3 |
| **NSOV** – Service | NSOV-2 – Service Definitions | §3 |
| **NOV** – Operational | NOV-2 – Operational Node Connectivity | §4 |
| **NLV** – Logical | NLV-1 – Logical Data Model | §5 |
| **NPV** – Physical | NPV-1 – Physical Deployment | §6 |
| **NIV** – Information | NIV-1 – Information Structure | §7 |

---

## 2. Capability View (NCV)

### C1 – Capability Taxonomy

```
C1  Identity Directory Capability
├── C1.1  User Management (SCIM 2.0)
│   ├── C1.1.1  User Provisioning (create, update, delete)
│   ├── C1.1.2  User Lifecycle (Active → Inactive → Locked → Staged)
│   ├── C1.1.3  SCIM Structured Names (formatted, given, family, prefix, suffix)
│   ├── C1.1.4  Multi-Valued Attributes (emails, phone numbers, addresses)
│   ├── C1.1.5  Custom Schema Extensions (ExtendedAttribute bindings)
│   ├── C1.1.6  User Search with Filter & Pagination
│   └── C1.1.7  Password Change
├── C1.2  Group Management (SCIM 2.0)
│   ├── C1.2.1  Group Provisioning (create, update, delete)
│   ├── C1.2.2  Group Types (Standard, Dynamic)
│   ├── C1.2.3  Nested Membership (User or Group members)
│   └── C1.2.4  Member Add / Remove Operations
├── C1.3  Schema Management
│   ├── C1.3.1  Custom Schema Definitions (URN-based)
│   ├── C1.3.2  Typed Attributes (String, Integer, Boolean, DateTime, Reference, Complex, Binary)
│   ├── C1.3.3  Attribute Constraints (Mutability, Returned, Uniqueness)
│   └── C1.3.4  Schema Validation of Extended Attributes
├── C1.4  Password Policy
│   ├── C1.4.1  Policy Configuration (length, character classes, history, lockout, expiry)
│   ├── C1.4.2  Password Strength Levels (Weak, Standard, Strong, Enterprise)
│   └── C1.4.3  Password Validation against Active Policy
├── C1.5  API Client Management
│   ├── C1.5.1  Client Credential Generation (clientId + clientSecret)
│   ├── C1.5.2  Scoped Access Control
│   ├── C1.5.3  Client Expiration
│   └── C1.5.4  Client Revocation
└── C1.6  Audit Logging
    ├── C1.6.1  21 Event Types (user, group, schema, client, password, login)
    ├── C1.6.2  Actor & Target Tracking
    └── C1.6.3  Filtering by Actor or Target
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide a centralised, SCIM 2.0-compliant identity directory for user provisioning, group assignment, and credential management across multi-tenant environments |
| **Vision** | A standards-based identity store that unifies user lifecycle, schema extensibility, and security policy enforcement behind a single API |
| **Strategic Goal** | Enable seamless user provisioning from SAP and third-party systems with audit-grade traceability, configurable password policies, and service-to-service authentication via API clients |
| **Scope** | Manages users, groups, custom schemas, password policies, API client credentials, and immutable audit events |
| **Stakeholders** | Identity Administrators, Application Developers, Security Officers, Compliance Auditors, Integration Architects |

---

## 3. Service View (NSOV)

### NSOV-1 – Service Taxonomy

```
NSOV-1  Identity Directory Services
├── SVC-USER   User Management Services (SCIM 2.0)
├── SVC-GRP    Group Management Services (SCIM 2.0)
├── SVC-SCH    Schema Management Services (SCIM 2.0)
├── SVC-PWP    Password Policy Services
├── SVC-AC     API Client Services
├── SVC-AUD    Audit Log Services
└── SVC-HEALTH Health / Readiness Services
```

### NSOV-2 – Service Definitions

| Service ID | Name | Interface | Protocol | Path Prefix | Methods |
|---|---|---|---|---|---|
| SVC-USER-CREATE | Create User | SCIM | HTTP/JSON | `/scim/Users` | POST |
| SVC-USER-LIST | List Users | SCIM | HTTP/JSON | `/scim/Users` | GET |
| SVC-USER-GET | Get User | SCIM | HTTP/JSON | `/scim/Users/{id}` | GET |
| SVC-USER-UPDATE | Update User | SCIM | HTTP/JSON | `/scim/Users/{id}` | PUT |
| SVC-USER-DELETE | Delete User | SCIM | HTTP/JSON | `/scim/Users/{id}` | DELETE |
| SVC-USER-CHPWD | Change Password | SCIM | HTTP/JSON | `/scim/Users/change-password` | POST |
| SVC-USER-SEARCH | Search Users | SCIM | HTTP/JSON | `/scim/Users/.search` | GET |
| SVC-GRP-CREATE | Create Group | SCIM | HTTP/JSON | `/scim/Groups` | POST |
| SVC-GRP-LIST | List Groups | SCIM | HTTP/JSON | `/scim/Groups` | GET |
| SVC-GRP-GET | Get Group | SCIM | HTTP/JSON | `/scim/Groups/{id}` | GET |
| SVC-GRP-UPDATE | Update Group | SCIM | HTTP/JSON | `/scim/Groups/{id}` | PUT |
| SVC-GRP-DELETE | Delete Group | SCIM | HTTP/JSON | `/scim/Groups/{id}` | DELETE |
| SVC-GRP-ADDMEM | Add Member | SCIM | HTTP/JSON | `/scim/Groups/members` | POST |
| SVC-GRP-RMMEM | Remove Member | SCIM | HTTP/JSON | `/scim/Groups/members` | DELETE |
| SVC-SCH-CREATE | Create Schema | SCIM | HTTP/JSON | `/scim/Schemas` | POST |
| SVC-SCH-LIST | List Schemas | SCIM | HTTP/JSON | `/scim/Schemas` | GET |
| SVC-SCH-GET | Get Schema | SCIM | HTTP/JSON | `/scim/Schemas/{id}` | GET |
| SVC-SCH-UPDATE | Update Schema | SCIM | HTTP/JSON | `/scim/Schemas/{id}` | PUT |
| SVC-SCH-DELETE | Delete Schema | SCIM | HTTP/JSON | `/scim/Schemas/{id}` | DELETE |
| SVC-PWP-CREATE | Create Policy | REST | HTTP/JSON | `/api/v1/password-policies` | POST |
| SVC-PWP-LIST | List Policies | REST | HTTP/JSON | `/api/v1/password-policies` | GET |
| SVC-PWP-ACTIVE | Get Active Policy | REST | HTTP/JSON | `/api/v1/password-policies/active` | GET |
| SVC-PWP-GET | Get Policy | REST | HTTP/JSON | `/api/v1/password-policies/{id}` | GET |
| SVC-AC-CREATE | Create Client | REST | HTTP/JSON | `/api/v1/api-clients` | POST |
| SVC-AC-LIST | List Clients | REST | HTTP/JSON | `/api/v1/api-clients` | GET |
| SVC-AC-GET | Get Client | REST | HTTP/JSON | `/api/v1/api-clients/{id}` | GET |
| SVC-AC-REVOKE | Revoke Client | REST | HTTP/JSON | `/api/v1/api-clients/{id}` | DELETE |
| SVC-AUD-LIST | List Audit Events | REST | HTTP/JSON | `/api/v1/audit-logs` | GET |
| SVC-AUD-ACTOR | Events by Actor | REST | HTTP/JSON | `/api/v1/audit-logs/actor/{id}` | GET |
| SVC-AUD-TARGET | Events by Target | REST | HTTP/JSON | `/api/v1/audit-logs/target/{id}` | GET |
| SVC-HEALTH | Health Check | REST | HTTP/JSON | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

### NOV-2 – Operational Node Connectivity

```
                     ┌──────────────────────────────────┐
                     │          HTTP Clients             │
                     │  (SCIM Provisioning Agent /       │
                     │   Admin Console / API Consumer)   │
                     └──────────────┬───────────────────┘
                                    │ HTTP / JSON
                                    ▼
                     ┌──────────────────────────────────┐
                     │    Presentation Layer             │
                     │  ┌────────────────────────────┐  │
                     │  │ SCIM 2.0:                  │  │
                     │  │   UserController            │  │
                     │  │   GroupController           │  │
                     │  │   SchemaController          │  │
                     │  ├────────────────────────────┤  │
                     │  │ Management API:             │  │
                     │  │   PasswordPolicyController  │  │
                     │  │   ApiClientController       │  │
                     │  │   AuditController           │  │
                     │  │   HealthController          │  │
                     │  └────────────────────────────┘  │
                     └──────────────┬───────────────────┘
                                    │ calls
                                    ▼
                     ┌──────────────────────────────────┐
                     │    Application Layer              │
                     │  ┌────────────────────────────┐  │
                     │  │ ManageUsersUseCase          │  │
                     │  │ ManageGroupsUseCase         │  │
                     │  │ ManageSchemasUseCase        │  │
                     │  │ ManagePasswordPoliciesUC    │  │
                     │  │ ManageApiClientsUseCase     │  │
                     │  │ QueryAuditLogUseCase        │  │
                     │  └────────────────────────────┘  │
                     └──────────────┬───────────────────┘
                                    │ depends on ports
                                    ▼
                     ┌──────────────────────────────────┐
                     │    Domain Layer                   │
                     │  ┌────────────────────────────┐  │
                     │  │ Entities:                   │  │
                     │  │   User, Group, Schema       │  │
                     │  │   PasswordPolicy            │  │
                     │  │   ApiClient, AuditEvent     │  │
                     │  ├────────────────────────────┤  │
                     │  │ Ports (Interfaces):         │  │
                     │  │   UserRepository            │  │
                     │  │   GroupRepository           │  │
                     │  │   SchemaRepository          │  │
                     │  │   PasswordPolicyRepository  │  │
                     │  │   ApiClientRepository       │  │
                     │  │   AuditRepository           │  │
                     │  │   PasswordService           │  │
                     │  ├────────────────────────────┤  │
                     │  │ Domain Services:            │  │
                     │  │   PasswordValidator         │  │
                     │  │   SchemaValidator           │  │
                     │  └────────────────────────────┘  │
                     └──────────────┬───────────────────┘
                                    │ implements
                                    ▼
                     ┌──────────────────────────────────┐
                     │    Infrastructure Layer           │
                     │  ┌────────────────────────────┐  │
                     │  │ AppConfig (IDS_HOST/PORT)   │  │
                     │  │ Container (DI wiring)       │  │
                     │  ├────────────────────────────┤  │
                     │  │ In-Memory Repositories:     │  │
                     │  │   MemoryUserRepo          │  │
                     │  │   MemoryGroupRepo         │  │
                     │  │   MemorySchemaRepo        │  │
                     │  │   MemoryPasswordPolicyRepo│  │
                     │  │   MemoryApiClientRepo     │  │
                     │  │   MemoryAuditRepo         │  │
                     │  ├────────────────────────────┤  │
                     │  │ Security Adapters:          │  │
                     │  │   Sha256PasswordService     │  │
                     │  └────────────────────────────┘  │
                     └──────────────────────────────────┘
                                    │
                     ┌──────────────┼───────────────────┐
                     ▼              ▼                    ▼
              ┌──────────┐  ┌──────────────┐  ┌────────────┐
              │ Audit Log│  │ Identity     │  │  Portal    │
              │ Service  │  │ Authentica.  │  │  Service   │
              └──────────┘  └──────────────┘  └────────────┘
```

**Operational Information Exchanges:**

| Exchange | From | To | Content | Frequency |
|---|---|---|---|---|
| OIE-1 | SCIM Agent | Identity Directory | User provisioning requests (CRUD) | On demand |
| OIE-2 | SCIM Agent | Identity Directory | Group management & membership operations | On demand |
| OIE-3 | Admin Console | Identity Directory | Schema definitions, password policies, API clients | On demand |
| OIE-4 | Identity Directory | Audit Store | Immutable audit event per state change | Per operation |
| OIE-5 | Identity Directory | Client | SCIM ListResponse with pagination | Per query |
| OIE-6 | Identity Directory | Client | API client credentials (secret at creation only) | Per creation |
| OIE-7 | Identity Auth. | Identity Directory | User lookup for authentication validation | Per login |
| OIE-8 | Compliance Tool | Identity Directory | Audit log queries by actor / target | On demand |

---

## 5. Logical View (NLV)

### NLV-1 – Logical Data Model

```
┌──────────────────────────────────────────────────────────────────┐
│  User Domain                                                      │
│                                                                   │
│  ┌──────────────────────────┐                                    │
│  │  User                     │                                    │
│  ├──────────────────────────┤                                    │
│  │ id : UserId               │       ┌──────────────────────┐   │
│  │ tenantId : TenantId       │──1:N──│ Email                 │   │
│  │ externalId : string       │       ├──────────────────────┤   │
│  │ userName : string         │       │ value, type : string  │   │
│  │ name : UserName           │       │ primary : bool        │   │
│  │ displayName : string      │       └──────────────────────┘   │
│  │ status : UserStatus       │                                    │
│  │ passwordHash : string     │       ┌──────────────────────┐   │
│  │ groupIds : string[]       │──1:N──│ PhoneNumber           │   │
│  │ schemas : string[]        │       ├──────────────────────┤   │
│  │ createdAt, updatedAt      │       │ value, type : string  │   │
│  └──────────────────────────┘       │ primary : bool        │   │
│           │                          └──────────────────────┘   │
│           │ 1:N                                                   │
│           ▼                          ┌──────────────────────┐   │
│  ┌──────────────────────────┐──1:N──│ Address               │   │
│  │ ExtendedAttribute         │       ├──────────────────────┤   │
│  ├──────────────────────────┤       │ streetAddress, city   │   │
│  │ schemaId : string         │       │ region, postalCode    │   │
│  │ attributeName : string    │       │ country, type         │   │
│  │ value : string            │       │ primary : bool        │   │
│  └──────────────────────────┘       └──────────────────────┘   │
│                                                                   │
│  ┌──────────────────────────┐                                    │
│  │  UserName                 │                                    │
│  ├──────────────────────────┤                                    │
│  │ formatted, familyName    │                                    │
│  │ givenName, middleName    │                                    │
│  │ honorificPrefix          │                                    │
│  │ honorificSuffix          │                                    │
│  └──────────────────────────┘                                    │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Group Domain                                                     │
│                                                                   │
│  ┌──────────────────────────┐       ┌──────────────────────┐   │
│  │  Group                    │──1:N──│  GroupMember          │   │
│  ├──────────────────────────┤       ├──────────────────────┤   │
│  │ id : GroupId              │       │ value : string (ID)   │   │
│  │ tenantId : TenantId       │       │ type : "User"/"Group" │   │
│  │ displayName, description  │       │ display : string      │   │
│  │ groupType : GroupType     │       └──────────────────────┘   │
│  │ schemas : string[]        │                                    │
│  │ createdAt, updatedAt      │                                    │
│  └──────────────────────────┘                                    │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Schema Domain                                                    │
│                                                                   │
│  ┌──────────────────────────┐       ┌──────────────────────┐   │
│  │  Schema (URN-based)       │──1:N──│  SchemaAttribute      │   │
│  ├──────────────────────────┤       ├──────────────────────┤   │
│  │ id : SchemaId (URN)       │       │ id : AttributeId      │   │
│  │ tenantId : TenantId       │       │ name, description     │   │
│  │ name, description         │       │ type : AttributeType  │   │
│  │ createdAt, updatedAt      │       │ multiValued : bool    │   │
│  └──────────────────────────┘       │ required : bool       │   │
│                                      │ mutability            │   │
│                                      │ returned              │   │
│                                      │ uniqueness            │   │
│                                      │ canonicalValues[]     │   │
│                                      │ referenceTypes[]      │   │
│                                      └──────────────────────┘   │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Security Domain                                                  │
│                                                                   │
│  ┌──────────────────────────┐       ┌──────────────────────┐   │
│  │  PasswordPolicy           │       │  ApiClient            │   │
│  ├──────────────────────────┤       ├──────────────────────┤   │
│  │ id, tenantId              │       │ id : ApiClientId      │   │
│  │ name, description         │       │ tenantId : TenantId   │   │
│  │ strength : PasswordStrength       │ name, description     │   │
│  │ minLength, maxLength      │       │ clientId, clientSecret│   │
│  │ requireUppercase .. etc   │       │ scopes : string[]     │   │
│  │ passwordHistoryCount      │       │ active : bool         │   │
│  │ maxFailedAttempts         │       │ expiresAt : long      │   │
│  │ lockoutDurationMinutes    │       │ lastUsedAt : long     │   │
│  │ expiryDays, active        │       └──────────────────────┘   │
│  └──────────────────────────┘                                    │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Audit Domain                                                     │
│                                                                   │
│  ┌──────────────────────────────────────────┐                    │
│  │  AuditEvent (immutable)                   │                    │
│  ├──────────────────────────────────────────┤                    │
│  │ id, tenantId                              │                    │
│  │ eventType : AuditEventType (21 values)    │                    │
│  │ actorId, actorType                        │                    │
│  │ targetId, targetType                      │                    │
│  │ description : string                      │                    │
│  │ ipAddress, userAgent : string             │                    │
│  │ details : string[string]                  │                    │
│  │ timestamp : long                          │                    │
│  └──────────────────────────────────────────┘                    │
└──────────────────────────────────────────────────────────────────┘
```

**Key Enumerations:**

| Enum | Values |
|---|---|
| UserStatus | Active, Inactive, Locked, Staged |
| GroupType | Standard, Dynamic |
| AttributeType | String, Integer, Boolean, DateTime, Reference, Complex, Binary |
| Mutability | ReadWrite, ReadOnly, WriteOnly, Immutable |
| Returned | Always, Never, Default, Request |
| Uniqueness | None, Server, Global |
| PasswordStrength | Weak, Standard, Strong, Enterprise |
| AuditEventType | UserCreated, UserUpdated, UserDeleted, UserActivated, UserDeactivated, UserLocked, UserUnlocked, PasswordChanged, PasswordReset, GroupCreated, GroupUpdated, GroupDeleted, MemberAdded, MemberRemoved, SchemaCreated, SchemaUpdated, SchemaDeleted, ApiClientCreated, ApiClientRevoked, LoginSuccess, LoginFailure |
| SortOrder | Ascending, Descending |

---

## 6. Physical View (NPV)

### NPV-1 – Physical Deployment

```
┌─────────────────────────────────────────────────────────────┐
│  Deployment Node: Application Server                         │
│  OS: Linux                                                   │
│  Runtime: Native D binary (compiled with dub + DMD/LDC)     │
│                                                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │  Artifact: uim-identity-directory-platform-service  │     │
│  │            (executable)                             │     │
│  │  Source:   identity-directory/source/**/*.d          │     │
│  │  Binary:   identity-directory/build/                 │     │
│  │            uim-identity-directory-platform-service   │     │
│  │  Port:     8082 (configurable IDS_PORT)              │     │
│  │  Protocol: HTTP/1.1 (vibe.d event loop)              │     │
│  └────────────────────────────────────────────────────┘     │
│                                                              │
│  Environment Variables:                                      │
│  ┌────────────────┬──────────┬──────────────────────┐       │
│  │ Name           │ Default  │ Description           │       │
│  ├────────────────┼──────────┼──────────────────────┤       │
│  │ IDS_HOST       │ 0.0.0.0  │ HTTP bind address     │       │
│  │ IDS_PORT       │ 8082     │ HTTP listen port      │       │
│  └────────────────┴──────────┴──────────────────────┘       │
│                                                              │
│  Dependencies:                                               │
│  ┌────────────────────────────┬──────────┐                  │
│  │ Package                    │ Version  │                  │
│  ├────────────────────────────┼──────────┤                  │
│  │ uim-platform:service       │ local    │                  │
│  └────────────────────────────┴──────────┘                  │
│                                                              │
│  Persistence: In-memory (ephemeral)                          │
│  Scaling: Stateless – horizontally scalable with external    │
│           persistence adapter                                │
└─────────────────────────────────────────────────────────────┘
```

**Deployment Constraints:**

| Constraint | Description |
|---|---|
| DC-1 | Single-process, multi-threaded via vibe.d fibers |
| DC-2 | In-memory persistence is non-durable; data is lost on restart |
| DC-3 | Swapping to durable persistence requires implementing 6 repository interfaces + 1 PasswordService adapter |
| DC-4 | SHA-256 password hashing is a development adapter; replace with bcrypt/argon2 for production |
| DC-5 | API client secret is only returned at creation time; cannot be recovered |

---

## 7. Information View (NIV)

### NIV-1 – Information Structure

**Information Flows:**

| Flow ID | Source | Target | Data | Format | Trigger |
|---|---|---|---|---|---|
| IF-1 | SCIM Agent | UserController | User identity attributes (name, emails, phones, addresses) | JSON | Provisioning sync |
| IF-2 | SCIM Agent | GroupController | Group definitions, membership changes | JSON | Provisioning sync |
| IF-3 | Admin | SchemaController | Custom schema with typed attribute definitions | JSON | Admin action |
| IF-4 | Admin | PasswordPolicyController | Policy rules (length, complexity, lockout, expiry) | JSON | Admin action |
| IF-5 | Service | ApiClientController | Client registration (name, scopes, expiry) | JSON | Admin action |
| IF-6 | ApiClientController | Client | clientId + clientSecret (creation only) | JSON | Response |
| IF-7 | ManageUsersUseCase | PasswordService | Plaintext → SHA-256 hash | Internal | On create / change-password |
| IF-8 | ManageUsersUseCase | AuditRepository | Audit event (user lifecycle change) | Internal | Per state change |
| IF-9 | ManageGroupsUseCase | UserRepository | Validate member exists | Internal | On add-member |
| IF-10 | Compliance Tool | AuditController | Audit query by actor / target | JSON | On demand |

**Data Sensitivity:**

| Data Element | Classification | Handling |
|---|---|---|
| Password (plaintext) | Secret | Received during create/change-password; immediately hashed via PasswordService; never stored |
| Password hash | Secret | SHA-256 hash stored in User entity; not exposed via API responses |
| API client secret | Secret | Generated at creation; returned once; stored but stripped from list/get responses |
| User PII (name, email, phone, address) | Personal data | SCIM-compliant structured storage; tenant-isolated |
| Audit events | Compliance-sensitive | Immutable; append-only; contains actor/target references, IP addresses |
| Schema definitions | Configuration | Tenant-scoped; controls attribute validation rules |

---

## 8. Traceability Matrix

| Capability | Service(s) | Entity/ies | Controller | Use Case |
|---|---|---|---|---|
| C1.1 User Management | SVC-USER-* | User, UserName, Email, PhoneNumber, Address | UserController | ManageUsersUseCase |
| C1.1.5 Schema Extensions | (internal) | ExtendedAttribute | — | SchemaValidator |
| C1.1.7 Password Change | SVC-USER-CHPWD | User | UserController | ManageUsersUseCase |
| C1.2 Group Management | SVC-GRP-* | Group, GroupMember | GroupController | ManageGroupsUseCase |
| C1.3 Schema Management | SVC-SCH-* | Schema, SchemaAttribute | SchemaController | ManageSchemasUseCase |
| C1.4 Password Policy | SVC-PWP-* | PasswordPolicy | PasswordPolicyController | ManagePasswordPoliciesUseCase |
| C1.4.3 Password Validation | (internal) | PasswordPolicy | — | PasswordValidator |
| C1.5 API Clients | SVC-AC-* | ApiClient | ApiClientController | ManageApiClientsUseCase |
| C1.6 Audit Logging | SVC-AUD-* | AuditEvent | AuditController | QueryAuditLogUseCase |

---

*Document generated for the UIM Platform Identity Directory Service.*
*Authors: UIM Platform Team*
*© 2018–2026 UIM Platform Team — Proprietary*
