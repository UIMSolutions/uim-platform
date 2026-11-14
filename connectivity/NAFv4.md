# NAF v4 Architecture Description — Connectivity Service

> NATO Architecture Framework v4 (NAF v4) description of the UIM Platform Connectivity
> service: destinations with their authentication flows, Cloud Connectors with service
> channels and access control, the certificate store and connectivity monitoring —
> exposed through REST, OData v4 (SAP Fiori), a CLI and a desktop GUI.

---

## 1. NAF v4 Grid Mapping

| NAF View | Viewpoint | Covered Below |
|---|---|---|
| **NCV** – Capability View | C1 Capability Taxonomy, C2 Enterprise Vision, C3 Capability Dependencies | §2 |
| **NSV** – Service View | NSOV-1 Service Taxonomy, NSOV-2 Service Definitions, NSOV-3 Service Interfaces | §3 |
| **NOV** – Operational View | NOV-1 Concept, NOV-2 Node Connectivity, NOV-5 Operational Activities | §4 |
| **NLV** – Logical View | NLV-1 Logical Data Model, NLV-2 Logical Components, NLV-6 State Transitions | §5 |
| **NPV** – Physical View | NPV-1 Physical Deployment, NPV-2 Configuration | §6 |
| **NIV** – Information View | NIV-1 Information Structure, NIV-2 Business Rules | §7 |
| **Architecture decisions** | — | §8 |
| **Traceability** | capabilities → services → components | §9 |

---

## 2. Capability View (NCV)

### C1 – Capability Taxonomy

```
C1  Connectivity
├── C1.1  Destination Management
│   ├── C1.1.1  Destination maintenance (HTTP, RFC, Mail, LDAP, TCP)
│   ├── C1.1.2  Authentication flows (none, basic, 7 × OAuth 2.0, client certificate,
│   │           principal propagation, SAML assertion) with completeness validation
│   ├── C1.1.3  Routing (internet, on premise via Cloud Connector location, private link)
│   ├── C1.1.4  Additional properties and HTTP headers
│   ├── C1.1.5  Connection check (auth → certificate → connector → access rule → probe)
│   └── C1.1.6  Secret protection (masking in every channel)
├── C1.2  Cloud Connector Management
│   ├── C1.2.1  Registration per subaccount and location ID
│   ├── C1.2.2  Heartbeats, reconnect, disconnect, maintenance
│   ├── C1.2.3  Missed-heartbeat detection
│   └── C1.2.4  Unregistration with cascade of channels and rules
├── C1.3  Service Channels
│   ├── C1.3.1  Virtual host:port → back-end host:port mapping (HTTP, RFC, TCP)
│   └── C1.3.2  Open / close bound to the connector state
├── C1.4  Access Control
│   ├── C1.4.1  Rules per protocol, virtual host:port, path prefix (± sub-paths)
│   ├── C1.4.2  Allow / deny, longest prefix wins, deny wins ties, default deny
│   ├── C1.4.3  Internal host mapping and principal propagation
│   └── C1.4.4  Access check (dry run)
├── C1.5  Certificate Store
│   ├── C1.5.1  X.509, PKCS#12, PEM, JKS for authentication, signing, encryption, trust
│   ├── C1.5.2  Validity tracking (valid → expiring → expired)
│   └── C1.5.3  Renewal and revocation; reference protection
├── C1.6  Connectivity Monitoring
│   ├── C1.6.1  Event log with 21 event types and default severities
│   ├── C1.6.2  Periodic health check and statistics (KPIs)
│   └── C1.6.3  Retention (log pruning)
└── C1.7  Access Channels
    ├── C1.7.1  REST API · C1.7.2 OData v4 / SAP Fiori · C1.7.3 CLI · C1.7.4 GtkD desktop GUI
    └── C1.7.5  Multi-tenancy and XSUAA-based identity
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | One place to define how cloud applications reach remote systems, and to see at any time whether they can |
| **Vision** | A connectivity layer that bridges cloud and on-premise systems through secure tunnels, explicit access control and complete, checked authentication settings |
| **Goals** | Destinations that are validated before use; access to on-premise back ends only through explicitly exposed resources; no silent expiry of certificates or loss of connectors |
| **Scope** | Destinations, Cloud Connectors, service channels, access rules, certificates, event log |
| **Out of scope** | Carrying the application traffic itself (proxying), token retrieval from token services, credential vaulting |
| **Stakeholders** | Integration architects, network administrators, security officers, application developers, operations |

### C3 – Capability Dependencies

| Capability | Depends on |
|---|---|
| C1.1.5 Connection check | C1.1.2 (settings), C1.5.2 (usable certificate), C1.2 (connected connector), C1.4.2 (access decision), probe gateway |
| C1.3.2 Open channels | C1.2.2 (connector connected) |
| C1.2.3 Missed-heartbeat detection | C1.6.2 (health check), C1.3.2 (channels are closed) |
| C1.5.3 Revocation | C1.1.5 (dependent destinations become misconfigured on their next check) |
| C1.6.1 Event log | all mutating capabilities |
| C1.7 Access channels | C1.1 – C1.6 through the same driving ports |

---

## 3. Service View (NSV)

### NSOV-1 – Service Taxonomy

```
NSOV-1  Connectivity Services
├── SVC-DEST    Destination Service          (IManageDestinationsUseCase)
├── SVC-CONN    Cloud Connector Service      (IManageConnectorsUseCase)
├── SVC-CHAN    Service Channel Service      (IManageChannelsUseCase)
├── SVC-ACR     Access Control Service       (IManageAccessRulesUseCase)
├── SVC-CERT    Certificate Store Service    (IManageCertificatesUseCase)
├── SVC-LOG     Event Log Service            (IManageLogsUseCase)
├── SVC-HC      Health Check Service         (IHealthCheckUseCase)
└── SVC-STAT    Statistics Service           (IConnectivityStatisticsService)
```

### NSOV-2 – Service Definitions

| Service | Operations | Outcome |
|---|---|---|
| SVC-DEST | create, update, remove, get, list, **check**, findByName | validated destination; check stores status, message, latency |
| SVC-CONN | register (create), update, unregister (remove), **heartbeat**, **disconnect**, **reconnect**, **startMaintenance** | connector state; channels closed on disconnect / maintenance; cascade on unregister |
| SVC-CHAN | create, update, remove, **open**, **close** | channel state bound to the connector |
| SVC-ACR | create, update, remove, **enable**, **disable**, **checkAccess** | rule set; access decision with internal target |
| SVC-CERT | create, update, remove, **renew**, **revoke** | validity status; protected while referenced |
| SVC-LOG | record (create), remove, list, bySource, **purge** | append-only audit trail |
| SVC-HC | run | report of examined / changed objects |
| SVC-STAT | statistics | KPI figures per tenant |

All mutating operations return a `UsecaseResult` whose `code` is 404 (not found),
409 (conflict with state or uniqueness) or 422 (business rule violated).

### NSOV-3 – Service Interfaces

| Interface | Binding | Notes |
|---|---|---|
| REST | `/api/v1/<resource>`, `/<resource>/{id}/<action>`, `/statistics`, `/health-check`, `/access-check`, `/resources`, `/health` | JSON, errors `{error:{code,message}}` |
| OData v4 | `/odata/v4/connectivity`: 6 entity sets, `Statistics` singleton, 11 bound-by-id unbound actions, `RunHealthCheck`, `CheckAccess` | CSDL with `Common.Label` and capabilities, `$filter/$orderby/$select/$top/$skip/$count/$search` |
| CLI | `uim-connectivity-cli <resource> <verb>`, `stats`, `health-check`, `access-check`, `purge-logs`, `config` | table or `--json` output; exit codes 0/1/2 |
| GUI | `uim-connectivity-gui` (GtkD 3) | tab per resource, forms derived from the specs, health / access check |
| Events | `IConnectivityEventPublisher`: `connectivity.<kind>.<verb>`, `connectivity.log.<eventType>`, `connectivity.health-check.completed` | default adapter writes the technical log |
| Probe | `IConnectivityProbe`: `probe(destination, endpoint)`, `probeTunnel(destination, connector, host, port)` | default adapter simulates reachability |

---

## 4. Operational View (NOV)

### NOV-1 – Concept

Cloud applications refer to remote systems by destination name. An administrator
maintains destinations; on-premise systems are exposed by a Cloud Connector that
registers for a location and exposes only the resources its access rules allow. The
service checks destinations on request and periodically, detects lost connectors and
expiring certificates, and records every relevant event.

### NOV-2 – Operational Node Connectivity

| Node | Role | Connects to | Information exchanged |
|---|---|---|---|
| Fiori user (browser) | administrator / operator / viewer | approuter | OData v4 over HTTPS |
| Approuter | authentication, routing, CSRF | XSUAA, connectivity backend | JWT, OData / REST |
| Connectivity backend | system of record and checks | snapshot storage, probe targets, event publisher | entities, probes, events |
| Cloud Connector (on premise) | tunnel end point | backend via approuter (REST) | registration, heartbeats |
| On-premise back end | target system | Cloud Connector (internal host:port) | application traffic (not carried by this service) |
| Internet service | target system | probe | reachability |
| CLI / GtkD GUI | local administration | snapshot storage | entities |

### NOV-5 – Operational Activities

| Activity | Actor | Steps |
|---|---|---|
| Expose an on-premise system | network administrator | register connector → create access rule(s) → (optional) create and open service channel |
| Provide a destination | integration architect | (optional) add certificate → create destination → check connection |
| Diagnose "cannot reach system" | operator | check destination → read status message → access check → event log of the destination |
| Rotate a certificate | security officer | renew (or add new + update destinations) → revoke old → check dependent destinations |
| Connector maintenance | network administrator | start maintenance (channels close) → reconnect → open channels |
| Continuous monitoring | system (health check) | heartbeat timeout → certificate validity → destination re-check → log retention |

---

## 5. Logical View (NLV)

### NLV-1 – Logical Data Model

| Entity | Key attributes | Relations |
|---|---|---|
| Destination | name, url, destinationType, authenticationType, proxyType, credentials, certificateId, cloudConnectorLocationId, properties, additionalHeaders, status, lastCheckedAt, latencyMs | → Certificate (0..1); → CloudConnector by location (0..1) |
| CloudConnector | subaccountId, name, locationId, host, port, connectorVersion, status, connectedAt, lastHeartbeatAt | 1 → * ServiceChannel, 1 → * AccessRule |
| ServiceChannel | connectorId, name, channelType, virtualHost:Port, backendHost:Port, connectionCount, status | * → 1 CloudConnector |
| AccessRule | connectorId, name, protocol, virtualHost:Port, internalHost:Port, urlPathPrefix, includeSubPaths, policy, principalPropagation, enabled | * → 1 CloudConnector |
| Certificate | name, certificateType, usage, subjectDN, issuerDN, serialNumber, fingerprint, issuedAt, expiresAt, status, revokedAt | 1 ← * Destination |
| ConnectivityLogEntry | eventType, severity, sourceType, sourceId, sourceName, message, remoteHost:Port, occurredAt | → any aggregate by sourceId |

All entities carry `tenantId`, `id`, `createdBy/At`, `updatedBy/At`. Value objects:
`KeyValue`, `Endpoint`, `MonitoringPolicy`, `AccessDecision`.

### NLV-2 – Logical Components

| Layer | Components |
|---|---|
| Domain | entities; services `names`, `endpoints`, `auth_flow`, `access_control`, `lifecycle`, `certificate_validity`; exceptions |
| Ports | driving: 6 × `IManageResource<…>` specializations, `IHealthCheckUseCase`, `IConnectivityStatisticsService`, bundle `ConnectivityPorts`; driven: 6 repositories, `ISnapshotStorage`, `IConnectivityProbe`, `IConnectivityEventPublisher` |
| Application | `ResourceUseCase<…>` + 6 interactors, `HealthCheckUseCase`, `DestinationChecker`, `ConnectorCascade`, `EventRecorder`, `ConnectivityStatisticsService` |
| Persistence | repositories, `SnapshotTenantStore`, `JsonFileSnapshotStorage`, `MemorySnapshotStorage`, `RecordMapper<T>` |
| Infrastructure | `ConnectivityConfig`, logging, XSUAA identity, `SimulatedConnectivityProbe`, `HealthCheckWorker`, `Container` |
| Presentation | `ResourceRegistry` + `ResourceAdapter<…>`, REST, OData (model, metadata, query, controller), CLI, GtkD GUI, web (Fiori files) |

### NLV-6 – State Transitions

| Entity | Transitions |
|---|---|
| CloudConnector | connected → disconnected / maintenance / error; disconnected → connected / error; maintenance → connected / disconnected; error → connected / disconnected |
| ServiceChannel | closed → open (connector connected); open → closed (close, connector disconnected / maintenance) |
| Certificate | valid → expiring → expired (time); valid / expiring / expired → revoked; renew → valid / expiring |
| Destination | unchecked (create / update) → reachable / unreachable / misconfigured (check, health check) |
| AccessRule | enabled ⇄ disabled |

---

## 6. Physical View (NPV)

### NPV-1 – Physical Deployment

| Artifact | Runtime | Deployed as |
|---|---|---|
| `uim-connectivity-platform-service` | D binary (vibe.d 0.10.3) | CF app `connectivity-srv`, binary buildpack, 256 MB, health check `/api/v1/health` |
| Fiori app (`frontend/`) | SAPUI5 1.120 (CDN) | static resources of `connectivity-approuter` |
| `@sap/approuter` | Node.js ≥ 20 | CF app `connectivity-approuter` |
| XSUAA | managed service `connectivity-xsuaa` (plan application) | `approuter/xs-security.json` |
| Runtime overrides | user-provided service `connectivity-config` | `VCAP_SERVICES` |
| Snapshots | `data/*.json` on the container disk | ephemeral — bind persistent storage for real data |
| `uim-connectivity-cli`, `uim-connectivity-gui` | D binaries (GUI: GTK 3.24) | local workstation, share `backend/data` with a local server |

### NPV-2 – Configuration

| Setting | Source | Default |
|---|---|---|
| host / port | `CONN_HOST` / `CONN_PORT`, `PORT` | 0.0.0.0 / 8088 |
| storage / dataDir | `CONN_STORAGE` / `CONN_DATA_DIR` | file / data |
| odataPath | `CONN_ODATA_PATH` | /odata/v4/connectivity |
| health check interval / tenants | `CONN_HEALTH_CHECK_INTERVAL` / `CONN_HEALTH_CHECK_TENANTS` | 30 s / default |
| heartbeat timeout | `CONN_HEARTBEAT_TIMEOUT` | 300 s |
| certificate warning window | `CONN_CERTIFICATE_WARNING_DAYS` | 30 days |
| log retention | `CONN_MAX_LOG_ENTRIES` | 5000 per tenant |

Precedence: defaults → `config/default.json` → environment → `VCAP_SERVICES`
(`connectivity-config`).

---

## 7. Information View (NIV)

### NIV-1 – Information Structure

| Information | Format | Sensitivity |
|---|---|---|
| Destination configuration | JSON / OData entity | **confidential** — password, client secret, token service password are masked on every channel (`********`); a masked value sent back keeps the stored secret |
| Certificate metadata | JSON / OData entity | internal (no private keys are stored) |
| Connector / channel / rule configuration | JSON / OData entity | internal (network topology) |
| Event log | JSON / OData entity | internal, audit relevant |
| Snapshot files | `{schemaVersion, collection, records[]}` | confidential (contain secrets in plain text) |
| Timestamps | ISO 8601 (Edm.DateTimeOffset) in payloads, std time in records | — |

### NIV-2 – Business Rules

| ID | Rule |
|---|---|
| BR-1 | Destination names are unique per tenant, consist of letters, digits, `-`, `_`, at most 200 characters, and cannot be renamed. |
| BR-2 | The URL scheme must match the destination type; ports must be explicit or implied by the scheme; RFC destinations may use `jco.client.ashost` / `jco.client.sysnr`. |
| BR-3 | Each authentication type requires its fields; OAuth / SAML flows need an `https` token service URL; principal propagation requires `onPremise`; non-HTTP types support only basic, client certificate or (RFC) principal propagation. |
| BR-4 | A referenced certificate must exist (id or name) and be usable at check time (not expired, not revoked, already valid). |
| BR-5 | A location ID is unique per subaccount; connector names are unique per tenant. |
| BR-6 | Channels open only through a connected connector; disconnect and maintenance close all open channels; mapping changes and deletion require a closed channel. |
| BR-7 | Access: only enabled rules with the same protocol, virtual host (case-insensitive) and port apply; path rules match on segment boundaries; the longest prefix wins; deny wins ties; anything else is denied. |
| BR-8 | A connected connector without heartbeat for `heartbeatTimeoutSeconds` becomes disconnected. |
| BR-9 | Certificates within `certificateWarningDays` of expiry are `expiring`; revoked certificates cannot be changed or renewed; certificates used by destinations cannot be deleted. |
| BR-10 | Log entries are immutable; retention keeps the newest `maxLogEntries` per tenant. |
| BR-11 | Connectors with open channels cannot be unregistered; unregistering removes their channels and access rules. |

---

## 8. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Hexagonal architecture (domain, ports, application, persistence, infrastructure, presentation) with the platform-wide `backend/ frontend/ approuter/ mta.yaml` layout | Business rules independent of vibe.d, OData, GTK and storage; same structure as `abap-environment`, `kyma`, `management` |
| AD-2 | Generic driving port `IManageResource<…>` and interactor base with `build / apply / beforeRemove / afterCreate / afterRemove` hooks | Six aggregates with identical CRUD semantics; rules live in hooks and domain services |
| AD-3 | Protocol-neutral resource registry shared by REST, OData, CLI and GUI | One behaviour, four channels; replaces hand-written controllers and `toJson` methods |
| AD-4 | Compile-time reflection codec for payloads, records, `$metadata`, tables and forms | New fields appear everywhere automatically; PATCH via `decode(patch, base)` |
| AD-5 | Connection check as an application service (`DestinationChecker`) composed of pure domain services | The same routing logic serves the explicit check and the health check; each step is unit tested |
| AD-6 | Access control evaluated in the domain (default deny, longest prefix, deny wins ties) | Mirrors Cloud Connector semantics; reusable for the access check dry run |
| AD-7 | Probe gateway port with a simulating adapter | Real HTTP / socket probes and the tunnel API can be added without touching use cases |
| AD-8 | Event log as an aggregate written by `EventRecorder`, plus an event publisher port | Auditable history in every channel; integration with an event broker later |
| AD-9 | Periodic health check in the server process (vibe.d timer) | Detects lost connectors and expiring certificates without an external scheduler |
| AD-10 | JSON snapshot files with atomic rename and revision checks | Server, CLI and GUI share state with no database; single-writer scale |
| AD-11 | OData v4 without `$batch`; unbound actions `<Action><Type>` with `id` | Simple server; UI5 `$direct` group |
| AD-12 | XSUAA via approuter (Viewer / Operator / Admin); backend decodes but does not verify JWTs | Standard BTP setup; direct exposure needs signature verification |
| AD-13 | Secrets masked in adapters, stored in snapshots | Prevents disclosure through APIs and UIs; production use should move secrets to a credential store |
| AD-14 | Port 8088, env prefix `CONN_`, REST resource paths kept | Compatibility with the previous version |

---

## 9. Traceability Matrix

| Capability | Service | Domain / application components | Channels |
|---|---|---|---|
| C1.1 Destinations | SVC-DEST | `Destination`, `endpoints`, `auth_flow`, `names`, `ManageDestinationsUseCase`, `DestinationChecker` | REST, OData, CLI, GUI, Fiori (tab + object page) |
| C1.2 Cloud Connectors | SVC-CONN | `CloudConnector`, `lifecycle`, `ManageConnectorsUseCase`, `ConnectorCascade` | all |
| C1.3 Service channels | SVC-CHAN | `ServiceChannel`, `lifecycle.requireOpenable`, `ManageChannelsUseCase` | all |
| C1.4 Access control | SVC-ACR | `AccessRule`, `access_control`, `ManageAccessRulesUseCase.checkAccess` | all (+ `access-check`, `CheckAccess`) |
| C1.5 Certificates | SVC-CERT | `Certificate`, `certificate_validity`, `ManageCertificatesUseCase` | all |
| C1.6 Monitoring | SVC-LOG, SVC-HC, SVC-STAT | `ConnectivityLogEntry`, `EventRecorder`, `HealthCheckUseCase`, `HealthCheckWorker`, `ConnectivityStatisticsService` | all (+ `health-check`, `RunHealthCheck`, `Statistics`) |
| C1.7 Access channels | — | `ResourceRegistry`, `ConnectivityRestController`, `ConnectivityODataController`, `ConnectivityCli`, `ConnectivityWindow`, approuter | — |
