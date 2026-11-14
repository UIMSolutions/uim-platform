# Identity Authentication Service

A D / vibe.d 0.10 service in the style of **SAP Cloud Identity Services – Authentication (IAS)**:
form login with account lockout, risk-based multi-factor authentication, OAuth 2.0 / OIDC
tokens, authorization policies, corporate identity providers, and administration of users,
groups, applications, sessions and tokens.

It has five driving adapters on the same hexagonal core:

| Adapter | Entry point | Purpose |
|---|---|---|
| REST + OAuth / OIDC | `backend/source/app.d` → `/api/v1/…` | login, token, refresh, introspection, revocation, userinfo, administration |
| vibe.d REST interface | `/rest/v1/identity-authentication/users` | typed `registerRestInterface` API |
| **OData v4** | `/odata/v4/identity-authentication` | SAP Fiori 3 UI, `$metadata`, `$filter/$orderby/$select/$top/$skip/$count/$search`, actions |
| **CLI** | `backend/source/cli.d` → `uim-ias-cli` | administration and end-to-end flow tests from the shell |
| **GtkD GUI** | `backend/source/gui.d` → `uim-ias-gui` | desktop administration client (GTK 3) |

Server, CLI and GUI share data through the snapshot storage (`backend/data/*.json`), so a user
created in the CLI appears in the Fiori app and the GUI.

## Layout

```
identity-authentication/
├── mta.yaml                      MTA: backend + approuter + XSUAA + config service
├── backend/                      D / vibe.d (dub package "identity-authentication")
│   ├── config/default.json       defaults (overridden by IAS_* env vars, then VCAP_SERVICES)
│   ├── Dockerfile, Containerfile
│   └── source/
│       ├── app.d  cli.d  gui.d   entry points (one dub configuration each)
│       └── uim/platform/identity_authentication/
│           ├── domain/           entities, types (ids), enumerations, services, exceptions
│           ├── ports/            usecases (driving), services, repositories, storages,
│           │                     messaging, gateways (password, secrets, token, MFA, OTP)
│           ├── application/      usecases, services (statistics), dtos
│           ├── persistence/      repositories, storages (memory / JSON file), mappers, records
│           ├── infrastructure/   configuration, logging, security (PBKDF2, JWT, TOTP),
│           │                     clients (OTP webhook), workers (expiry cleanup), container
│           └── presentation/     http, rest, odata, web, cli, gui
├── frontend/                     SAP Fiori 3 / UI5 app (uim.ias)
└── approuter/                    @sap/approuter, xs-app.json, xs-security.json
```

`backlog/` holds the old tenant-management draft. It is not compiled and is unchanged.

## Build and run

```bash
cd backend
dub build                      # server   → build/uim-identity-authentication-platform-service
dub build --config=cli         # CLI      → build/uim-ias-cli
dub build --config=gui         # GtkD GUI → build/uim-ias-gui   (needs GTK 3.24)
dub test  --config=defaultTest # unit + end-to-end tests (53 modules)

IAS_JWT_SECRET=$(openssl rand -hex 32) ./build/uim-identity-authentication-platform-service
# → http://localhost:8125/index.html   (Fiori app served from ../frontend for local development)
```

The default port is now **8125** (previously 8080, which other services already use).

### CLI quick tour

```bash
C=./build/uim-ias-cli
$C users create --email=jane@example.com --password=Secret123 --first-name=Jane
$C groups create --name=admins && $C groups add-member <groupId> jane
$C apps create --name=Portal --scopes=openid,profile      # prints the client secret once
$C policies create --name="Admins only" --rules="group:in:admins"
$C login --email=jane@example.com --password=Secret123     # → session id
$C token --session=<id> --client-id=<cid> --client-secret=<secret> --scopes=openid
$C introspect <access token>
$C users mfa jane totp                                      # prints secret + otpauth:// URI
$C stats --json
$C help                                                     # all commands
```

Global options: `--tenant`, `--as` (acting user), `--data-dir`, `--storage=memory`, `--json`.
Exit codes: 0 ok, 1 failure, 2 usage error.

## Authentication flows

| Endpoint | Description |
|---|---|
| `POST /api/v1/auth/login` | `{"email" or "userName", "password", "mfaCode"?}` → session. 401 bad credentials or MFA required, 403 denied by risk rule, 423 locked |
| `POST /api/v1/auth/token` | `grant_type=session` (session → tokens) or `refresh_token`; JSON or form body; client auth in the body or via HTTP Basic |
| `POST /api/v1/auth/refresh` | refresh with **rotation**; reusing a rotated refresh token revokes the whole session |
| `POST /api/v1/auth/introspect` | RFC 7662 |
| `POST /api/v1/auth/revoke` | RFC 7009 |
| `GET /api/v1/auth/userinfo` | OIDC userinfo for a bearer access token |
| `POST /api/v1/auth/logout` | revokes the session and all its tokens |
| `GET /.well-known/openid-configuration` | discovery document |

Login pipeline: user lookup (unknown users cost the same time) → status check → password →
risk rules (may deny or demand a second factor) → one-time code (SMS / e-mail codes are sent
on demand) → session. Failed passwords and codes count towards the lockout
(`maxFailedLogins`, default 5).

Token issuance checks the session, the client secret, the requested scopes against the
application's allowed scopes, and every **authorization policy** assigned to the application.

## Administration API (REST)

All under `/api/v1`. The tenant comes from the bearer token, `X-Tenant-Id`, or the default tenant.

| Resource | Endpoints |
|---|---|
| users | CRUD, `/:id/status`, `/:id/password`, `/:id/reset-password`, `/:id/mfa` (POST / DELETE), `/:id/sessions` |
| groups | CRUD, `/:id/members` (GET / POST), `/:id/members/:userId` (DELETE) |
| applications | CRUD, `/:id/rotate-secret` |
| policies | CRUD, `/evaluate` |
| risk-rules | CRUD, `/assess` |
| identity-providers | CRUD, `/resolve?email=&redirectUri=` |
| sessions, tokens | list / get / DELETE (= revoke), `/purge` |
| statistics | tenant figures |

The old routes `POST /users/change-password` and `POST /groups/members` still work.

## OData v4

Entity sets `Users`, `Groups`, `Applications`, `Policies`, `RiskRules`, `IdentityProviders`,
`Sessions` and `Tokens` (DELETE = revoke), the singleton `Statistics`, and the actions
`SetUserStatus`, `ResetPassword`, `EnrollMfa`, `DisableMfa`, `RevokeUserSessions`,
`AddGroupMember`, `RemoveGroupMember`, `RotateClientSecret`, `EvaluateAccess`, `AssessRisk`
and `PurgeExpired`. `$batch` is not supported (the UI5 model uses `groupId: "$direct"`).
Password hashes, MFA seeds, client-secret hashes and token values are never part of the model.

## Security notes

- Passwords: PBKDF2-HMAC-SHA256 with a random 16-byte salt; the iteration count is stored in the hash.
- Tokens: HS256 JWTs (only `HS256` is accepted on verification), stored **only as SHA-256
  fingerprints**, so revocation and introspection work without keeping bearer secrets.
- Client secrets: random 256 bit, returned once, stored as a fingerprint.
- MFA: RFC 6238 TOTP (30 s for authenticator apps, 5 min for SMS / e-mail codes, ±1 step drift).
- **Set `IAS_JWT_SECRET`** (≥ 16 characters) outside development; the service warns at startup
  while the built-in default is in use.
- The snapshot files contain password hashes and MFA seeds, so protect `dataDir`. On Cloud Foundry
  the container disk is ephemeral; bind persistent storage for production data.
- Administration requests trust XSUAA tokens forwarded by the approuter without verifying the
  XSUAA signature. Expose the backend only behind the approuter, or add XSUAA verification.
- TOTP codes are not yet protected against replay within their time window.

## Configuration

Precedence: `config/default.json` → environment variables → `VCAP_SERVICES` (service
`identity-authentication-config`).

| Variable | Default | Description |
|---|---|---|
| `IAS_HOST` / `IAS_PORT` (`PORT`) | `0.0.0.0` / `8125` | bind address |
| `IAS_STORAGE` / `IAS_DATA_DIR` | `file` / `data` | `memory` or JSON snapshots |
| `IAS_JWT_SECRET` | development default | token signing secret |
| `IAS_ISSUER` | `uim-identity-authentication` | `iss` claim and TOTP issuer |
| `IAS_SESSION_TIMEOUT` | `480` | session lifetime (minutes) |
| `IAS_ACCESS_TOKEN_MINUTES` / `IAS_REFRESH_TOKEN_HOURS` | `60` / `24` | token lifetimes |
| `IAS_MAX_FAILED_LOGINS` | `5` | lockout threshold (0 = off) |
| `IAS_PASSWORD_ITERATIONS` | `60000` | PBKDF2 iterations for new hashes |
| `IAS_OTP_WEBHOOK_URL` | — | POST target for SMS / e-mail codes (otherwise logged) |
| `IAS_CLEANUP_INTERVAL` / `IAS_CLEANUP_TENANTS` | `30` / `default` | purge expired sessions and tokens |
| `IAS_FRONTEND_DIR` | `../frontend` | serve the Fiori app locally (`""` = off) |
| `IAS_CONFIG_FILE` | — | alternative config file |

## Deployment (SAP BTP, Cloud Foundry)

```bash
cf create-user-provided-service identity-authentication-config -p '{"jwtSecret":"<random>"}'
mbt build && cf deploy mta_archives/uim-identity-authentication_1.0.0.mtar
```

The approuter protects administration with the `IdentityViewer` / `IdentityAdmin` scopes. It
leaves `/api/v1/auth/*` public because those endpoints authenticate users and clients themselves.
See [approuter/README.md](approuter/README.md) for running it locally.

## License

See the repository root [LICENSE](../LICENSE) file.
