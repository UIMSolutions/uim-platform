# OAuth 2.0 Service

A microservice providing OAuth 2.0 authorization capabilities similar to **SAP OAuth 2.0 on SAP BTP**. Built with D and vibe.d using a combination of clean and hexagonal architecture. Enables OAuth client registration, authorization code and client credentials grant flows, access and refresh token management, scope-based authorization, token revocation, and corporate branding customization for authorization pages.

## Features

- **OAuth Client Management** -- Register and manage OAuth 2.0 clients (confidential and public types) with configurable redirect URIs, allowed scopes, grant types, and token validity periods
- **OAuth Scope Management** -- Define and manage fine-grained authorization scopes per application with status tracking and tenant isolation
- **Access Token Management** -- Issue, validate, and revoke bearer access tokens with configurable expiration, client and user association, and scope restrictions
- **Refresh Token Management** -- Issue and manage refresh tokens for long-lived sessions with revocation support and access token association
- **Authorization Code Management** -- Generate and manage authorization codes for the authorization code grant flow with single-use enforcement, redirect URI binding, and expiration
- **Branding Configuration** -- Customize the authorization page appearance with logos, background images, colors, page titles, footer text, and custom CSS per tenant

## Architecture

```
+-----------------------------------------------------+
|                  Presentation Layer                  |
|  OAuthClientController  OAuthScopeController        |
|  AccessTokenController  RefreshTokenController      |
|  AuthorizationCodeController                        |
|  BrandingConfigController                           |
+-----------------------------------------------------+
|                  Application Layer                   |
|  ManageOAuthClientsUseCase                          |
|  ManageOAuthScopesUseCase                           |
|  ManageAccessTokensUseCase                          |
|  ManageRefreshTokensUseCase                         |
|  ManageAuthorizationCodesUseCase                    |
|  ManageBrandingConfigsUseCase                       |
+-----------------------------------------------------+
|                   Domain Layer                       |
|  Entities  Repository Interfaces  OAuthValidator    |
+-----------------------------------------------------+
|                Infrastructure Layer                  |
|  MemoryRepositories  AppConfig  Container           |
+-----------------------------------------------------+
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/health` | Health check |
| **OAuth Clients** | | |
| GET | `/api/v1/oauth/clients` | List all OAuth clients |
| GET | `/api/v1/oauth/clients/{id}` | Get OAuth client by ID |
| POST | `/api/v1/oauth/clients` | Register OAuth client |
| PUT | `/api/v1/oauth/clients/{id}` | Update OAuth client |
| DELETE | `/api/v1/oauth/clients/{id}` | Delete OAuth client |
| **OAuth Scopes** | | |
| GET | `/api/v1/oauth/scopes` | List all scopes |
| GET | `/api/v1/oauth/scopes/{id}` | Get scope by ID |
| POST | `/api/v1/oauth/scopes` | Create scope |
| PUT | `/api/v1/oauth/scopes/{id}` | Update scope |
| DELETE | `/api/v1/oauth/scopes/{id}` | Delete scope |
| **Access Tokens** | | |
| GET | `/api/v1/oauth/access-tokens` | List all access tokens |
| GET | `/api/v1/oauth/access-tokens/{id}` | Get access token by ID |
| POST | `/api/v1/oauth/access-tokens` | Issue access token |
| POST | `/api/v1/oauth/access-tokens/revoke/{id}` | Revoke access token |
| DELETE | `/api/v1/oauth/access-tokens/{id}` | Delete access token |
| **Refresh Tokens** | | |
| GET | `/api/v1/oauth/refresh-tokens` | List all refresh tokens |
| GET | `/api/v1/oauth/refresh-tokens/{id}` | Get refresh token by ID |
| POST | `/api/v1/oauth/refresh-tokens` | Issue refresh token |
| POST | `/api/v1/oauth/refresh-tokens/revoke/{id}` | Revoke refresh token |
| DELETE | `/api/v1/oauth/refresh-tokens/{id}` | Delete refresh token |
| **Authorization Codes** | | |
| GET | `/api/v1/oauth/authorization-codes` | List all authorization codes |
| GET | `/api/v1/oauth/authorization-codes/{id}` | Get authorization code by ID |
| POST | `/api/v1/oauth/authorization-codes` | Generate authorization code |
| POST | `/api/v1/oauth/authorization-codes/use/{id}` | Mark code as used |
| DELETE | `/api/v1/oauth/authorization-codes/{id}` | Delete authorization code |
| **Branding Configs** | | |
| GET | `/api/v1/oauth/branding-configs` | List all branding configs |
| GET | `/api/v1/oauth/branding-configs/{id}` | Get branding config by ID |
| POST | `/api/v1/oauth/branding-configs` | Create branding config |
| PUT | `/api/v1/oauth/branding-configs/{id}` | Update branding config |
| DELETE | `/api/v1/oauth/branding-configs/{id}` | Delete branding config |

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `OAUTH_HOST` | `0.0.0.0` | Server bind address |
| `OAUTH_PORT` | `8114` | Server listen port |

## Build and Run

### Local

```bash
dub build
./uim-oauth-platform-service
```

### Docker

```bash
docker build -t uim-oauth .
docker run -p 8114:8114 uim-oauth
```

### Podman

```bash
podman build -t uim-oauth -f Containerfile .
podman run -p 8114:8114 uim-oauth
```

### Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Testing

```bash
dub test
```

## License

See the repository root [LICENSE](../LICENSE) file.
