# UIM AuditLog Platform Service

A microservice for recording, querying, and managing audit logs across
multi-tenant cloud environments, inspired by the
**SAP BTP Audit Log Service**. Built with **D** and **vibe.d**, following
**Clean Architecture** and **Hexagonal Architecture** (Ports & Adapters)
principles.

Part of the [UIM Platform](https://www.sueel.de/uim/sap) suite.

## Features

| Capability | Description |
|---|---|
| **Audit Log Writing** | Write immutable audit log entries with 4 categories (security-events, configuration, data-access, data-modification), 4 severity levels, 19 action types, tenant-scoped configuration checks (category toggles, rate limiting, disabled tenants) |
| **Audit Log Retrieval** | Paginated search with category and time-range filters, lookup by ID, by category, by user, by correlation ID, and tenant-scoped entry counts |
| **Retention Policies** | Full CRUD for retention policies with configurable retention days (SAP default 90), category scoping, active/inactive/expired lifecycle, and default-policy designation |
| **Audit Configuration** | Per-tenant audit config with category toggles (data access, data modification, security events, config changes), data masking (field-level), service exclusion lists, minimum severity thresholds, and rate limiting |
| **Export Jobs** | Create export jobs (JSON/CSV) filtered by category and time range, list and retrieve export status, immediate export simulation with record counts and download URLs |
| **Security Events** | Enriched security event recording — login/logout, auth failures, MFA, token operations — with automatic parent audit log entry creation, IP/user-agent/IdP/auth-method tracking, risk-level classification |
| **Data Access Logging** | GDPR-aligned data access tracking — records who accessed whose data, which fields, for what purpose, through which channel — with automatic parent audit entry |
| **Config Change Logging** | Tracks security-critical configuration changes with old/new value pairs, change justification, and automatic parent audit entry |
| **Retention Enforcement** | Domain service that purges expired audit data across all log types (audit entries, security events, data access logs, config change logs) based on tenant retention policies |
| **Health Check** | Service liveness endpoint |

## Architecture

```
auditlog/
├── source/
│   ├── app.d                                       # Entry point & composition root
│   ├── domain/                                     # Pure business logic (no dependencies)
│   │   ├── types.d                                 #   7 type aliases & 8 enums
│   │   ├── entities/                               #   Core domain structs
│   │   │   ├── audit_log_entry.d                   #     Immutable audit record + AuditAttribute
│   │   │   ├── audit_config.d                      #     Tenant-level audit configuration
│   │   │   ├── retention_policy.d                  #     Retention policy with category scoping
│   │   │   ├── export_job.d                        #     Export job with status & download URL
│   │   │   ├── security_event.d                    #     Enriched security event record
│   │   │   ├── data_access_log.d                   #     GDPR data access tracking record
│   │   │   └── config_change_log.d                 #     Configuration change tracking record
│   │   ├── ports/                                  #   Repository interfaces (ports)
│   │   │   ├── audit_log_repository.d              #     search, findByCategory/User/Correlation, CRUD
│   │   │   ├── audit_config_repository.d           #     findByTenant, findAll, CRUD
│   │   │   ├── retention_policy_repository.d       #     findDefault, findByTenant, CRUD
│   │   │   ├── export_job_repository.d             #     findByTenant, CRUD
│   │   │   ├── security_event_repository.d         #     findByUser/Outcome/TimeRange, CRUD
│   │   │   ├── data_access_log_repository.d        #     findByAccessor/DataSubject/TimeRange, CRUD
│   │   │   └── config_change_log_repository.d      #     findByUser/ConfigType/TimeRange, CRUD
│   │   └── services/                               #   Stateless domain services
│   │       ├── audit_filter_service.d              #     Paginated search, correlation lookup, counts
│   │       └── retention_enforcer.d                #     Purge expired entries across all log types
│   ├── application/                                #   Application layer (use cases)
│   │   ├── dto.d                                   #     Request DTOs & CommandResult
│   │   └── usecases/                              #     Application services
│   │       ├── write_audit_log.d                   #       Write audit entry with config checks
│   │       ├── retrieve_audit_logs.d               #       Query, getById, getByCategory/User/Correlation
│   │       ├── manage.retention.d                  #       Retention policy CRUD
│   │       ├── manage.audit_config.d               #       Audit config CRUD (one per tenant)
│   │       ├── manage.exports.d                    #       Export job create/list/get/delete
│   │       ├── write_security_event.d              #       Write enriched security event + parent log
│   │       ├── write_data_access_log.d             #       Write data access record + parent log
│   │       └── write_config_change.d               #       Write config change record + parent log
│   ├── infrastructure/                             #   Technical adapters
│   │   ├── config.d                                #     Environment-based configuration
│   │   ├── container.d                             #     Dependency injection wiring
│   │   └── persistence/                            #     In-memory repository implementations
│   │       ├── in_memory_audit_log_repo.d
│   │       ├── in_memory_retention_repo.d
│   │       ├── in_memory_audit_config_repo.d
│   │       ├── in_memory_export_repo.d
│   │       ├── in_memory_security_event_repo.d
│   │       ├── in_memory_data_access_repo.d
│   │       └── in_memory_config_change_repo.d
│   └── presentation/                               #   HTTP driving adapters
│       └── http/
│           ├── health_controller.d
│           ├── audit_log_controller.d
│           ├── retention_controller.d
│           ├── audit_config_controller.d
│           ├── export_controller.d
│           ├── security_event_controller.d
│           ├── data_access_controller.d
│           └── config_change_controller.d
└── dub.sdl
```

## REST API

### Audit Logs

```
POST   /api/v1/auditlog                    Write an audit log entry
GET    /api/v1/auditlog                    Query audit logs (paginated, filtered)
GET    /api/v1/auditlog/{id}              Get audit log entry by ID
```

### Retention Policies

```
POST   /api/v1/retention                   Create a retention policy
GET    /api/v1/retention                   List retention policies for tenant
GET    /api/v1/retention/{id}             Get retention policy by ID
PUT    /api/v1/retention/{id}             Update a retention policy
DELETE /api/v1/retention/{id}             Delete a retention policy
```

### Audit Configuration

```
POST   /api/v1/configs                     Create audit config (one per tenant)
GET    /api/v1/configs                     List all audit configurations
GET    /api/v1/configs/{tenantId}          Get audit config by tenant
PUT    /api/v1/configs/{id}               Update audit config
DELETE /api/v1/configs/{id}               Delete audit config
```

### Export Jobs

```
POST   /api/v1/exports                     Create an export job
GET    /api/v1/exports                     List export jobs for tenant
GET    /api/v1/exports/{id}               Get export job by ID
DELETE /api/v1/exports/{id}               Delete an export job
```

### Security Events

```
POST   /api/v1/security-events             Write a security event
```

### Data Access Logs

```
POST   /api/v1/data-access                 Write a data access log
```

### Config Change Logs

```
POST   /api/v1/config-changes              Write a config change log
```

### Health

```
GET    /api/v1/health                      → {"status":"UP","service":"auditlog"}
```

## Build and Run

```bash
# Build
cd auditlog
dub build

# Run (default: 0.0.0.0:8085)
./build/uim-auditlog-platform-service

# Override host/port via environment
AL_HOST=127.0.0.1 AL_PORT=9090 ./build/uim-auditlog-platform-service
```

## Configuration

| Variable | Default | Description |
|---|---|---|
| `AL_HOST` | `0.0.0.0` | HTTP bind address |
| `AL_PORT` | `8085` | HTTP listen port |

## Domain Model Overview

### Type Aliases

| Alias | Underlying | Purpose |
|---|---|---|
| `AuditLogId` | `string` | Audit log entry identifier |
| `RetentionPolicyId` | `string` | Retention policy identifier |
| `AuditConfigId` | `string` | Audit config identifier |
| `ExportJobId` | `string` | Export job identifier |
| `TenantId` | `string` | Tenant identifier |
| `UserId` | `string` | User identifier |
| `ServiceId` | `string` | Originating service identifier |

### Enumerations

| Enum | Values |
|---|---|
| **AuditCategory** | securityEvents, configuration, dataAccess, dataModification |
| **AuditSeverity** | info, warning, error, critical |
| **AuditAction** | create, read_, update, delete_, login, logout, loginFailed, passwordChange, roleAssign, roleRevoke, policyChange, configChange, export_, dataAccess, consentChange, tokenIssue, tokenRevoke, mfaEnroll, mfaVerify |
| **AuditOutcome** | success, failure, denied, error |
| **RetentionStatus** | active, inactive, expired |
| **ExportStatus** | pending, inProgress, completed, failed |
| **ExportFormat** | json, csv |
| **ConfigStatus** | enabled, disabled |

### Domain Services

- **AuditFilterService** — provides paginated search over audit log entries with optional category and time-range filters, correlation-based lookup across services, and tenant-scoped entry counts
- **RetentionEnforcer** — enforces retention policies by purging entries older than the tenant's configured retention period (default 90 days) across all four log stores (audit entries, security events, data access logs, config change logs)

---

## UML – Architecture Diagram (PlantUML)

```plantuml
@startuml AuditLog Service – Hexagonal Architecture

!define PRESENTATION_COLOR #E3F2FD
!define APPLICATION_COLOR  #FFF3E0
!define DOMAIN_COLOR       #E8F5E9
!define INFRA_COLOR        #F3E5F5
!define PORT_COLOR         #E1F5FE
!define SERVICE_COLOR      #FFF8E1

skinparam @safe: class {
  BackgroundColor    WHITE
  BorderColor        #37474F
  ArrowColor         #37474F
  FontSize           11
}

skinparam package {
  FontSize          12
  FontStyle         bold
  BorderThickness   2
}

title UIM AuditLog Platform Service\nClean + Hexagonal Architecture

' ============================================================
' PRESENTATION LAYER (Driving Adapters)
' ============================================================

package "Presentation Layer  «driving adapters»" as PRES <<Rectangle>> {
  skinparam packageBackgroundColor PRESENTATION_COLOR

  @safe: class AuditLogController << (H,#EF5350) >> {
    POST   /api/v1/auditlog
    GET    /api/v1/auditlog
    GET    /api/v1/auditlog/{id}
  }

  @safe: class RetentionController << (H,#EF5350) >> {
    POST   /api/v1/retention
    GET    /api/v1/retention
    GET    /api/v1/retention/{id}
    PUT    /api/v1/retention/{id}
    DELETE /api/v1/retention/{id}
  }

  @safe: class AuditConfigController << (H,#EF5350) >> {
    POST   /api/v1/configs
    GET    /api/v1/configs
    GET    /api/v1/configs/{tenantId}
    PUT    /api/v1/configs/{id}
    DELETE /api/v1/configs/{id}
  }

  @safe: class ExportController << (H,#EF5350) >> {
    POST   /api/v1/exports
    GET    /api/v1/exports
    GET    /api/v1/exports/{id}
    DELETE /api/v1/exports/{id}
  }

  @safe: class SecurityEventController << (H,#EF5350) >> {
    POST /api/v1/security-events
  }

  @safe: class DataAccessController << (H,#EF5350) >> {
    POST /api/v1/data-access
  }

  @safe: class ConfigChangeController << (H,#EF5350) >> {
    POST /api/v1/config-changes
  }

  @safe: class HealthController << (H,#EF5350) >> {
    GET /api/v1/health
  }
}

' ============================================================
' APPLICATION LAYER (Use Cases)
' ============================================================

package "Application Layer  «use cases»" as APP <<Rectangle>> {
  skinparam packageBackgroundColor APPLICATION_COLOR

  @safe: class WriteAuditLogUseCase << (U,#FF7043) >> {
    + writeLog(req) : CommandResult
  }

  @safe: class RetrieveAuditLogsUseCase << (U,#FF7043) >> {
    + query(req) : AuditLogEntry[]
    + getById(tenantId, id) : AuditLogEntry*
    + getByCategory(tenantId, cat) : AuditLogEntry[]
    + getByUser(tenantId, userId) : AuditLogEntry[]
    + getByCorrelation(corrId) : AuditLogEntry[]
    + count(tenantId) : long
  }

  @safe: class ManageRetentionUseCase << (U,#FF7043) >> {
    + createPolicy(req) : CommandResult
    + getPolicy(tenantId, id) : RetentionPolicy*
    + listPolicies(tenantId) : RetentionPolicy[]
    + updatePolicy(req) : CommandResult
    + deletePolicy(tenantId, id) : void
  }

  @safe: class ManageAuditConfigUseCase << (U,#FF7043) >> {
    + createConfig(req) : CommandResult
    + getConfig(tenantId) : AuditConfig*
    + listConfigs() : AuditConfig[]
    + updateConfig(req) : CommandResult
    + deleteConfig(tenantId, id) : void
  }

  @safe: class ManageExportsUseCase << (U,#FF7043) >> {
    + createExport(req) : CommandResult
    + getExport(tenantId, id) : ExportJob*
    + listExports(tenantId) : ExportJob[]
    + deleteExport(tenantId, id) : void
  }

  @safe: class WriteSecurityEventUseCase << (U,#FF7043) >> {
    + writeEvent(req) : CommandResult
  }

  @safe: class WriteDataAccessLogUseCase << (U,#FF7043) >> {
    + writeLog(req) : CommandResult
  }

  @safe: class WriteConfigChangeUseCase << (U,#FF7043) >> {
    + writeChange(req) : CommandResult
  }
}

' ============================================================
' DOMAIN LAYER (Entities, Ports, Services)
' ============================================================

package "Domain Layer  «core business logic»" as DOM <<Rectangle>> {
  skinparam packageBackgroundColor DOMAIN_COLOR

  package "Entities" as ENT {
    @safe: class AuditLogEntry << (E,#66BB6A) >> {
      id : AuditLogId
      tenantId : TenantId
      userId : UserId
      category : AuditCategory
      severity : AuditSeverity
      action : AuditAction
      outcome : AuditOutcome
      attributes : AuditAttribute[]
      correlationId : string
      timestamp : long
    }

    @safe: class AuditConfig << (E,#66BB6A) >> {
      id : AuditConfigId
      tenantId : TenantId
      status : ConfigStatus
      logDataAccess : bool
      logDataModification : bool
      logSecurityEvents : bool
      logConfigurationChanges : bool
      enableDataMasking : bool
      maskedFields : string[]
      excludedServices : string[]
      minimumSeverity : AuditSeverity
      rateLimitPerSecond : int
    }

    @safe: class RetentionPolicy << (E,#66BB6A) >> {
      id : RetentionPolicyId
      tenantId : TenantId
      retentionDays : int
      categories : AuditCategory[]
      status : RetentionStatus
      isDefault : bool
    }

    @safe: class ExportJob << (E,#66BB6A) >> {
      id : ExportJobId
      tenantId : TenantId
      format_ : ExportFormat
      status : ExportStatus
      categories : AuditCategory[]
      totalRecords : long
      downloadUrl : string
    }

    @safe: class SecurityEvent << (E,#66BB6A) >> {
      auditLogId : AuditLogId
      tenantId : TenantId
      userId : UserId
      eventType : string
      authMethod : string
      outcome : AuditOutcome
      riskLevel : string
    }

    @safe: class DataAccessLog << (E,#66BB6A) >> {
      auditLogId : AuditLogId
      tenantId : TenantId
      accessedBy : UserId
      dataSubject : string
      accessedFields : string[]
      purpose : string
      channel : string
    }

    @safe: class ConfigChangeLog << (E,#66BB6A) >> {
      auditLogId : AuditLogId
      tenantId : TenantId
      changedBy : UserId
      configType : string
      changes : AuditAttribute[]
      reason : string
    }
  }

  package "Ports  «interfaces»" as PORTS {
    @safe: interface  AuditLogRepository << (P,#42A5F5) >> {
      + findByTenant(tenantId) : AuditLogEntry[]
      + findById(tenantId, id) : AuditLogEntry*
      + search(tenantId, categories, from, to, limit, offset) : AuditLogEntry[]
      + countByTenant(tenantId) : long
      + save(entry) : void
      + removeOlderThan(tenantId, before) : void
    }

    @safe: interface  AuditConfigRepository << (P,#42A5F5) >> {
      + findAll() : AuditConfig[]
      + findByTenant(tenantId) : AuditConfig*
      + findById(id) : AuditConfig*
      + save(config) : void
      + update(config) : void
      + removeById(tenantId, id) : void
    }

    @safe: interface  RetentionPolicyRepository << (P,#42A5F5) >> {
      + findByTenant(tenantId) : RetentionPolicy[]
      + findById(tenantId, id) : RetentionPolicy*
      + findDefault(tenantId) : RetentionPolicy*
      + save(policy) : void
      + update(policy) : void
      + removeById(tenantId, id) : void
    }

    @safe: interface  ExportJobRepository << (P,#42A5F5) >> {
      + findByTenant(tenantId) : ExportJob[]
      + findById(tenantId, id) : ExportJob*
      + save(job) : void
      + update(job) : void
      + removeById(tenantId, id) : void
    }

    @safe: interface  SecurityEventRepository << (P,#42A5F5) >> {
      + findByTenant(tenantId) : SecurityEvent[]
      + findByUser(tenantId, userId) : SecurityEvent[]
      + findByOutcome(tenantId, outcome) : SecurityEvent[]
      + save(event) : void
      + removeOlderThan(tenantId, before) : void
    }

    @safe: interface  DataAccessLogRepository << (P,#42A5F5) >> {
      + findByTenant(tenantId) : DataAccessLog[]
      + findByAccessor(tenantId, userId) : DataAccessLog[]
      + findByDataSubject(tenantId, subject) : DataAccessLog[]
      + save(log) : void
      + removeOlderThan(tenantId, before) : void
    }

    @safe: interface  ConfigChangeLogRepository << (P,#42A5F5) >> {
      + findByTenant(tenantId) : ConfigChangeLog[]
      + findByUser(tenantId, userId) : ConfigChangeLog[]
      + findByConfigType(tenantId, type) : ConfigChangeLog[]
      + save(log) : void
      + removeOlderThan(tenantId, before) : void
    }
  }

  package "Domain Services" as DSVC {
    @safe: class AuditFilterService << (S,#FFCA28) >> {
      + search(tenantId, categories, from, to, limit, offset)
      + findCorrelated(correlationId)
      + countForTenant(tenantId)
    }

    @safe: class RetentionEnforcer << (S,#FFCA28) >> {
      + enforceForTenant(tenantId) : long
    }
  }
}

' ============================================================
' INFRASTRUCTURE LAYER (Driven Adapters)
' ============================================================

package "Infrastructure Layer  «driven adapters»" as INFRA <<Rectangle>> {
  skinparam packageBackgroundColor INFRA_COLOR

  @safe: class MemoryAuditLogRepository << (A,#AB47BC) >>
  @safe: class MemoryAuditConfigRepository << (A,#AB47BC) >>
  @safe: class MemoryRetentionPolicyRepository << (A,#AB47BC) >>
  @safe: class MemoryExportJobRepository << (A,#AB47BC) >>
  @safe: class MemorySecurityEventRepository << (A,#AB47BC) >>
  @safe: class MemoryDataAccessLogRepository << (A,#AB47BC) >>
  @safe: class MemoryConfigChangeLogRepository << (A,#AB47BC) >>
}

' ============================================================
' RELATIONSHIPS
' ============================================================

' Controllers → Use Cases
AuditLogController --> WriteAuditLogUseCase
AuditLogController --> RetrieveAuditLogsUseCase
RetentionController --> ManageRetentionUseCase
AuditConfigController --> ManageAuditConfigUseCase
ExportController --> ManageExportsUseCase
SecurityEventController --> WriteSecurityEventUseCase
DataAccessController --> WriteDataAccessLogUseCase
ConfigChangeController --> WriteConfigChangeUseCase

' Use Cases → Ports
WriteAuditLogUseCase --> AuditLogRepository
WriteAuditLogUseCase --> AuditConfigRepository
RetrieveAuditLogsUseCase --> AuditLogRepository
ManageRetentionUseCase --> RetentionPolicyRepository
ManageAuditConfigUseCase --> AuditConfigRepository
ManageExportsUseCase --> ExportJobRepository
ManageExportsUseCase --> AuditLogRepository
WriteSecurityEventUseCase --> AuditLogRepository
WriteSecurityEventUseCase --> SecurityEventRepository
WriteDataAccessLogUseCase --> AuditLogRepository
WriteDataAccessLogUseCase --> DataAccessLogRepository
WriteConfigChangeUseCase --> AuditLogRepository
WriteConfigChangeUseCase --> ConfigChangeLogRepository

' Domain Services → Ports
AuditFilterService --> AuditLogRepository
RetentionEnforcer --> AuditLogRepository
RetentionEnforcer --> RetentionPolicyRepository
RetentionEnforcer --> SecurityEventRepository
RetentionEnforcer --> DataAccessLogRepository
RetentionEnforcer --> ConfigChangeLogRepository

' Use Cases → Entities
WriteAuditLogUseCase ..> AuditLogEntry
RetrieveAuditLogsUseCase ..> AuditLogEntry
ManageRetentionUseCase ..> RetentionPolicy
ManageAuditConfigUseCase ..> AuditConfig
ManageExportsUseCase ..> ExportJob
WriteSecurityEventUseCase ..> SecurityEvent
WriteSecurityEventUseCase ..> AuditLogEntry
WriteDataAccessLogUseCase ..> DataAccessLog
WriteDataAccessLogUseCase ..> AuditLogEntry
WriteConfigChangeUseCase ..> ConfigChangeLog
WriteConfigChangeUseCase ..> AuditLogEntry

' Infrastructure implements Ports
MemoryAuditLogRepository ..|> AuditLogRepository
MemoryAuditConfigRepository ..|> AuditConfigRepository
MemoryRetentionPolicyRepository ..|> RetentionPolicyRepository
MemoryExportJobRepository ..|> ExportJobRepository
MemorySecurityEventRepository ..|> SecurityEventRepository
MemoryDataAccessLogRepository ..|> DataAccessLogRepository
MemoryConfigChangeLogRepository ..|> ConfigChangeLogRepository

@enduml
```

## Testing

```bash
dub test
```

## License

See the repository root [LICENSE](../LICENSE) file.
