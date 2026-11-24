# UIM Data Quality

Data quality management in the style of SAP Data Quality Management: keep
datasets of records, check them against configurable rules, profile their
fields, find duplicates and merge them into golden records, cleanse values
and postal addresses, and follow the quality of every dataset in a
scorecard with a trend.

| Part | Technology | Folder |
|---|---|---|
| Backend | D, uim-framework 26.11, vibe.d 0.10.x, hexagonal / clean architecture | [backend/](backend/) |
| Frontend | SAP Fiori 3, OpenUI5 1.120 (XML views, OData V4 model) | [frontend/](frontend/) |
| Approuter | `@sap/approuter` with XSUAA | [approuter/](approuter/) |
| Deployment | MTA for SAP BTP / Cloud Foundry, Docker/Podman, Kubernetes | [mta.yaml](mta.yaml), [backend/Dockerfile](backend/Dockerfile), [k8s/](k8s/) |

More documentation: [UML.md](UML.md) (diagrams) and [NAFv4.md](NAFv4.md)
(architecture description).

## Features

| Capability | What it does |
|---|---|
| **Datasets and records** | Named datasets (e.g. `customers`, reference data such as `countries`) with records of `name=value` fields. Import from CSV (`,` `;` or tab, RFC 4180 quoting) or JSON in one storage batch. |
| **Validation rules** | Nine rule types — required, format (regex), numeric range, text length, allowed values, compare with another field, expressions (`country == DE => postalCode matches ^[0-9]{5}$`), reference data lookup, unique in dataset. Severity (info … critical), status (draft/active/inactive), priority, dataset pattern (`cust*`). |
| **Validation** | Records are validated when they are created or changed; whole datasets on demand. Every violation names record, field, value, rule, message and — where possible — a suggestion (closest allowed value, bound of a range, value of the compared field). |
| **Profiling** | Per field: detected type (integer, decimal, date, email, phone, boolean, text, mixed), completeness, distinct and repeated values, numeric or lexical min/max, mean, lengths, top values and value patterns (`Aa99`). |
| **Duplicate detection** | Exact, fuzzy (Jaro-Winkler), phonetic (Soundex) and composite matching over any fields, with a threshold. Values are compared without case, accents and punctuation; empty records never match. |
| **Golden records** | Resolve a match group by choosing the surviving record; optionally merge — empty fields of the survivor are filled from the duplicates, which are then deleted. |
| **Cleansing** | Rules per field: trim, collapse blanks, upper/lower/title case, remove diacritics, regex replace, default value, remove field, country name → ISO code, enrich from reference data. Jobs apply them to a dataset (also as dry run), log every change and revalidate. |
| **Address cleansing** | Country names in English/German/French/local spelling → ISO 3166 alpha-2, title cased city/region, postal codes normalized and checked against the format of ~30 countries, street abbreviations expanded (`Hauptstr.` → `Hauptstraße`, `Ave` → `Avenue`). Result quality: verified, corrected, partial, invalid, unverifiable. |
| **Scorecards and trend** | Five dimensions — completeness 25 %, validity 30 %, uniqueness 20 %, consistency 15 %, accuracy 10 % — give the quality score and rating (excellent ≥ 95, good ≥ 80, fair ≥ 60, poor ≥ 40, critical). A snapshot is stored after every validation run. |
| **Login and JWT** | Built-in login with user accounts (PBKDF2-SHA256 hashes, lockout after failed attempts) issuing HS256 JWTs; on SAP BTP the XSUAA tokens of the approuter (RS256). Scopes `Read`, `Manage`, `Admin`. |
| **Adapters** | REST API, OData V4 with Fiori annotations, CLI and a GtkD desktop browser — all on the same driving ports. |

### How a dimension is scored

A dimension score is the share of records without a violation (warning or
worse) of a rule of that dimension:

| Dimension | Rule types | Additional measure |
|---|---|---|
| Completeness | required | mean completeness of the profiled fields (averaged with the rule result) |
| Validity | format, range, length, enumeration | — |
| Uniqueness | unique | records that are open duplicates in a match group |
| Consistency | crossField, custom | — |
| Accuracy | referenceData | — |

A dimension without rules and without profile/duplicate data scores 100.

## Quick start (local)

Prerequisites: `dmd` or `ldc2`, `dub`. The backend depends on the shared
[`service`](../service) package of this repository (path dependency).

```bash
cd backend
dub build                     # server
dub build --config=cli        # command line tool

# demo content (3 datasets, 26 records, rules, addresses, duplicates)
./build/uim-data-quality-cli seed --data-file=data/data-quality.json

# server with the built-in login (config/default.json: authMode "jwt")
DQ_JWT_SECRET="$(openssl rand -base64 48)" DQ_ADMIN_PASSWORD="choose a password" \
  ./build/uim-data-quality-platform-service
```

Open <http://localhost:8086/app/index.html> and sign in as `admin`. Without
`DQ_ADMIN_PASSWORD` a random initial password is generated and written to
the log once (event "created the administrator of the built-in login").
Without `DQ_JWT_SECRET` a random secret is used and all tokens become
invalid when the process stops.

For development without login: `DQ_AUTH_MODE=open`.

The server, the CLI and the GUI can share one data file; the server reloads
it when it changes.

## Authentication and authorization

| Mode | When | How callers authenticate |
|---|---|---|
| `xsuaa` | an XSUAA service is bound (`VCAP_SERVICES`) — always wins | The approuter logs the user in and forwards the XSUAA token (RS256, verified with the binding's key). |
| `jwt` | `authMode: "jwt"` (or the legacy `requireAuthentication: true`) | `POST /auth/login` checks user name and password and returns an HS256 JWT; every other call needs `Authorization: Bearer <token>`. |
| `open` | `authMode: "open"` | Nothing; tenant from `X-Tenant-Id`, user from `X-User-Id`. Local development only. |

Scopes (XSUAA: `$XSAPPNAME.<scope>`):

| Scope | Allows |
|---|---|
| `Read` | reading everything except user accounts |
| `Manage` | changing data and rules, validation, profiling, duplicate detection, cleansing, imports |
| `Admin` | user accounts of the built-in login (`Users` entity set) |

Built-in login details:

- Passwords are stored as `pbkdf2-sha256$<iterations>$<salt>$<hash>` (16 byte
  random salt, 120 000 iterations by default; older hashes are upgraded on
  the next login). Minimum length 10 characters, not only digits.
- Unknown users and wrong passwords get the same answer
  ("Invalid user name or password") and take the same time.
- After `maxFailedLogins` (5) failures an account is locked for
  `lockSeconds` (900); administrators can also lock accounts permanently.
- The last unlocked administrator cannot be deleted, locked or lose `Admin`;
  nobody can delete or lock the own account.
- Tokens carry XSUAA compatible claims (`sub`, `user_id`, `user_name`, `zid`
  = tenant, `scope[]`, `iss`, `iat`, `exp`, `jti`) and live
  `tokenTtlSeconds` (3600). Logout is client side (the token is dropped).

```bash
# get a token
TOKEN=$(curl -s -X POST localhost:8086/auth/login -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"choose a password"}' | jq -r .access_token)
curl -H "Authorization: Bearer $TOKEN" localhost:8086/api/v1/datasets

# OAuth2 password grant style is accepted too
curl -X POST localhost:8086/auth/login -d 'username=admin&password=...'

# tokens for scripts without a password (trusted local CLI, same jwtSecret)
DQ_JWT_SECRET=... ./build/uim-data-quality-cli token admin
./build/uim-data-quality-cli passwd admin "a new password"
```

The Fiori app asks `GET /auth/config` whether a login is required, shows
the login dialog, keeps the token per browser tab (sessionStorage) and
sends it with every OData request. The user menu offers "Change Password"
and "Sign Out"; an expired token leads back to the login. Administrators
see the **Users** tab.

## Interfaces

### OData V4 — `/odata/v4/data-quality`

Entity sets: `Datasets`, `Records`, `ValidationRules`, `Violations`
(read only), `CleansingRules`, `CleansingJobs`, `MatchGroups`,
`ColumnProfiles` (read only), `Addresses`, `QualitySnapshots`, `Users`
(Admin), singleton `Statistics`. Resources of a dataset have the key
`<datasetId>~<id>`, e.g. `Records('customers~c-1001')`. `$filter`,
`$orderby`, `$select`, `$top`, `$skip`, `$count`, `$search` and `$batch`
are supported; `$metadata` carries the Fiori UI annotations.

Actions: `ValidateDataset`, `ValidateRecord`, `ProfileDataset`,
`DetectDuplicates`, `ResolveMatchGroup`, `ComputeScorecard`,
`TakeSnapshot`, `RunCleansingJob`, `CancelCleansingJob`, `ImportCsv`,
`SeedDemoData`.

```bash
curl -H "Authorization: Bearer $TOKEN" \
  "localhost:8086/odata/v4/data-quality/Violations?\$filter=datasetId eq 'customers' and severity eq 'critical'"
curl -X POST -H "Authorization: Bearer $TOKEN" -H 'Content-Type: application/json' \
  localhost:8086/odata/v4/data-quality/DetectDuplicates \
  -d '{"datasetId":"customers","matchFields":"name,city","strategy":"composite","threshold":85}'
```

### REST — `/api/v1`

Stateless services for integration plus dataset operations. A record is
`{"id": "...", "fields": {"name": "value"}}` (`fieldValues` and
`["name=value"]` are accepted as well).

| Method | Path | Purpose |
|---|---|---|
| GET | `/meta` | rule types, actions, strategies, dimension weights |
| POST | `/validate` | `{datasetId?, records}` — check records against the rules of a dataset, nothing stored |
| POST | `/profiles` | `{records}` — profile ad-hoc records |
| POST | `/duplicates/detect` | `{records, matchFields, strategy?, threshold?}` |
| POST | `/addresses/cleanse` | one address or `{addresses: [...], persist?}` |
| GET | `/datasets` | datasets with scorecards |
| GET | `/datasets/{id}/scorecard` | current scorecard |
| GET | `/datasets/{id}/violations` | violations of a dataset |
| POST | `/datasets/{id}/records` | import JSON `{records, createDataset?, replaceExisting?, validate?}` or `text/csv` (`?createDataset=true`) |
| POST | `/datasets/{id}/validate`, `/profile`, `/duplicates` | run an analysis |

Errors: `{"error": {"code", "message", "requestId", "target"}}` with 400,
401, 403, 404, 409, 422 or 500.

### Auth — `/auth`

| Method | Path | Purpose |
|---|---|---|
| GET | `/auth/config` | `{mode, loginRequired, loginUrl, defaultTenant}` (public) |
| POST | `/auth/login` | `{username, password, tenant?}` → `{access_token, token_type, expires_in, scope, user}` |
| GET | `/auth/me` | the caller: user, tenant, scopes |
| POST | `/auth/password` | `{currentPassword, newPassword}` — change the own password |
| POST | `/auth/logout` | 204 (stateless) |

### CLI

```bash
./build/uim-data-quality-cli help
./build/uim-data-quality-cli list Datasets
./build/uim-data-quality-cli import customers customers.csv --create
./build/uim-data-quality-cli validate customers
./build/uim-data-quality-cli duplicates customers name,city --strategy=composite --threshold=85
./build/uim-data-quality-cli cleanse customers --dry-run
./build/uim-data-quality-cli scorecard customers
./build/uim-data-quality-cli create Users --data='{"id":"steward","password":"a long password","scopes":["Manage"]}'
```

The generic commands (`sets`, `metadata`, `list`, `count`, `get`, `create`,
`update`, `delete`, `invoke`) work on every entity set and action of the
OData model. `--json` prints machine readable output; `--tenant`,
`--storage` and `--data-file` select the data.

### Desktop GUI

`dub build --config=gui` (needs GTK 3) builds a model driven browser with a
page per entity set, generated forms and an action runner.

## Configuration

Precedence (lowest → highest): built-in defaults →
`backend/config/default.json` → `config/<UIM_PROFILE>.json` → `DQ_*`
environment variables (`DQ_PORT`, `DQ_AUTH_MODE`, `DQ_JWT_SECRET`, …) →
Cloud Foundry (`PORT`, `VCAP_SERVICES`, credentials of the user-provided
service `data-quality-config`) → CLI options.

| Key | Default | Meaning |
|---|---|---|
| `port` / `host` | 8086 / 0.0.0.0 | HTTP listener |
| `storage` | `memory` (`file` in default.json) | `memory` or `file` (one JSON snapshot) |
| `dataFile` | `data/data-quality.json` | snapshot file |
| `apiPath` / `odataPath` | `/api/v1` / `/odata/v4/data-quality` | endpoints |
| `frontendDir` | `../frontend` | Fiori app served at `/app` ("" = off, e.g. behind the approuter) |
| `authMode` | `open` (`jwt` in default.json) | `open` or `jwt`; an XSUAA binding switches to `xsuaa` |
| `jwtSecret` | "" | HS256 secret, ≥ 32 characters ("" = random per start) |
| `tokenTtlSeconds` | 3600 | token lifetime |
| `adminUser` / `adminPassword` | `admin` / "" | first administrator in jwt mode ("" = generated, logged once) |
| `passwordIterations` | 120000 | PBKDF2 rounds |
| `maxFailedLogins` / `lockSeconds` | 5 / 900 | temporary lock |
| `minPasswordLength` | 10 | password policy |
| `jobIntervalSeconds` | 5 | cleansing job worker (0 = run jobs on creation) |
| `autoValidate` | true | validate records when created or changed |
| `maxSnapshots` | 100 | trend points kept per dataset |
| `maxImportRecords` | 50000 | records per import |
| `maxPairwiseRecords` | 20000 | limit for fuzzy/composite matching |
| `maxPageSize` | 200 | OData server-driven paging |

Secrets are masked in `uim-data-quality-cli config`.

## Deployment

**SAP BTP / Cloud Foundry**

```bash
mbt build && cf deploy mta_archives/uim-data-quality_2.0.0.mtar
```

The MTA creates the XSUAA instance from
[approuter/xs-security.json](approuter/xs-security.json) (role collections
`DataQualityViewer`, `DataQualitySteward`, `DataQualityAdministrator`),
deploys the backend with the binary buildpack and the approuter with the
Fiori app. Locally the approuter runs with `approuter/default-env.json`
(never committed).

**Container / Kubernetes**

```bash
# from the repository root (path dependency on ../service)
docker build -f data-quality/backend/Dockerfile -t uim-platform/data-quality .
cp k8s/secret.example.yaml k8s/secret.yaml   # fill in DQ_JWT_SECRET, DQ_ADMIN_PASSWORD
kubectl apply -f k8s/secret.yaml -f k8s/configmap.yaml -f k8s/deployment.yaml -f k8s/service.yaml
```

The file store is a single-node snapshot: run one replica.

## Development

```bash
cd backend
dub test                      # unit + integration tests (domain … HTTP, login, file store)
dub build --config=gui        # optional desktop GUI
```

Frontend tests: `frontend/test/testsuite.qunit.html` (QUnit for formatters,
dialogs and session; OPA5 journey against a running backend with demo data
and `DQ_AUTH_MODE=open`). `cd frontend && npm install && npm start` serves
the app with the UI5 tooling; `localService/` holds the metadata and mock
data.

### Backend layout

```
backend/source/uim/platform/data_quality/
├── domain/          entities, value types, enumerations, exceptions, pure services
│                    (validation engine, expressions, cleansing engine, address cleanser,
│                    duplicate detector, similarity, profiler, quality scorer)
├── ports/           driving ports (use cases, statistics) and driven ports
│                    (repositories, unit of work, events, clock, password hasher, token issuer)
├── application/     DTOs, interactors, demo data, reference data lookups, statistics
├── persistence/     document collections, mappers, repositories, batching stores
├── infrastructure/  configuration, logging, security (PBKDF2, HS256 issuer, XSUAA),
│                    clock, cleansing job worker, composition root (container)
└── presentation/    odata (EDM model, engine), http (REST, auth, CSV), web (/app), cli, gui
```

### Performance notes

- The file store writes its snapshot once per batch (imports, validation
  runs, cleansing jobs) instead of once per document.
- Regular expressions and parsed expressions are compiled once per engine;
  address patterns once per thread.
- Reference data for lookups is loaded once per run and indexed.
- Duplicate detection groups exact and phonetic matches by hash (O(n)) and
  skips fuzzy pairs whose length difference already rules out the threshold.
- Dataset counters are computed in one pass for the whole list.
