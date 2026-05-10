# UML — Authorization and Trust Management Service

## Component Diagram (Hexagonal Architecture)

```
┌──────────────────────────────────────────────────────────────────────────────────────┐
│                    Authorization and Trust Management Service                        │
│                                                                                      │
│  ┌───────────────────────────────────────────────────────────────────────────────┐  │
│  │                    Presentation Layer (Driving Adapters)                       │  │
│  │  ┌──────────────┐ ┌────────────┐ ┌───────────┐ ┌──────────────────────────┐  │  │
│  │  │OAuthClientCtrl│ │ScopeCtrl  │ │RoleCtrl   │ │RoleCollectionController   │  │  │
│  │  │/oauth/clients │ │/scopes    │ │/roles     │ │/role-collections          │  │  │
│  │  └──────┬────────┘ └─────┬─────┘ └─────┬─────┘ └────────────┬─────────────┘  │  │
│  │         │                │             │                     │               │  │
│  │  ┌──────────────┐ ┌─────────────────┐ ┌──────────────────┐  │               │  │
│  │  │UserAssignment│ │IdentityProvider │ │ TokenController  │  │               │  │
│  │  │Controller    │ │ Controller      │ │ /oauth/token     │  │               │  │
│  │  └──────┬───────┘ └────────┬────────┘ └────────┬─────────┘  │               │  │
│  └─────────┼──────────────────┼──────────────────  ┼────────────┼───────────────┘  │
│            │                  │                    │            │                   │
│  ┌─────────▼──────────────────▼────────────────────▼────────────▼───────────────┐  │
│  │                          Application Layer                                    │  │
│  │  ManageOAuthClientsUseCase    ManageScopesUseCase    ManageRolesUseCase       │  │
│  │  ManageRoleCollectionsUseCase ManageUserAssignmentsUseCase                    │  │
│  │  ManageIdentityProvidersUseCase                                               │  │
│  │  DTOs: CreateOAuthClientRequest, CreateScopeRequest, CreateRoleRequest,       │  │
│  │        CreateRoleCollectionRequest, CreateUserAssignmentRequest,              │  │
│  │        CreateIdentityProviderRequest, IssueTokenRequest, CommandResult        │  │
│  └─────────────────────────────────┬──────────────────────────────────────────  ┘  │
│                                    │                                                │
│  ┌─────────────────────────────────▼──────────────────────────────────────────── ┐ │
│  │                            Domain Layer                                        │ │
│  │  Entities: OAuthClientEntity, ScopeEntity, RoleEntity, RoleCollectionEntity,  │ │
│  │            UserAssignmentEntity, IdentityProviderEntity                        │ │
│  │  Types:    GrantType, ClientType, IdpType, OAuthClientId, ScopeId, RoleId,   │ │
│  │            RoleCollectionId, UserAssignmentId, IdentityProviderId             │ │
│  │  Ports:    OAuthClientRepository, ScopeRepository, RoleRepository,           │ │
│  │            RoleCollectionRepository, UserAssignmentRepository,               │ │
│  │            IdentityProviderRepository (all interfaces)                        │ │
│  │  Services: TokenService (JWT issuance / validation)                          │ │
│  └─────────────────────────────────┬──────────────────────────────────────────  ┘ │
│                                    │                                                │
│  ┌─────────────────────────────────▼──────────────────────────────────────────── ┐ │
│  │                  Infrastructure Layer (Driven Adapters)                        │ │
│  │  MemoryOAuthClientRepository   MemoryScopeRepository   MemoryRoleRepository   │ │
│  │  MemoryRoleCollectionRepository  MemoryUserAssignmentRepository               │ │
│  │  MemoryIdentityProviderRepository                                             │ │
│  │  SrvConfig (env vars)   Container (DI)                                        │ │
│  └───────────────────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Class Diagram

### Domain — Entities

```
┌───────────────────────────────────┐   ┌───────────────────────────────────┐
│ OAuthClientEntity                 │   │ ScopeEntity                       │
├───────────────────────────────────┤   ├───────────────────────────────────┤
│ id             : OAuthClientId    │   │ id             : ScopeId          │
│ clientId       : string           │   │ name           : string           │
│ clientSecret   : string (hashed)  │   │ description    : string           │
│ name           : string           │   │ appId          : string           │
│ description    : string           │   │ createdAt      : long             │
│ grantTypes     : GrantType[]      │   │ updatedAt      : long             │
│ scopes         : string[]         │   └───────────────────────────────────┘
│ redirectUris   : string[]         │
│ clientType     : ClientType       │   ┌───────────────────────────────────┐
│ appId          : string           │   │ RoleEntity                        │
│ createdAt      : long             │   ├───────────────────────────────────┤
│ updatedAt      : long             │   │ id             : RoleId           │
└───────────────────────────────────┘   │ name           : string           │
                                        │ description    : string           │
┌───────────────────────────────────┐   │ scopeReferences: string[]         │
│ RoleCollectionEntity              │   │ appId          : string           │
├───────────────────────────────────┤   │ createdAt      : long             │
│ id             : RoleCollectionId │   │ updatedAt      : long             │
│ name           : string           │   └───────────────────────────────────┘
│ description    : string           │
│ roleReferences : string[]         │   ┌───────────────────────────────────┐
│ createdAt      : long             │   │ UserAssignmentEntity              │
│ updatedAt      : long             │   ├───────────────────────────────────┤
└───────────────────────────────────┘   │ id             : UserAssignmentId │
                                        │ userId         : string           │
┌───────────────────────────────────┐   │ userEmail      : string           │
│ IdentityProviderEntity            │   │ roleCollectionId: RoleCollectionId│
├───────────────────────────────────┤   │ origin         : string           │
│ id             : IdentityProviderId│  │ createdAt      : long             │
│ alias_         : string           │   └───────────────────────────────────┘
│ displayName    : string           │
│ idpType        : IdpType          │
│ metadataUrl    : string           │
│ entityId       : string           │
│ ssoUrl         : string           │
│ sloUrl         : string           │
│ signingCert    : string           │
│ isActive       : bool             │
│ isDefault      : bool             │
│ createdAt      : long             │
│ updatedAt      : long             │
└───────────────────────────────────┘
```

---

## Sequence Diagram — Token Issuance (Client Credentials)

```
Client                OAuthClientController        TokenService       OAuthClientRepository
  │                           │                         │                      │
  │  POST /api/v1/oauth/token │                         │                      │
  │  grant_type=client_creds  │                         │                      │
  │──────────────────────────►│                         │                      │
  │                           │ findByClientId(id)      │                      │
  │                           │────────────────────────────────────────────────►
  │                           │◄────────────────────────────────────────────────
  │                           │ validateSecret(secret)  │                      │
  │                           │────────────────────────►│                      │
  │                           │ generateJWT(client,     │                      │
  │                           │  scopes)                │                      │
  │                           │────────────────────────►│                      │
  │                           │◄── JWT token ───────────│                      │
  │◄─── 200 {access_token} ───│                         │                      │
```

---

## Sequence Diagram — Role Collection Assignment

```
Admin               RoleCollectionController    ManageRoleCollectionsUseCase   MemoryRoleCollectionRepository
  │                         │                            │                              │
  │  POST /api/v1/          │                            │                              │
  │  role-collections       │                            │                              │
  │────────────────────────►│                            │                              │
  │                         │ create(request)            │                              │
  │                         │───────────────────────────►│                              │
  │                         │                            │ save(roleCollection)         │
  │                         │                            │─────────────────────────────►│
  │                         │ CommandResult(success, id) │                              │
  │◄─── 201 {id} ───────────│                            │                              │
```

---

## Deployment View

```
┌──────────────────────────────────────────────────────────────────┐
│  Kubernetes Cluster                                              │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Pod: authorization-trust                                 │   │
│  │  ┌─────────────────────────────────────────────────┐    │   │
│  │  │  Container: uim-authorization-trust-platform-   │    │   │
│  │  │             service                             │    │   │
│  │  │  Port: 8116                                     │    │   │
│  │  │  Health: GET /api/v1/health                     │    │   │
│  │  └─────────────────────────────────────────────────┘    │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ConfigMap: authorization-trust-config                          │
│    AUTHORIZATION_TRUST_HOST=0.0.0.0                             │
│    AUTHORIZATION_TRUST_PORT=8116                                 │
│                                                                  │
│  Service: authorization-trust (ClusterIP :8116)                 │
└──────────────────────────────────────────────────────────────────┘
```
