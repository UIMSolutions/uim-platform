# UML — Audit Log Service


## Documentation update

This document is maintained alongside the implementation, deployment manifests, and tests for the same package so the service documentation stays aligned with the codebase.

## Class Diagram — Domain Entities

```mermaid
classDiagram
    class AuditLogEntry {
        +AuditLogEntryId id
        +TenantId tenantId
        +string category
        +string severity
        +string actionType
        +string objectType
        +string objectId
        +string userId
        +string correlationId
        +string message
        +long timestamp
        +Json toJson()
    }
    class SecurityEvent {
        +SecurityEventId id
        +TenantId tenantId
        +AuditLogEntryId auditEntryId
        +string eventType
        +string userId
        +string ipAddress
        +string userAgent
        +string authMethod
        +string idpName
        +string riskLevel
        +long timestamp
        +Json toJson()
    }
    class DataAccessLog {
        +DataAccessLogId id
        +TenantId tenantId
        +AuditLogEntryId auditEntryId
        +string dataSubjectId
        +string dataSubjectType
        +string accessedFields
        +string accessPurpose
        +string accessChannel
        +string userId
        +long timestamp
        +Json toJson()
    }
    class ConfigChangeLog {
        +ConfigChangeLogId id
        +TenantId tenantId
        +AuditLogEntryId auditEntryId
        +string configKey
        +string oldValue
        +string newValue
        +string changeJustification
        +string userId
        +long timestamp
        +Json toJson()
    }
    class RetentionPolicy {
        +RetentionPolicyId id
        +TenantId tenantId
        +string name
        +int retentionDays
        +string category
        +string status
        +bool isDefault
        +Json toJson()
    }
    class AuditConfig {
        +AuditConfigId id
        +TenantId tenantId
        +bool dataAccessEnabled
        +bool dataModificationEnabled
        +bool securityEventsEnabled
        +bool configChangesEnabled
        +string minimumSeverity
        +int rateLimit
        +Json toJson()
    }
    class ExportJob {
        +ExportJobId id
        +TenantId tenantId
        +string exportFormat
        +string category
        +long fromTimestamp
        +long toTimestamp
        +string status
        +string downloadUrl
        +Json toJson()
    }

    AuditLogEntry "1" --> "0..1" SecurityEvent : generates
    AuditLogEntry "1" --> "0..1" DataAccessLog : generates
    AuditLogEntry "1" --> "0..1" ConfigChangeLog : generates
    RetentionPolicy "1" ..> "0..*" AuditLogEntry : governs
    AuditConfig "1" ..> "0..*" AuditLogEntry : configures
    ExportJob ..> AuditLogEntry : exports
```

---

## Deployment / Component Diagram

```mermaid
flowchart LR
    subgraph BTP["SAP BTP · Cloud Foundry (mta.yaml)"]
        AR["approuter<br/>@sap/approuter + Fiori app (resources/)"]
        XS[(XSUAA<br/>auditlog-xsuaa)]
        UPS[(auditlog-config<br/>user-provided)]
        SRV["auditlog-srv<br/>D / vibe.d binary"]
    end
    Browser["Browser<br/>SAP Fiori 3 / UI5"] -->|HTTPS| AR
    AR -->|login / token| XS
    AR -->|"destination auditlog-srv<br/>/odata/v4/auditlog, /api/v1"| SRV
    SRV -.->|VCAP_SERVICES| UPS
    Admin["Administrator"] --> CLI["uim-auditlog-cli"]
    Admin --> GUI["uim-auditlog-gui (GtkD)"]
    CLI & GUI & SRV --- DATA[("JSON snapshots<br/>dataDir")]
```

## Component Diagram — Hexagonal Architecture

```mermaid
flowchart TB
    subgraph Presentation["presentation (driving adapters)"]
        REST["http/controllers<br/>REST /api/v1"]
        OD["odata<br/>AuditLogODataController · EDM model ·<br/>\$metadata · query engine · serializers"]
        CLIA["cli<br/>CliArgs · AuditLogCli"]
        GUIA["gui<br/>AuditLogWindow · TablePage"]
        WEB["web<br/>FrontendController"]
        TAB["tabular<br/>Table projections"]
    end
    subgraph Ports["ports"]
        DP["driving.d — AuditLogPorts<br/>I*UseCase · IAuditStatisticsService"]
        RP["repositories — I*Repository"]
        SP["storages — ISnapshotStorage"]
        MP["messaging — IAuditEventPublisher"]
    end
    subgraph Application["application"]
        UCW["usecases/write<br/>AuditLog · SecurityEvent · DataAccess · ConfigChange"]
        UCR["usecases/retrieve<br/>AuditLogs · Records"]
        UCM["usecases/manage<br/>Retention · AuditConfig · Exports · EnforceRetention"]
        AS["services<br/>AuditStatisticsService"]
    end
    subgraph Domain["domain"]
        ENT["entities · types · enumerations"]
        DS["services<br/>AuditPolicy · AuditFilterService · RetentionEnforcer"]
    end
    subgraph Persistence["persistence (driven adapters)"]
        REPO["repositories ×7"]
        STO["storages<br/>memory · JsonFileSnapshotStorage · SnapshotTenantStore"]
        MAP["mappers · records"]
    end
    subgraph Infrastructure["infrastructure"]
        CFG["configuration<br/>defaults → file → env → VCAP_SERVICES"]
        SEC["security<br/>XSUAA JWT → RequestIdentity"]
        WRK["workers<br/>RetentionWorker"]
        LOG["logging<br/>LogEventPublisher"]
        CTR["container<br/>Container.ports()"]
    end

    REST & OD & CLIA & GUIA --> DP
    CLIA & GUIA --> TAB
    OD --> SEC
    WRK --> DP
    DP -.implemented by.-> UCW & UCR & UCM & AS
    UCW & UCR & UCM & AS --> DS & ENT
    UCW & UCR & UCM & AS --> RP
    UCW & UCM --> MP
    REPO -.implements.-> RP
    REPO --> STO --> SP
    STO --> MAP
    LOG -.implements.-> MP
    CTR --> REPO & UCW & UCR & UCM & AS & CFG
```

## Class Diagram — Driving Adapters

```mermaid
classDiagram
    class AuditLogPorts {
        +IWriteAuditLogUseCase writeAuditLog
        +IRetrieveAuditLogsUseCase retrieveAuditLogs
        +IBrowseAuditRecordsUseCase browseRecords
        +IWriteSecurityEventUseCase writeSecurityEvent
        +IWriteDataAccessLogUseCase writeDataAccessLog
        +IWriteConfigChangeUseCase writeConfigChange
        +IManageRetentionUseCase manageRetention
        +IEnforceRetentionUseCase enforceRetention
        +IManageAuditConfigUseCase manageAuditConfig
        +IManageExportsUseCase manageExports
        +IAuditStatisticsService statistics
    }
    class Container {
        +AuditLogConfig config
        +ports() AuditLogPorts
    }
    class AuditLogODataController {
        -ODataServiceModel model
        +registerRoutes(URLRouter)
    }
    class AuditLogCli {
        +run(string[] argv) int
    }
    class CliArgs {
        +string[] positional
        +string[string] options
        +parse(string[]) CliArgs$
    }
    class AuditLogWindow {
        +refreshAll()
    }
    class TablePage {
        +reload()
        +selectedId() string
    }
    class Table {
        +string[] headers
        +string[][] rows
        +render() string
    }
    Container --> AuditLogPorts
    AuditLogODataController --> AuditLogPorts
    AuditLogCli --> AuditLogPorts
    AuditLogCli --> CliArgs
    AuditLogCli --> Table
    AuditLogWindow --> AuditLogPorts
    AuditLogWindow *-- TablePage
    TablePage --> Table
```

## Sequence Diagram — Fiori reads audit logs

```mermaid
sequenceDiagram
    participant UI as UI5 ODataModel (V4)
    participant AR as approuter
    participant OD as AuditLogODataController
    participant ID as resolveIdentity
    participant UC as IRetrieveAuditLogsUseCase
    participant Q as ODataQuery
    UI->>AR: GET odata/v4/auditlog/AuditLogs?$filter=…&$orderby=timestamp desc&$count=true
    AR->>OD: forward + Bearer JWT
    OD->>ID: Authorization / X-Tenant-Id
    ID-->>OD: RequestIdentity(tenantId, userId)
    OD->>UC: queryAuditLogs(tenant)
    UC-->>OD: AuditLogEntry[]
    OD->>Q: toOData(entries) → filter, order, count, skip/top, select
    Q-->>OD: rows
    OD-->>UI: 200 {"@odata.context", "@odata.count", "value": [...]}
```

## Sequence Diagram — CLI retention enforcement

```mermaid
sequenceDiagram
    actor Admin
    participant CLI as AuditLogCli
    participant UC as EnforceRetentionUseCase
    participant RE as RetentionEnforcer
    participant ST as SnapshotTenantStore (file)
    Admin->>CLI: uim-auditlog-cli retention enforce --tenant=t1
    CLI->>UC: enforce(TenantId("t1"))
    UC->>RE: enforceForTenant(t1)
    RE->>ST: refresh() / remove expired records
    ST-->>RE: removed count (snapshot persisted)
    UC-->>CLI: UsecaseResult("Removed n expired records")
    CLI-->>Admin: exit 0
```

---

## Sequence Diagram — Write Security Event

```mermaid
sequenceDiagram
    participant Client
    participant SEC as SecurityEventController
    participant SUC as ManageSecurityEventsUseCase
    participant AR as AuditLogEntryRepository
    participant SR as ISecurityEventRepository

    Client->>SEC: POST /security-events { eventType=login, userId, ipAddress }
    SEC->>SUC: createSecurityEvent(dto)
    SUC->>AR: save(auditEntry — category=security-events)
    AR-->>SUC: auditEntryId
    SUC->>SR: save(securityEvent — auditEntryId)
    SR-->>SUC: ok
    SUC-->>SEC: UsecaseResult(true, id)
    SEC-->>Client: 201 { id }
```

---

## Sequence Diagram — Export Job

```mermaid
sequenceDiagram
    participant Admin
    participant EC as ExportJobController
    participant EUC as ManageExportJobsUseCase
    participant ER as IExportJobRepository
    participant AR as AuditLogEntryRepository

    Admin->>EC: POST /export-jobs { format=JSON, category=security-events, from, to }
    EC->>EUC: createExportJob(dto)
    EUC->>ER: save(exportJob — status=pending)
    EUC->>AR: findByCategory(category, from, to)
    AR-->>EUC: entries[]
    EUC->>ER: update(status=completed, downloadUrl, recordCount)
    EUC-->>EC: UsecaseResult(true, id)
    EC-->>Admin: 201 { id, downloadUrl }
```
