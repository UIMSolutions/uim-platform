# Customer Identity Service

SAP Customer Identity and Access Management (CIAM) for B2C — microservice platform implementation.

This service provides a complete customer identity lifecycle management solution based on SAP Customer Data Cloud capabilities, including registration, authentication, social login, federation, consent management, audit logging, screen sets, and site policies.

## Features

- **Customer Registration & Login** — Email/password registration with customizable flows and progressive profiling
- **Social Login** — Google, Facebook, Apple, Twitter, LinkedIn OAuth2/OIDC integration
- **Single Sign-On (SSO)** — Cross-site SSO with session management and token federation
- **SAML/OIDC Federation** — Enterprise identity provider integration via SAML 2.0 and OpenID Connect
- **Consent Management** — GDPR/CCPA compliant consent recording, versioning, and revocation
- **Audit Logging** — Immutable event trail for all identity-related operations
- **Screen Sets** — Configurable UI flows for registration, login, profile update, password reset
- **Site Policies** — Password complexity, MFA, session timeout, lockout, CAPTCHA rules
- **Account Linking** — Link multiple social identities to a single customer account
- **Progressive Profiling** — Incremental data collection across sessions

## Architecture

Hexagonal (clean) architecture with 4 layers:

```
Domain → Application → Presentation → Infrastructure
```

- **Domain**: Entities, value objects, repository interfaces, domain services
- **Application**: Use cases, DTOs, application services
- **Presentation**: HTTP REST controllers (vibe.d), CLI, Web, GUI stubs
- **Infrastructure**: In-memory persistence, config, DI container

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/customer-identity/customers` | List customers |
| POST | `/api/v1/customer-identity/customers` | Register customer |
| GET | `/api/v1/customer-identity/customers/:id` | Get customer |
| PUT | `/api/v1/customer-identity/customers/:id` | Update customer |
| DELETE | `/api/v1/customer-identity/customers/:id` | Delete customer |
| GET | `/api/v1/customer-identity/sessions` | List sessions |
| POST | `/api/v1/customer-identity/sessions` | Create session |
| GET | `/api/v1/customer-identity/sessions/:id` | Get session |
| DELETE | `/api/v1/customer-identity/sessions/:id` | Revoke session |
| GET | `/api/v1/customer-identity/social-identities` | List social identities |
| POST | `/api/v1/customer-identity/social-identities` | Link social identity |
| GET | `/api/v1/customer-identity/social-identities/:id` | Get social identity |
| PUT | `/api/v1/customer-identity/social-identities/:id` | Unlink social identity |
| DELETE | `/api/v1/customer-identity/social-identities/:id` | Delete social identity |
| GET | `/api/v1/customer-identity/consents` | List consent records |
| POST | `/api/v1/customer-identity/consents` | Grant consent |
| GET | `/api/v1/customer-identity/consents/:id` | Get consent record |
| PUT | `/api/v1/customer-identity/consents/:id` | Revoke consent |
| DELETE | `/api/v1/customer-identity/consents/:id` | Delete consent record |
| GET | `/api/v1/customer-identity/audit-logs` | List audit logs |
| POST | `/api/v1/customer-identity/audit-logs` | Record audit event |
| GET | `/api/v1/customer-identity/audit-logs/:id` | Get audit log |
| DELETE | `/api/v1/customer-identity/audit-logs/:id` | Delete audit log |
| GET | `/api/v1/customer-identity/identity-providers` | List identity providers |
| POST | `/api/v1/customer-identity/identity-providers` | Create identity provider |
| GET | `/api/v1/customer-identity/identity-providers/:id` | Get identity provider |
| PUT | `/api/v1/customer-identity/identity-providers/:id` | Update identity provider |
| DELETE | `/api/v1/customer-identity/identity-providers/:id` | Delete identity provider |
| GET | `/api/v1/customer-identity/screen-sets` | List screen sets |
| POST | `/api/v1/customer-identity/screen-sets` | Create screen set |
| GET | `/api/v1/customer-identity/screen-sets/:id` | Get screen set |
| PUT | `/api/v1/customer-identity/screen-sets/:id` | Update screen set |
| DELETE | `/api/v1/customer-identity/screen-sets/:id` | Delete screen set |
| GET | `/api/v1/customer-identity/policies` | List site policies |
| POST | `/api/v1/customer-identity/policies` | Create site policy |
| GET | `/api/v1/customer-identity/policies/:id` | Get site policy |
| PUT | `/api/v1/customer-identity/policies/:id` | Update site policy |
| DELETE | `/api/v1/customer-identity/policies/:id` | Delete site policy |
| GET | `/health` | Health check |

## Configuration

| Environment Variable | Default | Description |
|----------------------|---------|-------------|
| `CUSTOMER_IDENTITY_HOST` | `0.0.0.0` | Bind address |
| `CUSTOMER_IDENTITY_PORT` | `8119` | Listen port |

## Running

### Local (DUB)

```bash
cd customer-identity
dub run
```

### Docker

```bash
docker build -t uim-customer-identity-platform-service .
docker run -p 8119:8119 uim-customer-identity-platform-service
```

### Podman

```bash
podman build -t uim-customer-identity-platform-service -f Containerfile .
podman run -p 8119:8119 uim-customer-identity-platform-service
```

### Kubernetes

```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

## Testing

```bash
cd customer-identity
dub test
```

## Dependencies

- [vibe.d](https://vibed.org/) — HTTP server framework
- [uim-platform:service](../source/) — Shared platform base classes
