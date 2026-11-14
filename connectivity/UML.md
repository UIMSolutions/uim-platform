# UML — Connectivity Service

Diagrams of the hexagonal backend (`backend/source/uim/platform/connectivity`), the
Fiori frontend and the BTP deployment. All diagrams are Mermaid.

## Class Diagram — Domain Entities

All aggregates mix in `TenantEntity` (`tenantId`, `id`, `createdBy/At`, `updatedBy/At`).
Service channels and access rules belong to one Cloud Connector; destinations reach a
connector indirectly through its location ID and may reference a certificate.

```mermaid
classDiagram
    class Destination {
        +DestinationId id
        +string name
        +string description
        +string url
        +DestinationType destinationType
        +AuthenticationType authenticationType
        +ProxyType proxyType
        +string user
        +string password «secret»
        +string clientId
        +string clientSecret «secret»
        +string tokenServiceUrl
        +string tokenServiceUser
        +string tokenServicePassword «secret»
        +CertificateId certificateId
        +string cloudConnectorLocationId
        +KeyValue[] properties
        +KeyValue[] additionalHeaders
        +DestinationStatus status
        +string statusMessage
        +long lastCheckedAt
        +int latencyMs
    }
    class CloudConnector {
        +ConnectorId id
        +SubaccountId subaccountId
        +string name
        +string locationId
        +string description
        +string connectorVersion
        +string host
        +int port
        +string tunnelEndpoint
        +ConnectorStatus status
        +string statusMessage
        +long connectedAt
        +long lastHeartbeatAt
    }
    class ServiceChannel {
        +ChannelId id
        +ConnectorId connectorId
        +string connectorName
        +string name
        +ChannelType channelType
        +string virtualHost
        +int virtualPort
        +string backendHost
        +int backendPort
        +int connectionCount
        +ChannelStatus status
        +long openedAt
        +long closedAt
    }
    class AccessRule {
        +AccessRuleId id
        +ConnectorId connectorId
        +string connectorName
        +string name
        +AccessProtocol protocol
        +string virtualHost
        +int virtualPort
        +string internalHost
        +int internalPort
        +string urlPathPrefix
        +bool includeSubPaths
        +AccessPolicy policy
        +bool principalPropagation
        +bool enabled
    }
    class Certificate {
        +CertificateId id
        +string name
        +CertificateType certificateType
        +CertificateUsage usage
        +string subjectDN
        +string issuerDN
        +string serialNumber
        +string fingerprint
        +long issuedAt
        +long expiresAt
        +CertificateStatus status
        +long revokedAt
    }
    class ConnectivityLogEntry {
        +LogEntryId id
        +string name
        +ConnectivityEventType eventType
        +LogSeverity severity
        +SourceType sourceType
        +string sourceId
        +string sourceName
        +string message
        +string remoteHost
        +int remotePort
        +long occurredAt
    }
    class KeyValue {
        +string key
        +string value
    }
    class MonitoringPolicy {
        +int heartbeatTimeoutSeconds
        +int certificateWarningDays
        +int maxLogEntries
    }
    class Endpoint {
        +string scheme
        +string host
        +int port
        +string path
    }

    CloudConnector "1" *-- "0..*" ServiceChannel : connectorId
    CloudConnector "1" *-- "0..*" AccessRule : connectorId
    Destination "0..*" ..> "0..1" CloudConnector : cloudConnectorLocationId = locationId
    Destination "0..*" --> "0..1" Certificate : certificateId
    Destination *-- KeyValue
    ConnectivityLogEntry ..> Destination : sourceId
    ConnectivityLogEntry ..> CloudConnector : sourceId
    ConnectivityLogEntry ..> ServiceChannel : sourceId
    ConnectivityLogEntry ..> Certificate : sourceId
```

## Class Diagram — Domain Services

Pure functions without I/O; the application layer calls them and throws their
`ConnectivityValidationException` (422) / `ConnectivityConflictException` (409).

```mermaid
classDiagram
    class names {
        validateDestinationName(name)
        validateDisplayName(kind, name)
        validateLocationId(id)
        validateHost(what, host)
        validatePort(what, port)
        normalizeFingerprint(fp) string
    }
    class endpoints {
        parseEndpoint(url) Endpoint
        defaultPort(scheme) int
        schemesOf(DestinationType) string[]
        validateDestinationUrl(type, url) Endpoint
    }
    class auth_flow {
        needsTokenService(AuthenticationType) bool
        supportsAuthentication(DestinationType, AuthenticationType) bool
        authenticationErrors(Destination) string[]
        validateAuthentication(Destination)
    }
    class access_control {
        normalizePath(path) string
        pathMatches(AccessRule, path) bool
        ruleNameOf(AccessRule) string
        evaluateAccess(rules, protocol, host, port, path) AccessDecision
    }
    class lifecycle {
        canTransition(ConnectorStatus, ConnectorStatus) bool
        transitionTo(ref CloudConnector, ConnectorStatus)
        heartbeatOverdue(CloudConnector, now, MonitoringPolicy) bool
        requireOpenable(ServiceChannel, CloudConnector)
    }
    class certificate_validity {
        validityAt(Certificate, now, warningDays) CertificateStatus
        daysLeft(Certificate, now) long
        usableAt(Certificate, now, warningDays) bool
        validateValidity(Certificate)
    }
    class AccessDecision {
        +bool allowed
        +AccessRuleId ruleId
        +string ruleName
        +string internalHost
        +int internalPort
        +bool principalPropagation
        +string reason
    }
    access_control ..> AccessDecision
```

## State Diagram — Lifecycles

```mermaid
stateDiagram-v2
    state "Cloud Connector" as CC {
        [*] --> connected : register
        connected --> disconnected : disconnect / heartbeat missed (health check)
        connected --> maintenance : start-maintenance
        connected --> error
        disconnected --> connected : reconnect / heartbeat
        maintenance --> connected : reconnect
        maintenance --> disconnected : disconnect
        error --> connected : reconnect / heartbeat
        error --> disconnected
        disconnected --> [*] : unregister (cascades channels and rules)
        maintenance --> [*] : unregister
    }
    state "Service Channel" as SC {
        [*] --> closed : create
        closed --> open : open (connector connected)
        open --> closed : close / connector disconnected or in maintenance
        closed --> [*] : delete
    }
    state "Certificate" as CE {
        [*] --> valid : create
        valid --> expiring : warning window reached
        expiring --> expired : expiresAt passed
        expiring --> valid : renew
        expired --> valid : renew
        valid --> revoked : revoke
        expiring --> revoked : revoke
        expired --> revoked : revoke
    }
    state "Destination" as DE {
        [*] --> unchecked : create / update
        unchecked --> reachable : check
        unchecked --> unreachable : check
        unchecked --> misconfigured : check
        reachable --> unreachable : health check
        unreachable --> reachable : health check
        reachable --> misconfigured : certificate revoked / expired
    }
```

## Activity Diagram — Connection check (`DestinationChecker`)

```mermaid
flowchart TD
    A([check destination]) --> B{authenticationErrors empty?}
    B -- no --> MC[misconfigured<br/>authenticationFailure]
    B -- yes --> C{endpoint resolvable?<br/>URL or jco.client.ashost}
    C -- no --> MC
    C -- yes --> D{certificate referenced?}
    D -- yes --> E{exists and usableAt now?}
    E -- no --> MC
    E -- yes --> F
    D -- no --> F{proxyType}
    F -- onPremise --> G{connector for location?}
    G -- no --> UR1[unreachable<br/>destinationNotFound]
    G -- yes --> H{connector connected?}
    H -- no --> UR2[unreachable<br/>connectionRefused]
    H -- yes --> I{evaluateAccess allows<br/>scheme/host/port/path?}
    I -- no --> UR3[unreachable<br/>accessDenied]
    I -- yes --> J[probeTunnel internalHost:internalPort]
    F -- internet / privateLink --> K[probe host:port]
    J --> L{reachable?}
    K --> L
    L -- yes --> R[reachable<br/>destinationResolved, latency]
    L -- no --> UR4[unreachable<br/>connectionRefused]
```

## Component Diagram — Hexagonal Architecture

```mermaid
flowchart LR
    subgraph Driving["Driving adapters (presentation)"]
        REST["http · ConnectivityRestController<br/>/api/v1"]
        OD["odata · ConnectivityODataController<br/>/odata/v4/connectivity + $metadata"]
        CLI["cli · ConnectivityCli"]
        GUI["gui · ConnectivityWindow (GtkD)"]
        WEB["web · FrontendController<br/>Fiori app (local dev)"]
        REG["resources · ResourceRegistry<br/>6 × ResourceAdapter"]
    end
    subgraph Core["Application core"]
        PORTS["ports · ConnectivityPorts<br/>IManageResource&lt;…&gt; × 6<br/>IHealthCheckUseCase · IConnectivityStatisticsService"]
        UC["application · ResourceUseCase&lt;…&gt; × 6<br/>HealthCheckUseCase · DestinationChecker<br/>ConnectorCascade · EventRecorder · Statistics"]
        DOM["domain · entities · names · endpoints<br/>auth flows · access control<br/>lifecycle · certificate validity"]
    end
    subgraph Driven["Driven adapters"]
        REPO["persistence · 6 repositories<br/>RecordMapper&lt;T&gt;"]
        STORE["storages · SnapshotTenantStore<br/>JsonFileSnapshotStorage"]
        PROBE["clients · SimulatedConnectivityProbe<br/>(IConnectivityProbe)"]
        PUB["logging · LogEventPublisher<br/>(IConnectivityEventPublisher)"]
    end
    INFRA["infrastructure · ConnectivityConfig · identity · HealthCheckWorker · Container"]

    REST --> REG
    OD --> REG
    CLI --> REG
    GUI --> REG
    REG --> PORTS
    PORTS --> UC
    UC --> DOM
    UC --> REPO
    UC --> PROBE
    UC --> PUB
    REPO --> STORE
    STORE --> FILES[("data/*.json")]
    INFRA -. wires .-> UC
    INFRA -. wires .-> REPO
    INFRA -. runs .-> PORTS
```

Dependencies point inwards: presentation knows only `ConnectivityPorts`; use cases know
only port interfaces (`ConnectivityRepositories`, `IConnectivityProbe`,
`IConnectivityEventPublisher`).

## Class Diagram — Generic use cases and adapters

```mermaid
classDiagram
    class IManageResource~TEntity,TId,TCreate,TUpdate~ {
        <<interface>>
        +create(TCreate) UsecaseResult
        +update(TUpdate) UsecaseResult
        +remove(TenantId, TId, UserId) UsecaseResult
        +get(TenantId, TId) TEntity
        +list(TenantId) TEntity[]
    }
    class ResourceUseCase~TEntity,TId,TCreate,TUpdate~ {
        <<abstract>>
        #ConnectivityRepositories repos
        #EventRecorder events
        #build(TCreate)* TEntity
        #apply(ref TEntity, TSpec)*
        #beforeRemove(TEntity)
        #afterCreate(TEntity, UserId)
        #afterRemove(TEntity, UserId)
        #transition(tenant, id, actor, verb, change) UsecaseResult
        #requireConnector(TenantId, ConnectorId) CloudConnector
        #ensureUnique(existing, candidate, scope)
    }
    class ManageDestinationsUseCase {
        +check(TenantId, DestinationId, UserId) UsecaseResult
        +findByName(TenantId, string) Destination
    }
    class ManageConnectorsUseCase {
        +heartbeat(…, connectorVersion, …)
        +disconnect(…)
        +reconnect(…)
        +startMaintenance(…)
    }
    class ManageChannelsUseCase {
        +open(…)
        +close(…)
    }
    class ManageAccessRulesUseCase {
        +enable(…)
        +disable(…)
        +checkAccess(AccessCheckRequest) AccessCheckResult
    }
    class ManageCertificatesUseCase {
        +revoke(…)
        +renew(…, validDays, …)
    }
    class ManageLogsUseCase {
        +bySource(TenantId, string)
        +purge(TenantId, before, UserId) size_t
    }
    class HealthCheckUseCase {
        +run(TenantId) HealthCheckReport
    }
    class DestinationChecker {
        +evaluate(Destination, now) DestinationCheck
        +run(ref Destination, now, logAlways) bool
    }
    class ConnectorCascade {
        +closeChannels(CloudConnector, reason) size_t
        +clear(TenantId, ConnectorId) size_t
    }
    class EventRecorder {
        +publish(topic, Json)
        +log(tenant, eventType, sourceType, sourceId, sourceName, message, …) ConnectivityLogEntry
    }
    class ResourceAdapter~TEntity,TId,TCreate,TUpdate~ {
        +column(header, field)
        +action(name, label, handler, parameters)
        +secret(field)
        +appendOnly()
        +list / get / create / update / remove / invoke (Json)
    }
    class ResourceRegistry {
        +adapters() IResourceAdapter[]
        +byPath / bySet / byODataAction
        +withReferences(TenantId, Json) Json
        +statistics / healthCheck / checkAccess
    }

    IManageResource <|.. ResourceUseCase
    ResourceUseCase <|-- ManageDestinationsUseCase
    ResourceUseCase <|-- ManageConnectorsUseCase
    ResourceUseCase <|-- ManageChannelsUseCase
    ResourceUseCase <|-- ManageAccessRulesUseCase
    ResourceUseCase <|-- ManageCertificatesUseCase
    ResourceUseCase <|-- ManageLogsUseCase
    ManageDestinationsUseCase --> DestinationChecker
    ManageConnectorsUseCase --> ConnectorCascade
    HealthCheckUseCase --> DestinationChecker
    HealthCheckUseCase --> ConnectorCascade
    ResourceUseCase --> EventRecorder
    ResourceAdapter --> IManageResource
    ResourceRegistry o-- ResourceAdapter
```

## Sequence Diagram — Fiori checks an on-premise destination

```mermaid
sequenceDiagram
    actor U as User (Fiori)
    participant AR as Approuter
    participant OD as ConnectivityODataController
    participant RA as ResourceAdapter (Destinations)
    participant UC as ManageDestinationsUseCase
    participant DC as DestinationChecker
    participant R as Repositories
    participant P as IConnectivityProbe
    participant EV as EventRecorder

    U->>AR: POST /odata/v4/connectivity/CheckDestination {"id"}
    AR->>OD: forward (JWT)
    OD->>OD: resolveIdentity (zid, user_name)
    OD->>RA: invoke(who, id, "check")
    RA->>UC: check(tenant, id, actor)
    UC->>R: destinations.findById
    UC->>DC: run(destination, now, logAlways=true)
    DC->>DC: authenticationErrors / certificate usable
    DC->>R: connectors.findByLocation(fra)
    DC->>R: accessRules.findByConnector
    DC->>DC: evaluateAccess(https, erp.virtual, 443, /sap/opu/odata/…)
    DC->>P: probeTunnel(connector, s4h.corp.local, 44300)
    P-->>DC: reachable, 25 ms
    DC->>EV: log(destinationResolved)
    UC->>R: destinations.update
    UC-->>RA: UsecaseResult(success)
    RA-->>OD: payload (secrets masked)
    OD-->>U: 200 Destination (status = reachable)
```

## Sequence Diagram — Health check detects a lost Cloud Connector

```mermaid
sequenceDiagram
    participant W as HealthCheckWorker (timer)
    participant HC as HealthCheckUseCase
    participant R as Repositories
    participant CC as ConnectorCascade
    participant DC as DestinationChecker
    participant EV as EventRecorder

    W->>HC: run(tenant)
    HC->>R: connectors.findByTenant
    HC->>HC: heartbeatOverdue(c, now, policy)?
    HC->>R: connectors.update(status = disconnected)
    HC->>CC: closeChannels(c)
    CC->>R: channels.update(closed)
    CC->>EV: log(channelClosed) × n
    HC->>EV: log(heartbeatMissed)
    HC->>R: certificates (validityAt) → update changed
    HC->>DC: run(d, now, logAlways=false) for every destination
    DC->>EV: log(connectionRefused) on status change
    HC->>R: destinations.update(changed)
    HC->>R: logs → prune to maxLogEntries
    HC->>EV: publish(connectivity.health-check.completed)
    HC-->>W: HealthCheckReport(changes)
```

## Sequence Diagram — CLI and server share data

```mermaid
sequenceDiagram
    participant CLI as uim-connectivity-cli
    participant FS as data/*.json
    participant S as server (SnapshotTenantStore)

    CLI->>FS: write destinations.json.tmp → rename
    S->>FS: revision(destinations) changed?
    FS-->>S: new mtime
    S->>FS: reload snapshot
    S-->>S: serve the new destination over REST / OData
```

## Deployment Diagram — SAP BTP (Cloud Foundry)

```mermaid
flowchart LR
    B[Browser<br/>Fiori app] -->|HTTPS| AR[connectivity-approuter<br/>@sap/approuter + resources/]
    AR -->|XSUAA login| X[(connectivity-xsuaa)]
    AR -->|destination connectivity-srv<br/>JWT forwarded| SRV[connectivity-srv<br/>binary buildpack<br/>uim-connectivity-platform-service]
    SRV -->|VCAP_SERVICES| CFG[(connectivity-config<br/>user-provided)]
    SRV --> DISK[(data/*.json<br/>container disk)]
    SCC[Cloud Connector<br/>on premise] -.->|"POST /api/v1/connectors/:id/heartbeat"| AR
    ADM[CLI / GtkD GUI<br/>local] --> DISK2[(backend/data)]
```
