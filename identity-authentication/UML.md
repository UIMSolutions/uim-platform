# UML — Identity Authentication Service

## Components (hexagonal architecture)

```mermaid
flowchart LR
  subgraph Driving["Driving adapters (presentation)"]
    HTTP["http: AuthController, UserController, …"]
    REST["rest: UserRestService (IUserApi)"]
    OData["odata: IdentityODataController"]
    CLI["cli: IdentityCli"]
    GUI["gui: IdentityWindow (GtkD)"]
    WEB["web: FrontendController (Fiori static)"]
  end
  subgraph Core["Application + domain"]
    Ports["IdentityPorts (driving ports)"]
    UC["Use cases: AuthenticateUser, IssueToken, Manage*"]
    Stats["IdentityStatisticsService"]
    Dom["Domain: entities, risk / policy evaluators, lifecycle, validator"]
  end
  subgraph Driven["Driven adapters"]
    Repo["persistence: *Repository"]
    Store["SnapshotTenantStore → JsonFile / Memory storage"]
    Sec["security: Pbkdf2Password, Sha256Secret, JwtToken, TotpMfa"]
    Msg["logging: LogEventPublisher (audit)"]
    OTP["clients: WebhookOtpSender / LogOtpSender"]
  end
  HTTP & REST & OData & CLI & GUI --> Ports
  Ports --> UC & Stats
  UC --> Dom
  UC --> Repo --> Store
  UC --> Sec
  UC --> Msg
  Sec --> OTP
  Fiori["frontend (UI5, uim.ias)"] -->|OData v4| Approuter["approuter (XSUAA)"] --> OData
```

## Domain model

```mermaid
classDiagram
  class IAUser {
    UserId id
    TenantId tenantId
    string userName
    string email
    string passwordHash
    UserStatus status
    MfaType mfaType
    string mfaSecret
    GroupId[] groupIds
    int failedLoginAttempts
    long lastLoginAt
    isActive() bool
    hasMfa() bool
  }
  class IAGroup {
    GroupId id
    string name
    UserId[] memberUserIds
  }
  class Application {
    ApplicationId id
    SsoProtocol protocol
    string clientId
    string clientSecretHash
    string[] redirectUris
    string[] allowedScopes
    bool active
  }
  class AuthorizationPolicy {
    PolicyId id
    PolicyRule[] rules
    string[] applicationIds
    bool active
  }
  class PolicyRule {
    string attribute
    string operator_
    string value
  }
  class RiskRule {
    RiskRuleId id
    RiskCondition[] conditions
    RiskLevel riskLevel
    MfaType requiredMfa
    bool denyAccess
  }
  class IdpConfig {
    IdpConfigId id
    IdpType idpType
    string authorizationEndpoint
    string[] domainHints
    bool isDefault
  }
  class IASession {
    SessionId id
    UserId userId
    MfaType mfaUsed
    RiskLevel riskLevel
    long expiresAt
    bool revoked
  }
  class Token {
    TokenId id
    SessionId sessionId
    TokenType tokenType
    string tokenHash
    string[] scopes
    long expiresAt
    bool revoked
  }
  IAUser "*" -- "*" IAGroup : membership
  AuthorizationPolicy "1" *-- "*" PolicyRule
  AuthorizationPolicy "*" --> "*" Application : applies to
  RiskRule "1" *-- "*" RiskCondition
  IASession "*" --> "1" IAUser
  Token "*" --> "1" IASession
  Token "*" --> "1" Application
```

User status lifecycle (`domain/services/lifecycle.d`):

```mermaid
stateDiagram-v2
  [*] --> pendingVerification
  [*] --> active
  pendingVerification --> active
  pendingVerification --> inactive
  active --> locked : too many failures / admin
  active --> inactive
  locked --> active : unlock (resets failures)
  locked --> inactive
  inactive --> active
```

## Ports

```mermaid
classDiagram
  class IdentityPorts {
    IAuthenticationUseCase authentication
    ITokenUseCase tokens
    IManageSessionsUseCase sessions
    IManageUsersUseCase users
    IManageGroupsUseCase groups
    IManageApplicationsUseCase applications
    IManagePoliciesUseCase policies
    IManageRiskRulesUseCase riskRules
    IManageIdentityProvidersUseCase identityProviders
    IIdentityStatisticsService statistics
  }
  class IPasswordService { hashPassword() verifyPassword() }
  class ISecretService { randomSecret() fingerprint() matches() }
  class ITokenService { sign() verify() generateSamlAssertion() }
  class IMfaService { generateSecret() currentCode() validateCode() provisioningUri() sendOtp() }
  class IOtpSender { send() }
  class IIdentityEventPublisher { publish() }
  class ISnapshotStorage { load() store() revision() }
  Pbkdf2PasswordService ..|> IPasswordService
  Sha256SecretService ..|> ISecretService
  JwtTokenService ..|> ITokenService
  TotpMfaService ..|> IMfaService
  WebhookOtpSender ..|> IOtpSender
  LogOtpSender ..|> IOtpSender
  LogEventPublisher ..|> IIdentityEventPublisher
  JsonFileSnapshotStorage ..|> ISnapshotStorage
  MemorySnapshotStorage ..|> ISnapshotStorage
```

## Login and token flow

```mermaid
sequenceDiagram
  participant C as Client
  participant A as AuthenticateUserUseCase
  participant R as RiskRules
  participant M as IMfaService
  participant T as IssueTokenUseCase
  participant P as Policies
  C->>A: login(email, password, mfaCode?)
  A->>A: find user, check status, verify PBKDF2 hash
  A->>R: assessRisk(rules, user, ip / agent / groups)
  alt denied
    A-->>C: 403
  else second factor needed, no code
    A->>M: sendOtp (SMS / e-mail)
    A-->>C: 401 mfaRequired
  else ok
    A->>M: validateCode (TOTP)
    A-->>C: sessionId
  end
  C->>T: token(sessionId, client_id, client_secret, scope)
  T->>T: session active? client secret fingerprint? scopes allowed?
  T->>P: findDenyingPolicies(app policies, user)
  T-->>C: access / refresh / id token (JWT, stored as SHA-256)
  C->>T: refresh_token
  T->>T: rotate (old refresh token revoked); reuse ⇒ revoke session
```
