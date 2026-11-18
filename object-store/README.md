# UIM Object Store Service

An SAP BTP *Object Store*–style service for the UIM Platform: S3-like buckets and
objects with versioning, access policies, lifecycle rules, CORS rules and service
bindings (access keys) on AWS, Azure, Google Cloud and Alibaba Cloud regions.

It is built as a hexagonal (Clean Architecture) **D / vibe.d 0.10** backend with five
driving adapters on the same ports:

| Adapter | Entry point | Purpose |
|---|---|---|
| REST (management plane) | `/api/v1/object-store/<resource>` | CRUD and actions on all resources |
| Content API (data plane) | `/api/v1/object-store/content/<bucket>/<key>` | S3-like `PUT` / `GET` / `HEAD` / `DELETE` / `OPTIONS`, listing |
| OData v4 | `/odata/v4/object-store` | SAP Fiori 3 / UI5 app (`frontend/`) |
| CLI | `uim-object-store-cli` | administration, scripting, `put` / `get` / `ls` / `rm` |
| Desktop GUI | `uim-object-store-gui` | GtkD 3: bucket browser, upload/download, all resources |

The server, CLI and GUI share one storage (JSON snapshots plus content-addressed
blob files in `dataDir`), so changes made in one show up in the others.

```
object-store/
├── mta.yaml                 MTA descriptor (backend + approuter + XSUAA)
├── backend/                 D / vibe.d service (hexagonal architecture)
├── frontend/                SAP Fiori 3 / UI5 app (OData v4)
├── approuter/               SAP approuter: XSUAA login, routing, CSRF
├── k8s/                     Kubernetes manifests
├── README.md · UML.md · NAFv4.md
```

## Project layout

```
backend/
├── dub.sdl                  configurations: defaultRun (server), cli, gui, defaultTest
├── config/default.json      default configuration
├── Dockerfile / Containerfile
└── source/
    ├── app.d  cli.d  gui.d  entry points (composition roots)
    └── uim/platform/object_store/
        ├── domain/          entities, types (ids, values), enumerations, exceptions,
        │                    services: naming, checksums, bucket_rules, access_evaluator,
        │                    cors_matcher, lifecycle_planner, catalogs
        ├── ports/           usecases (driving), services, repositories, storages (snapshot, blob),
        │                    messaging (events), gateways (key management), driving.d (port bundle)
        ├── application/     usecases/manage (buckets, objects, versions, configuration, bindings),
        │                    services (object_storage, statistics, catalog, events), dtos
        ├── persistence/     repositories, storages (JSON files, memory, snapshot store, blobs),
        │                    mappers (reflection codec), records (collections, snapshot envelope)
        ├── infrastructure/  configuration, logging, security (XSUAA identity), clients (KMS),
        │                    workers (lifecycle), container (dependency injection)
        ├── presentation/    resources (protocol-neutral adapters + registry), http (REST + content),
        │                    odata (controller, $metadata, query options), cli, gui (GtkD), web, tabular
        └── helpers/         codec (struct ↔ JSON by reflection), enums, json, time
frontend/
├── manifest.json · Component.js · index.html
├── view/                    App, Main (KPIs, buckets, bindings, access tools), BucketDetail (browser, rules)
├── controller/              BaseController (create dialog, actions, credentials), Main, BucketDetail
├── fragment/                CreateDialog, CredentialsDialog, VersionsDialog
├── model/                   models, formatter, fields (create dialog catalogue)
├── i18n/                    English, German
├── localService/            metadata.xml and mock data generated from the running service
└── test/                    QUnit (formatter, fields) and OPA5 journeys
```

## Domain model

| Aggregate | Key rules |
|---|---|
| **Bucket** | S3 naming (3–63 chars, lowercase, digits, `-`, `.`; no IP form), unique per tenant; provider and region fixed after creation, region checked against the provider's region catalogue; SSE-KMS / SSE-C need a key id (checked by the key management gateway); quota ≥ usage; `suspended` buckets are read-only; must be empty before it is deleted; deleting it deletes its policies, rules and bindings |
| **StorageObject** | key ≤ 1024 bytes, no leading `/`, no control characters, no `.`/`..` segments; ETag = MD5 of the content; user metadata; storage class; **legal hold** blocks overwrite, delete and expiry; `archived` objects must be restored before reading |
| **ObjectVersion** | created by every write, immutable, content-addressed (SHA-256 blob id: copies and promotions share content); versioned buckets write **delete markers**; old versions can be promoted ("make latest") or deleted permanently; unreferenced blobs are garbage collected |
| **AccessPolicy** | IAM-style statements: effect, principals (`user`, `binding:<name>`, `anonymous`, glob patterns), actions (`read`, `write`, `delete`, `list`, `all`), key patterns; **explicit deny wins**; with *Block Public Access*, wildcard statements never apply to `anonymous` |
| **LifecycleRule** | per prefix: transition to a colder class after N days, expiration after N days, purge of noncurrent versions after N days; legal hold respected; run by a background worker or on demand |
| **CorsRule** | allowed origins (with wildcards), methods, headers, exposed headers, max age; evaluated for `OPTIONS` preflights and actual browser requests of the content API |
| **ServiceBinding** | access key id `OSAK…` plus a 40-character secret shown **once** (on create and rotate); only a salted SHA-256 hash is stored and compared in constant time; permission `readOnly` / `readWrite` / `admin`; expiry; revoke is final; last use is recorded |

Storage classes, hottest first: `standard`, `infrequentAccess`, `nearline`,
`coldline`, `archive`. Lifecycle transitions only move objects to colder classes.

### Management plane vs. data plane

* The **management plane** (REST resources, OData, CLI, GUI) is protected by XSUAA
  scopes in the approuter.
* The **data plane** (content API, `PutObjectContent` OData action, CLI `put`/`get`/`ls`/`rm`)
  additionally enforces **binding permissions** and the bucket's **access policies**.
  Callers authenticate with the XSUAA token (principal = user id) or with binding
  credentials (`X-Access-Key-Id` / `X-Secret-Access-Key` headers or
  `Authorization: OSK <accessKeyId>:<secret>`; principal = `binding:<name>`).
  A bucket without enabled policies is open to all authenticated callers of the tenant.

## Build and run

```bash
cd backend

# HTTP server: REST + content API + OData v4 + Fiori app at http://localhost:8092/
dub run

# Command line interface
dub build --config=cli
./build/uim-object-store-cli help
./build/uim-object-store-cli buckets create --name=media --versioning-enabled --labels=team=web
./build/uim-object-store-cli put media docs/readme.md ../README.md
./build/uim-object-store-cli ls media
./build/uim-object-store-cli get media docs/readme.md --out=/tmp/readme.md
./build/uim-object-store-cli bindings create --bucket-id=media --name=ci --permission=readWrite
./build/uim-object-store-cli policies create --bucket-id=media --name=readers --principals='*' --actions=read,list
./build/uim-object-store-cli evaluate --bucket=media --principal=jane --action=write --key=docs/a.txt
./build/uim-object-store-cli lifecycle-rules create --bucket-id=media --name=logs --prefix=logs/ \
    --transition-days=30 --transition-storage-class=coldline --expiration-days=365
./build/uim-object-store-cli lifecycle

# Desktop GUI (GtkD 3, needs GTK 3.24)
dub run --config=gui -- --tenant=default

# Unit tests (domain rules, codec, persistence, use cases, adapters, CLI, end-to-end scenario)
dub test --config=defaultTest
```

The CLI and GUI accept `--data-dir=<dir>`, `--storage=memory` and `--tenant=<id>`.
Every resource supports `list [--<field>=<value>]`, `get`, `create`, `update`,
`delete`, `fields` and its actions (e.g. `objects copy <id> --target-key=b.txt`,
`bindings rotate ci`, `buckets empty media`). Ids and unique names are accepted
wherever an id is expected; `--json` gives machine-readable output.

The backend depends on the `service` package of this repository by path
(`../../service`), so it builds independently of the repository root recipe.

### Content API with curl

```bash
R=http://localhost:8092/api/v1/object-store
curl -X PUT $R/content/media/docs/hello.txt -H 'Content-Type: text/plain' -H 'X-Meta-Owner: jane' --data-binary 'Hello'
curl $R/content/media/docs/hello.txt                    # ETag, X-Version-Number, X-Meta-*, Last-Modified
curl "$R/content/media/docs/hello.txt?version=1"         # an older version
curl "$R/content/media?prefix=docs/&delimiter=/"         # list keys and folders
curl -X DELETE $R/content/media/docs/hello.txt           # delete marker in versioned buckets
curl $R/content/media/docs/a.txt -H "Authorization: OSK $KEY:$SECRET"   # as a service binding
```

### Fiori app

The backend serves `frontend/` at `/` for local development (`frontendDir`), so
http://localhost:8092/index.html works without an approuter. The app offers:

* **Overview / KPI header** — buckets, objects, stored bytes, versions, archived,
  legal hold, active bindings, usage per storage class (Statistics singleton)
* **Buckets** — create (provider, region, versioning, encryption, quota, labels),
  suspend, resume, empty, delete; usage bars against the quota
* **Bucket detail** — folder browser (breadcrumbs), upload, new text object,
  download, versions (download, make latest, delete permanently), copy, archive,
  restore, legal hold; access policies (inline enable/disable), lifecycle rules
  (apply now), CORS rules, service bindings (create/rotate shows the secret once)
* **Service Bindings** — all bindings of the tenant: rotate, revoke, delete
* **Access Tools** — evaluate access policies, check CORS preflights, verify binding credentials

`localService/` contains the generated `$metadata` and mock data for standalone
development; the OData model uses `$direct` (no `$batch`).

### Deploy to SAP BTP (Cloud Foundry)

```bash
mbt build            # backend (binary buildpack) + approuter (Fiori app in resources/)
cf deploy mta_archives/uim-object-store_1.0.0.mtar
```

Assign the role collections *UIM Object Store Viewer / User / Administrator*.
Runtime overrides can be provided by the user-provided service `object-store-config`.

### Container / Kubernetes

```bash
# from the uim-platform repository root
podman build -f object-store/backend/Containerfile -t uim-platform/cloud-object-store .
kubectl apply -f object-store/k8s/
```

## Configuration

Precedence (lowest → highest): compiled defaults → `config/default.json` (or
`OBJSTORE_CONFIG_FILE`) → environment variables → `VCAP_SERVICES` credentials of a
service named or tagged `object-store-config`.

| Key | Environment | Default | Meaning |
|---|---|---|---|
| `host` / `port` | `OBJSTORE_HOST` / `OBJSTORE_PORT`, `PORT` | `0.0.0.0` / `8092` | listener |
| `logLevel` | `OBJSTORE_LOG_LEVEL` | `info` | `debug`, `info`, `warn`, `error` |
| `storage` | `OBJSTORE_STORAGE` | `file` | `file` (shared JSON snapshots + blobs) or `memory` |
| `dataDir` | `OBJSTORE_DATA_DIR` | `data` | snapshot files and `blobs/<tenant>/<id[0..2]>/<id>` |
| `defaultTenant` | `OBJSTORE_DEFAULT_TENANT` | `default` | tenant without token / `X-Tenant-Id` |
| `restPath` / `odataPath` | `OBJSTORE_REST_PATH` / `OBJSTORE_ODATA_PATH` | `/api/v1/object-store` / `/odata/v4/object-store` | adapter roots |
| `lifecycleIntervalSeconds` | `OBJSTORE_LIFECYCLE_INTERVAL` | `3600` | lifecycle worker period (0 = off) |
| `lifecycleTenants` | `OBJSTORE_LIFECYCLE_TENANTS` | `default` | tenants processed by the worker |
| `providers` | `OBJSTORE_PROVIDERS` | `aws,azure,gcp,alibaba` | offered hyperscalers (region value help) |
| `defaultRegion` | `OBJSTORE_DEFAULT_REGION` | `eu-central-1` | region of new buckets (if offered by the provider) |
| `maxObjectSize` | `OBJSTORE_MAX_OBJECT_SIZE` | `67108864` | bytes per object (HTTP 413 above) |
| `maxBucketsPerTenant` | `OBJSTORE_MAX_BUCKETS` | `100` | bucket limit per tenant |
| `frontendDir` | `OBJSTORE_FRONTEND_DIR` | `../frontend` | serve the Fiori app at `/` ("" = off) |

## REST API (`/api/v1/object-store`)

| Method | Path | Description |
|---|---|---|
| GET | `/<resource>[?<field>=<value>…]` | list → `{ "items": [...], "count": n }` |
| POST | `/<resource>` | create → 201 |
| GET / PATCH (PUT) / DELETE | `/<resource>/<id or name>` | read, partial update, delete |
| POST | `/<resource>/<id or name>/<action>` | action, e.g. `/objects/<id>/archive`, `/bindings/ci/rotate` |
| GET | `/buckets/<id or name>/list?prefix=&delimiter=/` | S3 style listing with folders |
| POST | `/access/evaluate` · `/cors/check` · `/credentials/verify` · `/lifecycle/apply` | operations |
| GET | `/statistics` · `/resources` | KPIs · resource catalogue (fields, actions) |
| PUT / GET / HEAD / DELETE / OPTIONS | `/content/<bucket>/<key>` | data plane (see above) |
| GET | `/api/v1/health` | health check |

Resources: `buckets`, `objects`, `versions` (read/delete only), `policies`,
`lifecycle-rules`, `cors-rules`, `bindings`, `regions`, `storage-classes` (read-only).
Errors: `{ "error": { "code", "message" } }` with 400, 403, 404, 405, 409, 413, 422 or 500.
Tenant and user come from the XSUAA token or the `X-Tenant-Id` / `X-User-Id` headers.

## OData v4 (`/odata/v4/object-store`)

* Entity sets: `Buckets`, `StorageObjects`, `ObjectVersions`, `AccessPolicies`,
  `LifecycleRules`, `CorsRules`, `ServiceBindings`, `Regions`, `StorageClasses`;
  singleton `Statistics`
* `$filter` (`eq ne gt ge lt le and or not contains startswith endswith tolower toupper`),
  `$orderby`, `$select`, `$top`, `$skip`, `$count`, `$search`, `/$count`
* Byte sizes are `Edm.Int64` — written as strings for `IEEE754Compatible=true`
  clients (UI5), also inside complex types
* Actions per resource (`SuspendBucket`, `ResumeBucket`, `EmptyBucket`,
  `ArchiveStorageObject`, `RestoreStorageObject`, `HoldStorageObject`,
  `ReleaseStorageObject`, `CopyStorageObject`, `PromoteObjectVersion`,
  `ApplyLifecycleRule`, `RotateServiceBinding`, `RevokeServiceBinding`) with an `id` parameter
* Unbound actions: `PutObjectContent` (upload, data plane), `EvaluateAccess`,
  `CheckCors`, `VerifyCredentials`, `ApplyLifecycle`
* Capability annotations (insertable / updatable / deletable) and `Common.Label`s
  for all properties; `$batch` is not supported

## Changes from the previous version

| Area | Before | Now |
|---|---|---|
| Layout | flat `source/`, single executable | `backend/` (hexagonal layers per the Fiori/vibe.d architecture), `frontend/`, `approuter/`, `mta.yaml`, `k8s/` |
| Adapters | REST controllers per resource | protocol-neutral resource registry driving REST, content API, OData v4, CLI and GtkD GUI |
| Content | object metadata only, no bytes | real content: content-addressed blob storage (files / memory), MD5 ETags, raw upload/download, base64 via OData |
| Versioning | version records without content | versions with content, delete markers, promote, permanent delete, blob garbage collection |
| Persistence | in-memory only | shared JSON snapshots (atomic writes, reload on change) + blob files; memory mode for tests |
| Access policies | stored only | evaluated (explicit deny wins, globbing, public access block) and enforced on the data plane |
| Service bindings | MD5 of the secret, secret never returned | salted SHA-256, constant-time verification, one-time secret on create/rotate, expiry, last use, binding credentials on the content API |
| Lifecycle rules | stored only | planned and executed (transition, expiration, noncurrent versions), background worker, per-rule results |
| CORS rules | stored only | validated; preflight and response headers on the content API |
| Buckets | — | S3 naming rules, provider/region catalogue, KMS key validation, quota checks, suspend/resume/empty, cascade delete |
| Objects | — | key rules, legal hold, archive/restore, copy, S3 style listing with folders |
| Errors | `UsecaseResult` strings | business exceptions mapped to 403/404/405/409/413/422 |
| Configuration | `OBJSTORE_HOST/PORT` | typed config: defaults → file → env → `VCAP_SERVICES` |
| Tests | — | unit tests for every layer and an end-to-end scenario |

Older JSON records stay readable: unknown or missing fields fall back to defaults.

## Architecture notes

* **Dependency rule** — `domain ← ports ← application ← persistence / infrastructure ← presentation`.
  Presentation adapters only see the `ObjectStorePorts` bundle; the container is the only
  place that knows concrete classes.
* **One registry, many protocols** — `presentation/resources` wraps each driving port in a
  generic `ResourceAdapter` (JSON payloads by compile-time reflection). REST, OData
  (`$metadata` is generated from it), CLI and GUI are thin protocol layers on top.
* **Content addressing** — the blob id is the SHA-256 of the content, so identical content
  is stored once per tenant; a blob is deleted when the last version referencing it goes.
* **Security** — XSUAA JWT claims are decoded but **not signature-verified** by the
  backend; it must only be reachable through the approuter (or add JWKS verification in
  `infrastructure/security`). The KMS client is simulated (format checks); replace it
  with a real gateway for production.
* **Extension points** — a hyperscaler blob adapter (S3, Azure Blob, GCS) implements
  `IBlobStorage`; an Event Mesh publisher implements `IObjectStoreEventPublisher`.

## License

Apache 2.0 — see the repository's LICENSE file.
