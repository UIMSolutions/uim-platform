# UIM OAuth 2.0 Service

An OAuth 2.0 authorization server for the UIM platform, modelled on the **SAP
BTP OAuth 2.0 service**. It registers clients and scopes, runs the
authorization code flow (with PKCE), the client credentials flow and refresh
token rotation, and issues signed JWT access tokens. It also provides token
introspection and revocation, and login page branding.

| Layer | Technology |
| --- | --- |
| Backend | D, vibe.d 0.10.3, hexagonal / Clean Architecture ([backend/](backend/)) |
| Protocol | OAuth 2.0 endpoints under `/oauth` (RFC 6749, 7636, 7662, 7009, 8414) |
| Management APIs | OData v4 for SAP Fiori (`/odata/v4/oauth`), REST/JSON (`/api/v1/oauth`) |
| Admin tools | Command line interface (`uim-oauth-cli`), GtkD 3 desktop GUI (`uim-oauth-gui`) |
| Frontend | SAP Fiori 3 / UI5 1.120 ([frontend/](frontend/)) |
| Cloud | SAP BTP Cloud Foundry: approuter + XSUAA ([approuter/](approuter/)), [mta.yaml](mta.yaml); Kubernetes ([k8s/](k8s/)) |

The four management adapters (OData, REST, CLI and GUI) all run through **one
EDM model and one `ODataEngine`** from `uim-platform:service`. Validation,
scopes, `$filter`/`$orderby`/`$search` and error handling are therefore the
same everywhere. The protocol endpoints call the protocol ports directly.

---

## What the service does

| Resource | Purpose |
| --- | --- |
| **OAuth clients** | Confidential clients (server apps, services) or public clients (SPA, native apps). Each client has exact-match redirect URIs, allowed scopes, grant types, token lifetimes, contacts and an optional branding. The secret is **generated** and returned **once** (on create or rotate). It is stored only as a salted SHA-256 hash. |
| **Scopes** | Scope values (`orders.read`), grouped by the application that checks them. Only active scopes are granted. A scope cannot be deleted while a client is still allowed to request it. |
| **Access tokens** | HS256 JWTs. The server stores a record with the `jti`, a hash of the token, the client, user, scopes, grant and status. The token itself is never stored. |
| **Refresh tokens** | Opaque random values, stored only as a hash. They are **rotated on every use** and keep the original scope ceiling and absolute lifetime. |
| **Authorization codes** | Single use, bound to the client, the redirect URI and an optional PKCE challenge. They are valid for 5 minutes by default. |
| **Brandings** | Logo, background image, colors, page title, footer and custom CSS for the login page. There is one default per tenant, and a client can use its own branding. |

### Security rules (enforced in the domain and application layers)

- **Supported grants:** `authorization_code`, `client_credentials` and `refresh_token`. The implicit and password grants are not offered (OAuth 2.0 Security BCP / OAuth 2.1).
- **Public clients:** must use PKCE (`S256` or `plain`) and cannot use `client_credentials`.
- **Redirect URIs:** absolute, matched exactly, no fragments or wildcards. They must use `https`. Plain `http` is allowed only for loopback hosts. Native apps can use private-use schemes (`com.example.app:/cb`). Unregistered URIs are **never** redirected to.
- **Replay detection:** if a used authorization code or an already rotated refresh token is presented again, every token issued from that grant is revoked.
- **Blocking a client** or **rotating its secret** revokes all of its tokens.
- **Tenants are isolated:** tokens, codes and clients are looked up only in the caller's tenant.
- **Secrets stay out of the APIs and the logs:** secret hashes, token hashes and PKCE challenges are never serialized. Neither secrets nor tokens are logged.
- **Random values** come from the kernel CSPRNG (`/dev/urandom`). The generator fails closed, with no fallback.

### Token format

Access tokens use the claim set of SAP XSUAA / UAA:

```json
{ "iss": "https://oauth.example.com", "jti": "…", "zid": "<tenant>", "client_id": "sb-portal", "cid": "sb-portal",
  "azp": "sb-portal", "sub": "jane", "user_id": "jane", "user_name": "jane",
  "scope": ["orders.read"], "grant_type": "authorization_code", "iat": 1794389782, "exp": 1794393382 }
```

`resolveRequestContext` in `uim-platform:service` reads exactly these claims.
Any platform service that has `jwtSecret` set to this service's signing
secret therefore accepts the tokens directly, including tenant, user and
scopes. An integration test covers this.

---

## Quick start

```bash
cd backend
dub build                                    # server
dub build --config=cli                       # command line interface
dub test                                     # unit + integration tests

# demo data (branding, 6 scopes, a service, a web and a native client); prints the secrets once
./build/uim-oauth-cli seed --data-file=data/oauth.json

./build/uim-oauth-platform-service           # http://localhost:8114
```

- Fiori app: <http://localhost:8114/app/index.html> (local development; on BTP the approuter serves it)
- OData metadata: <http://localhost:8114/odata/v4/oauth/$metadata>
- Discovery: <http://localhost:8114/.well-known/oauth-authorization-server>

`config/default.json` uses the file store `data/oauth.json`. The server, the
CLI and the GUI all work on that same file.

### Try the flows with curl

```bash
# client credentials (client_secret_basic)
curl -u sb-billing-service:<secret> -d grant_type=client_credentials -d scope=orders.read \
     http://localhost:8114/oauth/token

# introspect / revoke (confidential client)
curl -u sb-billing-service:<secret> -d token=<access_token> http://localhost:8114/oauth/introspect
curl -u sb-billing-service:<secret> -d token=<access_token> http://localhost:8114/oauth/revoke
```

For the authorization code flow, `/oauth/authorize` needs an authenticated
user. On BTP the approuter forwards the user's XSUAA token. For local tests
you can start the server with `OAUTH_TRUST_USER_HEADER=true` and send
`X-User-Id: jane`, or use the CLI (`authorize`), which does the same thing
after login:

```bash
./build/uim-oauth-cli pkce                                    # code_verifier + S256 challenge
./build/uim-oauth-cli authorize mobile-app --user=jane --scope="orders.read" --challenge=<challenge>
./build/uim-oauth-cli token mobile-app --grant=authorization_code --code=<code> --verifier=<verifier>
./build/uim-oauth-cli token mobile-app --grant=refresh_token --refresh-token=<refresh_token>
```

### Command line

```text
uim-oauth-cli sets | metadata                       model driven: every entity set and action
uim-oauth-cli list OAuthClients --filter="clientType eq 'public'" --orderby=name [--json|--csv]
uim-oauth-cli get|create|update|delete <Set> …       generic CRUD (create/update take --prop=value)
uim-oauth-cli invoke <Action> --param=value          any OData action
uim-oauth-cli stats                                  statistics of the tenant
uim-oauth-cli token <clientId> [--secret] [--grant] [--scope] [--code --redirect-uri --verifier] [--refresh-token]
uim-oauth-cli authorize <clientId> --user=U [--scope] [--challenge [--method]] [--state]
uim-oauth-cli pkce                                   generate code_verifier / code_challenge
uim-oauth-cli introspect|revoke <token> [--hint=access_token|refresh_token]
uim-oauth-cli rotate-secret <clientKey> --yes        new secret, revokes the client's tokens
uim-oauth-cli revoke-client <clientKey>              revoke all tokens and codes of a client
uim-oauth-cli purge                                  remove expired / revoked tokens and codes
uim-oauth-cli seed | config
global: --tenant=<id> --storage=memory|file --data-file=<path> --config-dir=<dir>
```

### Desktop GUI (GtkD)

```bash
dub build --config=gui            # needs GTK 3.24
./build/uim-oauth-gui --data-file=data/oauth.json [--tenant=default] [--refresh=5]
```

The GUI is the model-driven entity browser of `uim-platform:service`. It has
one page per entity set with search and `$filter`, create/edit/delete forms
generated from the EDM types, the Statistics sheet, and a runner for all
actions (rotate secret, revoke, test client credentials, introspect, purge).

---

## APIs

### OAuth 2.0 protocol — `/oauth`

| Endpoint | Standard | Notes |
| --- | --- | --- |
| `GET/POST /oauth/authorize` | RFC 6749 §4.1, RFC 7636, RFC 9207 | `response_type=code`. Replies with `302` to `redirect_uri?code=&state=&iss=`. Errors after the redirect URI is validated go back as `error=`. Errors before that are a `400` JSON response. |
| `POST /oauth/token` | RFC 6749 §3.2 | Form-encoded. Client authentication: `client_secret_basic`, `client_secret_post` or `none` (public). A failed Basic authentication returns `401` with `WWW-Authenticate`. Responses are sent with `Cache-Control: no-store`. |
| `POST /oauth/introspect` | RFC 7662 | Only for confidential clients. An inactive token returns only `{"active": false}`. |
| `POST /oauth/revoke` | RFC 7009 | A client can revoke only its own tokens. Unknown tokens also return `200`. Revoking a refresh token also revokes its access tokens. |
| `GET /oauth/branding?client_id=` | — | Login page branding: the client's own, or the default. |
| `GET /.well-known/oauth-authorization-server` | RFC 8414 | Endpoints, grants, auth methods, PKCE methods and the active scopes of the tenant. |

The tenant comes from the `zid` claim of the user token, from the
`X-Tenant-Id` header, or from `defaultTenant`.

### OData v4 — `/odata/v4/oauth`

| Entity set | Operations | Notes |
| --- | --- | --- |
| `OAuthClients` | CRUD | `clientSecret` is filled only in the create response. `hasSecret`, `secretRotatedAt` and `activeTokens` are computed. `clientId` and `clientType` cannot be changed after creation. |
| `OAuthScopes` | CRUD | `clientCount` is computed |
| `AccessTokens`, `RefreshTokens`, `AuthorizationCodes` | read, delete | The status takes expiry into account. Values and hashes are never exposed. |
| `BrandingConfigs` | CRUD | `isDefault` is unique per tenant |
| `Statistics` (singleton) | read | Clients, tokens by status, pending codes, scopes, brandings |

Actions: `RotateClientSecret(id)`, `RevokeClientTokens(id)`,
`RevokeAccessToken(id)`, `RevokeRefreshToken(id)`,
`RequestClientToken(clientId, clientSecret, scope)` (to test a client from
the UI), `IntrospectToken(token, tokenTypeHint)` and `PurgeExpired()`.
`$metadata` contains the Fiori UI annotations (`HeaderInfo`, `LineItem`,
`SelectionFields`), Core annotations (`Computed`, `Immutable`) and
Capabilities annotations. `$batch` is supported.

Scopes with XSUAA: `Read` for all reads, and `Manage` for all writes and
actions.

### REST — `/api/v1/oauth`

`clients`, `scopes`, `access-tokens`, `refresh-tokens`,
`authorization-codes` and `brandings` support `GET` (with `filter`,
`orderby`, `select`, `search`, `top` and `skip`), `POST`, `GET/PUT/PATCH/DELETE /:id`.
There are also `GET /statistics`, `POST /clients/:id/rotate-secret`,
`POST /clients/:id/revoke-tokens`, `POST /access-tokens/:id/revoke`,
`POST /refresh-tokens/:id/revoke`, `POST /introspect` and `POST /purge`.
Errors are returned as `{"error": {"code", "message"}}`.

---

## Configuration

Precedence (lowest to highest): built-in defaults → `config/default.json` →
`config/<UIM_PROFILE>.json` → `OAUTH_*` environment variables → Cloud Foundry
(`PORT`, `VCAP_APPLICATION`, credentials of the user-provided service
`oauth-config`) → CLI/GUI options.

| Key (env) | Default | Meaning |
| --- | --- | --- |
| `port` (`OAUTH_PORT`) | 8114 | HTTP port |
| `storage` (`OAUTH_STORAGE`) | memory (`file` in default.json) | `memory` or `file` |
| `dataFile` (`OAUTH_DATA_FILE`) | data/oauth.json | JSON snapshot shared by the server, CLI and GUI |
| `issuer` (`OAUTH_ISSUER`) | publicUrl or `http://localhost:<port>` | `iss` of the tokens and base of the metadata URLs |
| `signingSecret` (`OAUTH_SIGNING_SECRET`) | — | HS256 key, at least 32 characters. **Set it in production.** If it is empty, a key is generated once and kept in the store (partition `_system`). |
| `authorizationCodeValiditySeconds` | 300 | 30–600 |
| `trustUserHeader` (`OAUTH_TRUST_USER_HEADER`) | false | **Development only:** `/authorize` accepts the user from `X-User-Id` |
| `purgeIntervalSeconds` / `purgeTenants` | 0 (3600 in default.json) / `["default"]` | Background cleanup of expired tokens and codes |
| `requireAuthentication` / `jwtSecret` | false / — | Protects the management APIs with HS256 when there is no XSUAA binding |
| `restPath` / `odataPath` / `oauthPath` | `/api/v1/oauth` / `/odata/v4/oauth` / `/oauth` | must differ |
| `frontendDir` | ../frontend | Serves the Fiori app under `/app` ("" when deployed behind the approuter) |

**Security modes of the management APIs:** with an XSUAA binding, RS256
tokens are required and scopes are enforced. With `requireAuthentication` and
`jwtSecret`, HS256 tokens are required. Otherwise the APIs are open, which is
meant for local development only, and the tenant comes from `X-Tenant-Id`.
`GET /health` shows the active mode and where the signing key came from.

---

## Deployment

```bash
# SAP BTP Cloud Foundry (approuter + XSUAA + backend)
mbt build && cf deploy mta_archives/uim-oauth_2.0.0.mtar
cf update-user-provided-service oauth-config -p '{"signingSecret":"<48+ random chars>","issuer":"https://<route>"}'

# Local approuter (copy and fill in approuter/default-env.json — never committed)
cd approuter && npm install && npm start

# Container (build context = repository root)
docker build -f oauth/backend/Dockerfile -t uim-platform/oauth .
kubectl -n uim-platform create secret generic uim-oauth-signing --from-literal=OAUTH_SIGNING_SECRET="$(openssl rand -base64 48)"
kubectl apply -f oauth/k8s/
```

The file store supports **a single instance only** (`replicas: 1`,
`Recreate`). Running more instances needs a database adapter for
`IDocumentStore`.

---

## Layout

```text
oauth/
├── mta.yaml                     MTA: backend + approuter + XSUAA + oauth-config
├── approuter/                   xs-app.json (routes), xs-security.json (Read/Manage), default-env.json (local, ignored)
├── frontend/                    Fiori 3 app: view/ controller/ fragment/ model/ i18n/ (en, de) localService/ test/
├── k8s/                         ConfigMap, Deployment, Service
└── backend/
    ├── dub.sdl                  configurations: defaultRun (server), cli, gui, defaultTest
    ├── config/default.json
    ├── tests/oauth_flows.d      integration tests (flows, replay, tenants, file store)
    └── source/
        ├── app.d  cli.d  gui.d  entry points
        └── uim/platform/oauth/
            ├── domain/          entities, types (ids, time, scopes, uris, colors), enumerations,
            │                    services (credentials/PKCE, scope policy, token claims), exceptions
            ├── ports/           usecases (manage_*, oauth_protocol), repositories, storages,
            │                    gateways (ITokenSigner, ISecretGenerator), services, messaging
            ├── application/     usecases (clients, scopes, brandings, tokens, authenticate,
            │                    authorize, issue_tokens, introspect_tokens), services, dtos
            ├── persistence/     repositories (document store), mappers, records, storages
            ├── infrastructure/  configuration, security (XSUAA/HS256, signer, CSPRNG, signing key),
            │                    logging, workers (expiry purge), container (composition root)
            └── presentation/    odata (model, engine, payloads, serializers, errors),
                                 http (protocol, rest, health), cli, gui, web, rest, unix
```

See [UML.md](UML.md) for the diagrams and [NAFv4.md](NAFv4.md) for the
architecture description.
