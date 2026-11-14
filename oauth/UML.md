# UML — OAuth 2.0 Service

These diagrams describe the 2.0 implementation in
`backend/source/uim/platform/oauth/`.

## Component diagram (hexagonal architecture)

```mermaid
flowchart LR
  subgraph Clients
    Fiori[SAP Fiori 3 app]
    App[Client applications\nweb / SPA / native / services]
    RS[Resource servers\nplatform services]
    Admin[Operator shell]
    Desk[Desktop user]
  end

  subgraph BTP[SAP BTP]
    AR[approuter + XSUAA\nuser login]
  end

  subgraph Presentation[presentation — driving adapters]
    PROT[OAuthProtocolController\n/oauth/authorize · token · introspect · revoke\n/.well-known/oauth-authorization-server]
    OD[ODataController\n/odata/v4/oauth]
    REST[OAuthRestController\n/api/v1/oauth]
    CLI[CLI commands\nuim-oauth-cli]
    GUI[GtkD entity browser\nuim-oauth-gui]
    WEB[FrontendController /app]
    HEALTH[OAuthHealthController /health]
    ENG{{ODataEngine\nEDM model + providers}}
  end

  subgraph Ports[ports]
    PU[[driving: IManageClients · IManageScopes · IManageBrandings · IManageTokens\nIAuthenticateClients · IAuthorize · IIssueTokens · IIntrospectTokens\nIOAuthStatisticsService]]
    PD[[driven: I*Repository · IDocumentStore\nITokenSigner · ISecretGenerator]]
  end

  subgraph Application[application]
    UC[use cases\nManageClients · ManageScopes · ManageBrandings · ManageTokens\nAuthenticateClients · Authorize · IssueTokens · IntrospectTokens]
    SVC[services\nOAuthStatisticsService · demo data · support]
  end

  subgraph Domain[domain]
    ENT[entities\nOAuthClient · OAuthScope · AccessToken\nRefreshToken · AuthorizationCode · BrandingConfig]
    DS[domain services\ncredentials + PKCE · scope policy · token claims]
    TY[types · enumerations · exceptions]
  end

  subgraph Infra[infrastructure + persistence]
    CFG[OAuthConfig\ndefaults → json → OAUTH_* → VCAP]
    SEC[SecuritySetup XSUAA/HS256\nHs256TokenSigner · SystemSecretGenerator\nresolveSigningKey]
    WRK[ExpiryPurgeWorker]
    REPO[Document repositories\n+ mappers + records]
    STORE[(Memory / File\nDocumentStore)]
    CONT[OAuthContainer\ncomposition root]
  end

  Fiori --> AR --> OD
  AR -->|user token| PROT
  App --> PROT
  RS -->|introspect| PROT
  Admin --> CLI
  Desk --> GUI
  OD --> ENG
  REST --> ENG
  CLI --> ENG
  GUI --> ENG
  CLI --> PU
  PROT --> PU
  ENG --> PU
  PU -.implemented by.-> UC
  UC --> ENT
  UC --> DS
  UC --> PD
  PD -.implemented by.-> REPO
  PD -.implemented by.-> SEC
  REPO --> STORE
  WRK --> PU
  CONT --> UC
  CONT --> REPO
  CONT --> SEC
  CFG --> CONT
```

Dependencies point inward. The domain uses no I/O and no vibe.d. The
application layer depends only on ports. Two kinds of adapters drive the
service: the management adapters, which share the EDM-driven engine, and the
protocol controller, which calls the protocol ports directly.

## Domain class diagram

```mermaid
classDiagram
  direction LR

  class TenantEntity {
    <<mixin>>
    +TId id
    +TenantId tenantId
    +long createdAt
    +UserId createdBy
    +long updatedAt
    +UserId updatedBy
    +isNull() bool
  }

  class OAuthClient {
    +string clientId
    -string secretHash
    -string secretSalt
    +long secretRotatedAt
    +string name
    +string description
    +ClientType clientType
    +ClientStatus status
    +string[] redirectUris
    +string[] allowedScopes
    +GrantType[] grantTypes
    +long accessTokenValidity
    +long refreshTokenValidity
    +string[] contacts
    +string brandingId
    +isActive() bool
    +isConfidential() bool
    +hasSecret() bool
    +allowsGrant(GrantType) bool
    +allowsRedirect(string) bool
    +issuesRefreshTokens() bool
    +validate()
  }

  class OAuthScope {
    +string applicationId
    +string name
    +string description
    +ScopeStatus status
    +isActive() bool
    +validate()
  }

  class AccessToken {
    -string tokenHash
    +string clientId
    +string userId
    +string[] scopes
    +GrantType grantType
    +TokenStatus status
    +long issuedAt
    +long expiresAt
    +long revokedAt
    +RevocationReason revocationReason
    +string refreshTokenId
    +string authorizationCodeId
    +effectiveStatus(now) TokenStatus
    +isUsable(now) bool
    +revoke(reason, now) bool
  }

  class RefreshToken {
    -string tokenHash
    +string clientId
    +string userId
    +string[] scopes
    +string accessTokenId
    +string replacedById
    +TokenStatus status
    +long issuedAt
    +long expiresAt
    +RevocationReason revocationReason
    +effectiveStatus(now) TokenStatus
    +isUsable(now) bool
    +revoke(reason, now) bool
    +wasRotated() bool
  }

  class AuthorizationCode {
    -string codeHash
    +string clientId
    +string userId
    +string redirectUri
    +string[] scopes
    -string codeChallenge
    +CodeChallengeMethod codeChallengeMethod
    +AuthCodeStatus status
    +long issuedAt
    +long expiresAt
    +long usedAt
    +effectiveStatus(now) AuthCodeStatus
    +isRedeemable(now) bool
    +markUsed(now)
  }

  class BrandingConfig {
    +string name
    +string logoUrl
    +string backgroundUrl
    +string primaryColor
    +string secondaryColor
    +string pageTitle
    +string footerText
    +string customCss
    +bool isDefault
    +validate()
  }

  TenantEntity <|.. OAuthClient
  TenantEntity <|.. OAuthScope
  TenantEntity <|.. AccessToken
  TenantEntity <|.. RefreshToken
  TenantEntity <|.. AuthorizationCode
  TenantEntity <|.. BrandingConfig

  OAuthClient "*" --> "*" OAuthScope : allowedScopes (by name)
  OAuthClient "*" --> "0..1" BrandingConfig : brandingId
  AccessToken "*" --> "1" OAuthClient : clientId
  RefreshToken "*" --> "1" OAuthClient : clientId
  AuthorizationCode "*" --> "1" OAuthClient : clientId
  AccessToken "*" --> "0..1" RefreshToken : refreshTokenId
  AccessToken "*" --> "0..1" AuthorizationCode : authorizationCodeId
  RefreshToken "0..1" --> "0..1" RefreshToken : replacedById (rotation chain)
```

Private (`-`) fields are persisted but never serialized by any adapter.

### Enumerations and domain services

```mermaid
classDiagram
  class ClientType {
    <<enumeration>>
    confidential
    public
  }
  class ClientStatus {
    <<enumeration>>
    active
    inactive
    blocked
  }
  class GrantType {
    <<enumeration>>
    authorization_code
    client_credentials
    refresh_token
  }
  class CodeChallengeMethod {
    <<enumeration>>
    none
    plain
    S256
  }
  class TokenStatus {
    <<enumeration>>
    active
    expired
    revoked
  }
  class AuthCodeStatus {
    <<enumeration>>
    active
    used
    expired
    revoked
  }
  class ScopeStatus {
    <<enumeration>>
    active
    inactive
  }
  class RevocationReason {
    <<enumeration>>
    manual
    clientBlocked
    clientDeleted
    secretRotated
    rotated
    replayDetected
    parentRevoked
  }
  class OAuthError {
    <<enumeration>>
    invalid_request
    invalid_client
    invalid_grant
    unauthorized_client
    unsupported_grant_type
    unsupported_response_type
    invalid_scope
    access_denied
    login_required
    server_error
  }

  class credentials {
    <<domain service>>
    +hashSecret(salt, secret) string
    +fingerprint(value) string
    +verifySecret(salt, hash, presented) bool
    +constantTimeEquals(a, b) bool
    +isValidCodeVerifier(v) bool
    +s256Challenge(verifier) string
    +verifyPkce(method, challenge, verifier) bool
  }
  class scope_policy {
    <<domain service>>
    +grantScopes(requested, allowed, active) string[]
    +refreshScopes(requested, original) string[]
  }
  class token_claims {
    <<domain service>>
    +accessTokenClaims(AccessToken, issuer) Json
  }
  class OAuthException {
    +OAuthErrorKind kind
  }
  class OAuthProtocolException {
    +OAuthError error
    +httpStatus() int
  }
```

`OAuthException` (invalid, notFound, conflict, ruleViolation) is used by the
management APIs and maps to 400/404/409/422. `OAuthProtocolException` carries
the RFC 6749 error code and maps to 400 or 401 on the protocol endpoints.

## Ports and application

```mermaid
classDiagram
  direction TB
  class OAuthPorts {
    <<struct>>
    IManageClients clients
    IManageScopes scopes
    IManageBrandings brandings
    IManageTokens tokens
    IAuthenticateClients authentication
    IAuthorize authorization
    IIssueTokens issuer
    IIntrospectTokens introspection
    IOAuthStatisticsService statistics
  }
  class IManageClients {
    <<interface>>
    +createClient(req) ClientCredentials
    +updateClient(req)
    +deleteClient()
    +rotateSecret() ClientCredentials
  }
  class IManageTokens {
    <<interface>>
    +revokeAccessToken()
    +revokeRefreshToken()
    +revokeClientTokens()
    +purgeExpired()
  }
  class IAuthenticateClients {
    <<interface>>
    +authenticate(tenant, clientId, secret) OAuthClient
  }
  class IAuthorize {
    <<interface>>
    +redirectUriFor(req) string
    +authorize(req) AuthorizationGrant
  }
  class IIssueTokens {
    <<interface>>
    +exchange(TokenRequest) TokenResponse
  }
  class IIntrospectTokens {
    <<interface>>
    +introspect(tenant, token, hint)
    +revoke(tenant, token, hint, requester)
  }
  class ITokenSigner {
    <<driven>>
    +algorithm()
    +sign(claims)
    +verify(token, out claims)
  }
  class ISecretGenerator {
    <<driven>>
    +generate(bytes) string
  }
  class IDocumentStore {
    <<driven>>
    +all()
    +get()
    +put()
    +remove()
    +count()
  }

  class IssueTokensUseCase
  class AuthorizeUseCase
  class ManageClientsUseCase
  class IntrospectTokensUseCase
  class Hs256TokenSigner
  class SystemSecretGenerator
  class FileDocumentStore

  IIssueTokens <|.. IssueTokensUseCase
  IAuthorize <|.. AuthorizeUseCase
  IManageClients <|.. ManageClientsUseCase
  IIntrospectTokens <|.. IntrospectTokensUseCase
  ITokenSigner <|.. Hs256TokenSigner
  ISecretGenerator <|.. SystemSecretGenerator
  IDocumentStore <|.. FileDocumentStore

  IssueTokensUseCase --> IAuthenticateClients
  IssueTokensUseCase --> ITokenSigner
  IssueTokensUseCase --> ISecretGenerator
  ManageClientsUseCase --> ISecretGenerator
  ManageClientsUseCase --> IManageTokens : revoke on block / rotate
  IntrospectTokensUseCase --> IManageTokens
```

## State machines

### OAuth client

```mermaid
stateDiagram-v2
  [*] --> active : create (secret generated for confidential clients)
  active --> inactive : status = inactive (tokens are no longer accepted)
  inactive --> active
  active --> blocked : status = blocked / revoke all tokens
  inactive --> blocked : revoke all tokens
  blocked --> active
  active --> active : rotateSecret / revoke all tokens
  active --> [*] : delete / remove tokens and codes
  inactive --> [*]
  blocked --> [*]
```

### Authorization code

```mermaid
stateDiagram-v2
  [*] --> active : /authorize
  active --> used : token request (redirect URI + PKCE verified)
  active --> expired : expiresAt reached (5 min)
  active --> revoked : client blocked / secret rotated
  used --> revoked : presented again / revoke issued tokens
  used --> [*] : purge after expiry
  expired --> [*] : purge
  revoked --> [*] : purge
```

### Refresh token (rotation)

```mermaid
stateDiagram-v2
  [*] --> active : issued with authorization_code / refresh_token grant
  active --> revoked_rotated : used once / successor issued (replacedById)
  active --> revoked : RFC 7009 revoke · client blocked · secret rotated
  active --> expired : expiresAt reached (absolute lifetime)
  revoked_rotated --> revoked_replay : presented again / revoke the whole grant
  revoked_rotated --> [*] : purge after expiry
  revoked --> [*] : purge
  expired --> [*] : purge
```

An access token is `active` until it expires (→ `expired`) or is revoked
(→ `revoked`). Revoking its refresh token revokes the access token too
(`parentRevoked`).

## Sequence: authorization code + PKCE (public client)

```mermaid
sequenceDiagram
  autonumber
  participant App as Native app (public client)
  participant AR as approuter + XSUAA
  participant P as OAuthProtocolController
  participant AZ as AuthorizeUseCase
  participant IT as IssueTokensUseCase
  participant S as Hs256TokenSigner
  participant DB as DocumentStore

  App->>App: code_verifier = random(43..128), challenge = S256(verifier)
  App->>AR: GET /oauth/authorize?response_type=code&client_id&redirect_uri&scope&state&code_challenge
  AR->>AR: user login (XSUAA)
  AR->>P: forward + user JWT (RS256)
  P->>P: SecuritySetup.resolve → verified user, tenant (zid)
  P->>AZ: redirectUriFor(req)
  AZ->>DB: client by clientId
  AZ-->>P: registered redirect URI (else 400, no redirect)
  P->>AZ: authorize(req)
  AZ->>AZ: response_type, client active, grant allowed, user present, PKCE required for public
  AZ->>AZ: grantScopes(requested, allowed, active)
  AZ->>DB: save AuthorizationCode(codeHash, challenge, expires 5 min)
  P-->>App: 302 redirect_uri?code&state&iss
  App->>P: POST /oauth/token grant_type=authorization_code&client_id&code&code_verifier
  P->>IT: exchange(TokenRequest)
  IT->>DB: authenticate client (public: no secret)
  IT->>DB: code by fingerprint(code)
  IT->>IT: not used? not expired? redirect_uri matches? verifyPkce(S256)
  IT->>DB: markUsed(code)
  IT->>S: sign(accessTokenClaims)
  IT->>DB: save AccessToken(jti, tokenHash) + RefreshToken(hash)
  P-->>App: 200 {access_token, token_type, expires_in, refresh_token, scope} (no-store)
```

## Sequence: refresh token rotation and replay detection

```mermaid
sequenceDiagram
  autonumber
  participant C as Client
  participant A as Attacker (stolen RT1)
  participant IT as IssueTokensUseCase
  participant DB as DocumentStore

  C->>IT: refresh_token = RT1
  IT->>DB: RT1 active → revoke(rotated), replacedById = RT2
  IT->>DB: save AT2, RT2 (same scope ceiling, same absolute expiry)
  IT-->>C: AT2, RT2
  A->>IT: refresh_token = RT1 (replay)
  IT->>DB: RT1.wasRotated → revoke all live tokens of client + user (replayDetected)
  IT-->>A: 400 invalid_grant
  C->>IT: refresh_token = RT2
  IT-->>C: 400 invalid_grant (grant was revoked, user must log in again)
```

## Sequence: resource server validates a token

```mermaid
sequenceDiagram
  participant Client
  participant RS as Platform service (resource server)
  participant P as /oauth/introspect
  Client->>RS: request + Bearer AT
  alt local validation (shared signing secret)
    RS->>RS: Hs256TokenVerifier.verify → resolveRequestContext (zid, user_id, scope[])
  else introspection (revocation aware)
    RS->>P: POST token=AT (Basic auth of a confidential client)
    P-->>RS: {active, scope, client_id, sub, exp, zid}
  end
  RS-->>Client: response
```

Local validation is fast but does not see revocations until the token
expires. Introspection does see them.

## Deployment diagram

```mermaid
flowchart TB
  subgraph CF[SAP BTP — Cloud Foundry space]
    AR[oauth-approuter\nNode.js · @sap/approuter\nresources/ = frontend]
    SRV[oauth-srv\nbinary buildpack\nuim-oauth-platform-service + uim-oauth-cli]
    X[(oauth-xsuaa\nxsuaa / application)]
    UPS[(oauth-config\nuser-provided:\nsigningSecret, issuer)]
    DISK[(container disk\ndata/oauth.json)]
  end
  Browser --> AR
  AR -->|destination oauth-srv\nforwardAuthToken| SRV
  AR --- X
  SRV --- X
  SRV --- UPS
  SRV --- DISK

  subgraph K8S[Kubernetes — namespace uim-platform]
    DEP[Deployment uim-oauth\nreplicas 1 · Recreate · read-only rootfs]
    CM[ConfigMap uim-oauth-config]
    SECRET[Secret uim-oauth-signing]
    VOL[(volume /data)]
    SVC[Service uim-oauth :8114]
  end
  SVC --> DEP
  CM --> DEP
  SECRET --> DEP
  DEP --- VOL
```
