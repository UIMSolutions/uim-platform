# UIM Identity Directory Platform Service

A microservice for identity provisioning, group management, custom schema
extensions, password policies, API client credentials, and audit logging,
inspired by **SAP Cloud Identity Directory (IDS / SCIM)**. Built with **D** and
**vibe.d**, following **Clean Architecture** and **Hexagonal Architecture**
(Ports & Adapters) principles.

Part of the [UIM Platform](https://www.sueel.de/uim/sap) suite.

## Features

| Capability | Description |
|---|---|
| **User Management (SCIM 2.0)** | Full CRUD for users with SCIM-compliant structured names, multi-valued emails, phone numbers, addresses, lifecycle status (Active / Inactive / Locked / Staged), and custom schema extensions |
| **Group Management (SCIM 2.0)** | Standard and dynamic groups with nested membership (User or Group members), member add/remove operations, and tenant-scoped display name search |
| **Custom Schemas** | SCIM 2.0 schema extensions with typed attributes (String, Integer, Boolean, DateTime, Reference, Complex, Binary), mutability rules, returned behavior, and uniqueness constraints |
| **Password Policies** | Configurable password rules per tenant — min/max length, character class requirements (uppercase, lowercase, digit, special), unique character minimum, consecutive repeat limit, password history, failed-attempt lockout, and expiry days |
| **Password Validation** | Domain service that validates passwords against all policy rules and returns a list of specific violations |
| **Schema Validation** | Domain service that validates user extended attributes against schema definitions, checking required fields, read-only guards, and unknown attribute detection |
| **Password Hashing** | SHA-256 password hashing via the PasswordService port with pluggable adapter |
| **API Clients** | Technical user / service-to-service credentials with scoped access, expiration, client ID + secret generation (secret returned only at creation), and revocation |
| **Audit Logging** | Immutable audit trail for 21 event types (user/group/schema/client lifecycle, password changes, login events) with actor, target, IP address, user agent, and custom metadata |
| **SCIM Search** | User search endpoint with filter expressions and pagination (startIndex, itemsPerPage) |

## Architecture

```
identity-directory/
├── source/
│   ├── app.d                                       # Entry point & composition root
│   ├── domain/                                     # Pure business logic (no dependencies)
│   │   ├── types.d                                 #   Type aliases & enums
│   │   ├── entities/                               #   Core domain structs
│   │   │   ├── user.d                              #     SCIM 2.0 user with name, emails, phones, addresses
│   │   │   ├── group.d                             #     SCIM 2.0 group with nested members
│   │   │   ├── schema.d                            #     Custom schema definitions with typed attributes
│   │   │   ├── password_policy.d                   #     Password policy configuration
│   │   │   ├── api_client.d                        #     Service-to-service credentials
│   │   │   └── audit_event.d                       #     Immutable audit log entries
│   │   ├── ports/                                  #   Repository interfaces (ports)
│   │   │   ├── user_repository.d                   #     Paginated, searchable user store
│   │   │   ├── group_repository.d                  #     Group store with member lookup
│   │   │   ├── schema_repository.d
│   │   │   ├── password_policy_repository.d
│   │   │   ├── api_client_repository.d
│   │   │   ├── audit_repository.d
│   │   │   └── password_service.d                  #     Hashing & verification port
│   │   └── services/                               #   Stateless domain services
│   │       ├── password_validator.d                #     Policy-based password validation
│   │       └── schema_validator.d                  #     Extended attribute validation
│   ├── application/                                #   Application layer (use cases)
│   │   ├── dto.d                                   #     Request / Response DTOs & SCIM list response
│   │   └── usecases/                              #     Application services
│   │       ├── manage.users.d
│   │       ├── manage.groups.d
│   │       ├── manage.schemas.d
│   │       ├── manage.password_policies.d
│   │       ├── manage.api_clients.d
│   │       └── query_audit_log.d
│   ├── infrastructure/                             #   Technical adapters
│   │   ├── config.d                                #     Environment-based configuration
│   │   ├── container.d                             #     Dependency injection wiring
│   │   ├── persistence/                            #     In-memory repository implementations
│   │   │   ├── in_memory_user_repo.d
│   │   │   ├── in_memory_group_repo.d
│   │   │   ├── in_memory_schema_repo.d
│   │   │   ├── in_memory_password_policy_repo.d
│   │   │   ├── in_memory_api_client_repo.d
│   │   │   └── in_memory_audit_repo.d
│   │   └── security/                               #     Security adapters
│   │       └── sha256_password_service.d           #       SHA-256 password hashing
│   └── presentation/                               #   HTTP driving adapters
│       └── http/
│           ├── json_utils.d                        #     JSON helper functions
│           ├── health_controller.d
│           ├── user_controller.d
│           ├── group_controller.d
│           ├── schema_controller.d
│           ├── password_policy_controller.d
│           ├── api_client_controller.d
│           └── audit_controller.d
└── dub.sdl
```

## REST API

### SCIM 2.0 Endpoints

#### Users

```
POST   /scim/Users                         Create a user
GET    /scim/Users                         List all users (SCIM ListResponse)
GET    /scim/Users/{id}                    Get user by ID
PUT    /scim/Users/{id}                    Update a user (full replacement)
DELETE /scim/Users/{id}                    Delete a user
POST   /scim/Users/change-password         Change user password
GET    /scim/Users/.search                 Search users with filter & pagination
```

#### Groups

```
POST   /scim/Groups                        Create a group
GET    /scim/Groups                        List all groups (SCIM ListResponse)
GET    /scim/Groups/{id}                   Get group by ID
PUT    /scim/Groups/{id}                   Update group displayName / description
DELETE /scim/Groups/{id}                   Delete a group
POST   /scim/Groups/members                Add a member to a group
DELETE /scim/Groups/members                Remove a member from a group
```

#### Schemas

```
POST   /scim/Schemas                       Create a custom schema
GET    /scim/Schemas                       List all schemas
GET    /scim/Schemas/{id}                  Get schema by ID
PUT    /scim/Schemas/{id}                  Update schema name, description, attributes
DELETE /scim/Schemas/{id}                  Delete a schema
```

### Management Endpoints

#### Password Policies

```
POST   /api/v1/password-policies           Create a password policy
GET    /api/v1/password-policies           List all policies
GET    /api/v1/password-policies/active    Get the active policy for tenant
GET    /api/v1/password-policies/{id}      Get policy by ID
```

#### API Clients

```
POST   /api/v1/api-clients                Create a client (returns clientId + clientSecret)
GET    /api/v1/api-clients                List all clients (secret stripped)
GET    /api/v1/api-clients/{id}           Get client by ID (secret stripped)
DELETE /api/v1/api-clients/{id}           Revoke a client
```

#### Audit Logs

```
GET    /api/v1/audit-logs                  List all audit events for tenant
GET    /api/v1/audit-logs/actor/{id}       Filter events by actor ID
GET    /api/v1/audit-logs/target/{id}      Filter events by target resource ID
```

#### Health

```
GET    /api/v1/health                      → {"status":"UP","service":"identity-directory"}
```

## Build and Run

```bash
# Build
cd identity-directory
dub build

# Run (default: 0.0.0.0:8082)
./build/uim-identity-directory-platform-service

# Override host/port via environment
IDS_HOST=127.0.0.1 IDS_PORT=9090 ./build/uim-identity-directory-platform-service
```

## Configuration

| Variable | Default | Description |
|---|---|---|
| `IDS_HOST` | `0.0.0.0` | HTTP bind address |
| `IDS_PORT` | `8082` | HTTP listen port |

## Domain Model Overview

### Type Aliases

| Alias | Underlying | Purpose |
|---|---|---|
| `UserId` | `string` | User identifier |
| `GroupId` | `string` | Group identifier |
| `TenantId` | `string` | Tenant identifier |
| `SchemaId` | `string` | Schema URN identifier |
| `AttributeId` | `string` | Schema attribute identifier |
| `ApiClientId` | `string` | API client identifier |

### Enumerations

| Enum | Values |
|---|---|
| **UserStatus** | Active, Inactive, Locked, Staged |
| **GroupType** | Standard, Dynamic |
| **AttributeType** | String, Integer, Boolean, DateTime, Reference, Complex, Binary |
| **Mutability** | ReadWrite, ReadOnly, WriteOnly, Immutable |
| **Returned** | Always, Never, Default, Request |
| **Uniqueness** | None, Server, Global |
| **PasswordStrength** | Weak, Standard, Strong, Enterprise |
| **AuditEventType** | UserCreated, UserUpdated, UserDeleted, UserActivated, UserDeactivated, UserLocked, UserUnlocked, PasswordChanged, PasswordReset, GroupCreated, GroupUpdated, GroupDeleted, MemberAdded, MemberRemoved, SchemaCreated, SchemaUpdated, SchemaDeleted, ApiClientCreated, ApiClientRevoked, LoginSuccess, LoginFailure |
| **SortOrder** | Ascending, Descending |

### SCIM 2.0 Value Objects

| Type | Fields |
|---|---|
| **UserName** | formatted, familyName, givenName, middleName, honorificPrefix, honorificSuffix |
| **Email** | value, type (work/home/other), primary |
| **PhoneNumber** | value, type (work/mobile/fax/other), primary |
| **Address** | formatted, streetAddress, locality, region, postalCode, country, type, primary |
| **ExtendedAttribute** | schemaId, attributeName, value |
| **GroupMember** | value (user/group ID), type ("User"/"Group"), display |
| **SchemaAttribute** | id, name, description, type, multiValued, required, mutability, returned, uniqueness, canonicalValues, referenceTypes |

### Domain Services

- **PasswordValidator** — validates a password string against all `PasswordPolicy` rules (length, character classes, unique chars, repeat limit) and returns a `PasswordValidationResult` with specific violations
- **SchemaValidator** — validates user `ExtendedAttribute[]` against a `Schema` definition, checking required fields, read-only attributes, and unknown attribute names

## Testing

```bash
dub test
```

## License

See the repository root [LICENSE](../LICENSE) file.
