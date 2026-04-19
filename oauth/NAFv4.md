# OAuth 2.0 Service — NAFv4 Architecture Views

## C1 — Capability Taxonomy

```mermaid
graph TB
    OA[OAuth 2.0 Service]
    OA --> OCM[OAuth Client Management]
    OA --> OSM[OAuth Scope Management]
    OA --> ATM[Access Token Management]
    OA --> RTM[Refresh Token Management]
    OA --> ACM[Authorization Code Management]
    OA --> BCM[Branding Configuration]

    OCM --> OCM1[Client Registration]
    OCM --> OCM2[Client Types - Confidential/Public]
    OCM --> OCM3[Redirect URI Management]
    OCM --> OCM4[Grant Type Configuration]

    OSM --> OSM1[Scope Definition]
    OSM --> OSM2[Application Scope Binding]
    OSM --> OSM3[Scope Status Management]
    OSM --> OSM4[Tenant Scope Isolation]

    ATM --> ATM1[Token Issuance]
    ATM --> ATM2[Token Validation]
    ATM --> ATM3[Token Revocation]
    ATM --> ATM4[Token Expiration]

    RTM --> RTM1[Refresh Token Issuance]
    RTM --> RTM2[Token Rotation]
    RTM --> RTM3[Refresh Token Revocation]
    RTM --> RTM4[Access Token Association]

    ACM --> ACM1[Code Generation]
    ACM --> ACM2[Single-Use Enforcement]
    ACM --> ACM3[Redirect URI Binding]
    ACM --> ACM4[Code Expiration]

    BCM --> BCM1[Logo Configuration]
    BCM --> BCM2[Color Theming]
    BCM --> BCM3[Page Title and Footer]
    BCM --> BCM4[Custom CSS]
```

## C2 — Service Taxonomy

```mermaid
graph TB
    subgraph "OAuth 2.0 Platform Service"
        API[REST API Layer]
        APP[Application Layer]
        DOM[Domain Layer]
        INF[Infrastructure Layer]
    end

    subgraph "Consumed Services"
        IAS[Identity Authentication]
        IDS[Identity Directory]
        AUD[Audit Log Service]
        CRS[Credential Store]
    end

    API --> APP
    APP --> DOM
    DOM --> INF

    API -.-> IAS
    INF -.-> IDS
    INF -.-> AUD
    INF -.-> CRS
```

## L1 — Logical Data Model

```mermaid
erDiagram
    OAUTH_CLIENT ||--o{ ACCESS_TOKEN : issues
    OAUTH_CLIENT ||--o{ REFRESH_TOKEN : issues
    OAUTH_CLIENT ||--o{ AUTHORIZATION_CODE : generates
    OAUTH_CLIENT }o--o{ OAUTH_SCOPE : uses
    ACCESS_TOKEN ||--o| REFRESH_TOKEN : "paired with"

    OAUTH_CLIENT {
        string id PK
        string tenantId
        string clientId
        string clientSecret
        string name
        string clientType
        string status
        string redirectUris
        string allowedScopes
        string grantTypes
        long accessTokenValidity
        long refreshTokenValidity
    }

    OAUTH_SCOPE {
        string id PK
        string tenantId
        string applicationId
        string name
        string description
        string status
    }

    ACCESS_TOKEN {
        string id PK
        string tenantId
        string tokenValue
        string tokenType
        string status
        string clientId FK
        string userId
        string scopes
        long expiresAt
    }

    REFRESH_TOKEN {
        string id PK
        string tenantId
        string tokenValue
        string status
        string clientId FK
        string userId
        string scopes
        string accessTokenId FK
        long expiresAt
    }

    AUTHORIZATION_CODE {
        string id PK
        string tenantId
        string code
        string clientId FK
        string userId
        string redirectUri
        string scopes
        string status
        long expiresAt
    }

    BRANDING_CONFIG {
        string id PK
        string tenantId
        string name
        string logoUrl
        string primaryColor
        string secondaryColor
        string pageTitle
        string customCss
    }
```

## L2 — Service Architecture

```mermaid
graph TB
    subgraph "Presentation Layer"
        R[URLRouter]
        OCC[OAuthClientController]
        OSC[OAuthScopeController]
        ATC[AccessTokenController]
        RTC[RefreshTokenController]
        ACC[AuthorizationCodeController]
        BCC[BrandingConfigController]
        HC[HealthController]
    end

    subgraph "Application Layer"
        MOCU[ManageOAuthClientsUseCase]
        MOSU[ManageOAuthScopesUseCase]
        MATU[ManageAccessTokensUseCase]
        MRTU[ManageRefreshTokensUseCase]
        MACU[ManageAuthorizationCodesUseCase]
        MBCU[ManageBrandingConfigsUseCase]
    end

    subgraph "Domain Layer"
        E[Entities]
        RI[Repository Interfaces]
        V[OAuthValidator]
    end

    subgraph "Infrastructure Layer"
        MR[Memory Repositories]
        AC[AppConfig]
        DI[Container]
    end

    R --> OCC & OSC & ATC & RTC & ACC & BCC & HC
    OCC --> MOCU
    OSC --> MOSU
    ATC --> MATU
    RTC --> MRTU
    ACC --> MACU
    BCC --> MBCU
    MOCU & MOSU & MATU & MRTU & MACU & MBCU --> RI
    MOCU & MOSU & MATU & MRTU & MACU & MBCU --> V
    MR -.-> RI
    DI --> MR
    DI --> AC
```

## L4 — Deployment View

```mermaid
graph TB
    subgraph "Kubernetes Cluster"
        subgraph "uim-platform namespace"
            CM[ConfigMap: oauth-config]
            DEP[Deployment: oauth]
            SVC[Service: oauth]
            POD[Pod: oauth]
        end
    end

    subgraph "Container"
        APP[uim-oauth-platform-service]
    end

    CM --> DEP
    DEP --> POD
    POD --> APP
    SVC --> POD
    APP -->|":8114"| SVC
```

## P1 — Physical Network

```mermaid
graph LR
    CLIENT[HTTP Client] -->|"port 8114"| SVC[K8s Service: oauth]
    SVC --> POD[Pod: oauth]
    POD --> CTR[Container: Alpine Linux]
    CTR --> BIN[uim-oauth-platform-service]
```

## S1 — Security Architecture

```mermaid
graph TB
    subgraph "Security Controls"
        TLS[TLS Termination]
        AUTH[Tenant Isolation]
        VAL[Input Validation]
        SEC[Secret Protection]
    end

    subgraph "OAuth 2.0 Flows"
        ACF[Authorization Code Flow]
        CCF[Client Credentials Flow]
        RTF[Refresh Token Flow]
    end

    subgraph "Token Security"
        TI[Token Issuance]
        TV[Token Validation]
        TR[Token Revocation]
        TE[Token Expiration]
    end

    TLS --> ACF & CCF & RTF
    AUTH --> ACF & CCF & RTF
    VAL --> TI
    SEC --> TI
    TI --> TV
    TV --> TR
    TV --> TE
```

## Sv1 — Service View

```mermaid
graph TB
    subgraph "OAuth 2.0 Service"
        EP1["/api/v1/oauth/clients"]
        EP2["/api/v1/oauth/scopes"]
        EP3["/api/v1/oauth/access-tokens"]
        EP4["/api/v1/oauth/refresh-tokens"]
        EP5["/api/v1/oauth/authorization-codes"]
        EP6["/api/v1/oauth/branding-configs"]
        EP7["/health"]
    end

    subgraph "Operations"
        CRUD[CRUD Operations]
        REVOKE[Token Revocation]
        USE[Code Consumption]
    end

    EP1 --> CRUD
    EP2 --> CRUD
    EP3 --> CRUD
    EP3 --> REVOKE
    EP4 --> CRUD
    EP4 --> REVOKE
    EP5 --> CRUD
    EP5 --> USE
    EP6 --> CRUD
```
