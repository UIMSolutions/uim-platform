# AuditLog Service – NAF v4 Architecture Description

This document describes the **UIM AuditLog Platform Service**
using the **NATO Architecture Framework v4 (NAF v4)** viewpoints, adapted for
a microservice based on SAP BTP Audit Log Service concepts.

---

## 1. NAF v4 Grid Mapping

| Viewpoint | View | Section |
|---|---|---|
| **NCV** – Capability | C1 – Capability Taxonomy | §2 |
| **NCV** – Capability | C2 – Enterprise Vision | §2 |
| **NSOV** – Service | NSOV-1 – Service Taxonomy | §3 |
| **NSOV** – Service | NSOV-2 – Service Definitions | §3 |
| **NOV** – Operational | NOV-2 – Operational Node Connectivity | §4 |
| **NLV** – Logical | NLV-1 – Logical Data Model | §5 |
| **NPV** – Physical | NPV-1 – Physical Deployment | §6 |
| **NIV** – Information | NIV-1 – Information Structure | §7 |

---

## 2. Capability View (NCV)

### C1 – Capability Taxonomy

```
C1  Audit Logging Capability
├── C1.1  Audit Log Writing
│   ├── C1.1.1  Immutable Entry Creation (UUID-based, timestamped)
│   ├── C1.1.2  Category Classification (security-events, configuration, data-access, data-modification)
│   ├── C1.1.3  Severity Levels (info, warning, error, critical)
│   ├── C1.1.4  19 Action Types (CRUD, auth, token, MFA, consent, policy, export)
│   ├── C1.1.5  Outcome Tracking (success, failure, denied, error)
│   ├── C1.1.6  Attribute Change Tracking (old/new value pairs)
│   ├── C1.1.7  Correlation ID for Cross-Service Tracing
│   └── C1.1.8  Tenant Config Checks (category toggles, disabled tenants)
├── C1.2  Audit Log Retrieval
│   ├── C1.2.1  Paginated Search (category + time range filters)
│   ├── C1.2.2  Lookup by ID
│   ├── C1.2.3  Lookup by Category
│   ├── C1.2.4  Lookup by User
│   ├── C1.2.5  Correlation-Based Search (cross-service trace)
│   └── C1.2.6  Tenant-Scoped Entry Counts
├── C1.3  Retention Policy Management
│   ├── C1.3.1  Policy Provisioning (create, update, delete)
│   ├── C1.3.2  Configurable Retention Days (default 90)
│   ├── C1.3.3  Category Scoping
│   ├── C1.3.4  Active / Inactive / Expired Lifecycle
│   ├── C1.3.5  Default Policy Designation
│   └── C1.3.6  Automated Purge via RetentionEnforcer
├── C1.4  Audit Configuration
│   ├── C1.4.1  Per-Tenant Config (one per tenant)
│   ├── C1.4.2  Category Toggles (data access, modification, security, config)
│   ├── C1.4.3  Data Masking (field-level sensitive field redaction)
│   ├── C1.4.4  Service Exclusion Lists
│   ├── C1.4.5  Minimum Severity Threshold
│   └── C1.4.6  Per-Tenant Rate Limiting
├── C1.5  Export Management
│   ├── C1.5.1  Export Job Creation (JSON / CSV)
│   ├── C1.5.2  Category & Time Range Filtering
│   ├── C1.5.3  Status Tracking (pending, inProgress, completed, failed)
│   ├── C1.5.4  Record Count & Download URL
│   └── C1.5.5  Job Listing & Deletion
├── C1.6  Security Event Tracking
│   ├── C1.6.1  Authentication Events (login, logout, loginFailed)
│   ├── C1.6.2  MFA Events (mfaEnroll, mfaVerify)
│   ├── C1.6.3  Token Events (tokenIssue, tokenRevoke)
│   ├── C1.6.4  IP / User-Agent / IdP / Auth-Method Tracking
│   ├── C1.6.5  Risk Level Classification (low, medium, high)
│   └── C1.6.6  Automatic Parent Audit Log Entry
├── C1.7  Data Access Logging
│   ├── C1.7.1  GDPR-Aligned Access Tracking
│   ├── C1.7.2  Data Subject Identification
│   ├── C1.7.3  Accessed Fields Recording
│   ├── C1.7.4  Purpose & Channel Documentation
│   └── C1.7.5  Automatic Parent Audit Log Entry
├── C1.8  Config Change Logging
│   ├── C1.8.1  Security-Critical Change Tracking
│   ├── C1.8.2  Old / New Value Pairs
│   ├── C1.8.3  Change Justification (reason)
│   └── C1.8.4  Automatic Parent Audit Log Entry
└── C1.9  Health & Readiness
    └── C1.9.1  Service Liveness Check
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide a centralised, immutable audit logging hub for recording, querying, and managing compliance-relevant events across multi-tenant cloud environments |
| **Vision** | A unified audit trail that captures security events, data access, configuration changes, and operational actions with full traceability, retention enforcement, and export capabilities |
| **Strategic Goal** | Enable regulatory compliance (GDPR, SOX, ISO 27001) through immutable event recording, configurable retention policies, data masking, and structured export of audit data |
| **Scope** | Manages audit log entries, retention policies, tenant configurations, export jobs, security events, data access logs, and config change logs |
| **Stakeholders** | Compliance Officers, Security Auditors, Data Protection Officers, Platform Administrators, Application Developers |

---

## 3. Service View (NSOV)

### NSOV-1 – Service Taxonomy

```
NSOV-1  AuditLog Services
├── SVC-LOG     Audit Log Write / Query Services
├── SVC-RET     Retention Policy Management Services
├── SVC-CFG     Audit Configuration Services
├── SVC-EXP     Export Job Management Services
├── SVC-SEC     Security Event Services
├── SVC-DAL     Data Access Log Services
├── SVC-CCL     Config Change Log Services
└── SVC-HEALTH  Health / Readiness Services
```

### NSOV-2 – Service Definitions

| Service ID | Name | @safe: interface  | Protocol | Path | Methods |
|---|---|---|---|---|---|
| SVC-LOG-WRITE | Write Audit Log | REST | HTTP/JSON | `/api/v1/auditlog` | POST |
| SVC-LOG-QUERY | Query Audit Logs | REST | HTTP/JSON | `/api/v1/auditlog` | GET |
| SVC-LOG-GET | Get Audit Log Entry | REST | HTTP/JSON | `/api/v1/auditlog/{id}` | GET |
| SVC-RET-CREATE | Create Retention Policy | REST | HTTP/JSON | `/api/v1/retention` | POST |
| SVC-RET-LIST | List Retention Policies | REST | HTTP/JSON | `/api/v1/retention` | GET |
| SVC-RET-GET | Get Retention Policy | REST | HTTP/JSON | `/api/v1/retention/{id}` | GET |
| SVC-RET-UPDATE | Update Retention Policy | REST | HTTP/JSON | `/api/v1/retention/{id}` | PUT |
| SVC-RET-DELETE | Delete Retention Policy | REST | HTTP/JSON | `/api/v1/retention/{id}` | DELETE |
| SVC-CFG-CREATE | Create Audit Config | REST | HTTP/JSON | `/api/v1/configs` | POST |
| SVC-CFG-LIST | List Audit Configs | REST | HTTP/JSON | `/api/v1/configs` | GET |
| SVC-CFG-GET | Get Audit Config | REST | HTTP/JSON | `/api/v1/configs/{tenantId}` | GET |
| SVC-CFG-UPDATE | Update Audit Config | REST | HTTP/JSON | `/api/v1/configs/{id}` | PUT |
| SVC-CFG-DELETE | Delete Audit Config | REST | HTTP/JSON | `/api/v1/configs/{id}` | DELETE |
| SVC-EXP-CREATE | Create Export Job | REST | HTTP/JSON | `/api/v1/exports` | POST |
| SVC-EXP-LIST | List Export Jobs | REST | HTTP/JSON | `/api/v1/exports` | GET |
| SVC-EXP-GET | Get Export Job | REST | HTTP/JSON | `/api/v1/exports/{id}` | GET |
| SVC-EXP-DELETE | Delete Export Job | REST | HTTP/JSON | `/api/v1/exports/{id}` | DELETE |
| SVC-SEC-WRITE | Write Security Event | REST | HTTP/JSON | `/api/v1/security-events` | POST |
| SVC-DAL-WRITE | Write Data Access Log | REST | HTTP/JSON | `/api/v1/data-access` | POST |
| SVC-CCL-WRITE | Write Config Change Log | REST | HTTP/JSON | `/api/v1/config-changes` | POST |
| SVC-HEALTH | Health Check | REST | HTTP/JSON | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

### NOV-2 – Operational Node Connectivity

```
                     ┌──────────────────────────────────┐
                     │          HTTP Clients             │
                     │  (Platform Services / Admin UI /  │
                     │   Compliance Tooling / SIEM)      │
                     └──────────────┬───────────────────┘
                                    │ HTTP / JSON
                                    ▼
                     ┌──────────────────────────────────┐
                     │    Presentation Layer             │
                     │  ┌────────────────────────────┐  │
                     │  │ AuditLogController          │  │
                     │  │ RetentionController         │  │
                     │  │ AuditConfigController       │  │
                     │  │ ExportController            │  │
                     │  │ SecurityEventController     │  │
                     │  │ DataAccessController        │  │
                     │  │ ConfigChangeController      │  │
                     │  │ HealthController            │  │
                     │  └────────────┬───────────────┘  │
                     └───────────────┼──────────────────┘
                                     │
                                     ▼
                     ┌──────────────────────────────────┐
                     │    Application Layer              │
                     │  ┌────────────────────────────┐  │
                     │  │ WriteAuditLogUseCase        │  │
                     │  │ RetrieveAuditLogsUseCase    │  │
                     │  │ ManageRetentionUseCase      │  │
                     │  │ ManageAuditConfigUseCase    │  │
                     │  │ ManageExportsUseCase        │  │
                     │  │ WriteSecurityEventUseCase   │  │
                     │  │ WriteDataAccessLogUseCase   │  │
                     │  │ WriteConfigChangeUseCase    │  │
                     │  └────────────┬───────────────┘  │
                     └───────────────┼──────────────────┘
                                     │
               ┌─────────────────────┼─────────────────────┐
               ▼                     ▼                     ▼
  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
  │  Domain Entities  │  │  Domain Ports     │  │ Domain Services   │
  │                   │  │  (interfaces)     │  │                   │
  │  AuditLogEntry    │  │  AuditLogRepo     │  │  AuditFilter-     │
  │  AuditConfig      │  │  AuditConfigRepo  │  │   Service         │
  │  RetentionPolicy  │  │  RetentionRepo    │  │  Retention-       │
  │  ExportJob        │  │  ExportJobRepo    │  │   Enforcer        │
  │  SecurityEvent    │  │  SecurityEventRep │  │                   │
  │  DataAccessLog    │  │  DataAccessLogRep │  │                   │
  │  ConfigChangeLog  │  │  ConfigChangeRep  │  │                   │
  └──────────────────┘  └────────┬─────────┘  └───────────────────┘
                                 │
                                 ▼
                     ┌──────────────────────────────────┐
                     │   Infrastructure Layer            │
                     │  ┌────────────────────────────┐  │
                     │  │ InMemoryAuditLogRepo        │  │
                     │  │ InMemoryAuditConfigRepo     │  │
                     │  │ InMemoryRetentionRepo       │  │
                     │  │ InMemoryExportJobRepo       │  │
                     │  │ InMemorySecurityEventRepo   │  │
                     │  │ InMemoryDataAccessRepo      │  │
                     │  │ InMemoryConfigChangeRepo    │  │
                     │  └────────────────────────────┘  │
                     └──────────────────────────────────┘
```

### Operational Information Exchanges (OIE)

| OIE | From | To | Payload | Description |
|---|---|---|---|---|
| OIE-1 | HTTP Client | AuditLogController | `WriteAuditLogRequest` (JSON) | Write an immutable audit log entry |
| OIE-2 | HTTP Client | AuditLogController | Query parameters / `X-Tenant-Id` header | Paginated audit log search |
| OIE-3 | HTTP Client | RetentionController | `CreateRetentionPolicyRequest` / `UpdateRetentionPolicyRequest` | Manage retention policies |
| OIE-4 | HTTP Client | AuditConfigController | `CreateAuditConfigRequest` / `UpdateAuditConfigRequest` | Manage per-tenant audit configuration |
| OIE-5 | HTTP Client | ExportController | `CreateExportJobRequest` | Create or query export jobs |
| OIE-6 | HTTP Client | SecurityEventController | `WriteSecurityEventRequest` | Record enriched security events |
| OIE-7 | HTTP Client | DataAccessController | `WriteDataAccessLogRequest` | Record GDPR data access events |
| OIE-8 | HTTP Client | ConfigChangeController | `WriteConfigChangeLogRequest` | Record security-critical config changes |
| OIE-9 | HTTP Client | HealthController | — | Service liveness probe |

---

## 5. Logical View (NLV)

### NLV-1 – Logical Data Model

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Audit Log Entry                                 │
│                                                                     │
│  AuditLogId · TenantId · UserId · ServiceId                        │
│  AuditCategory (4) · AuditSeverity (4)                             │
│  AuditAction (19) · AuditOutcome (4)                               │
│  objectType · objectId · message · correlationId                    │
│  AuditAttribute[] (name, oldValue, newValue)                        │
│  ipAddress · userAgent · originApp · timestamp                      │
├─────────────────────────────────────────────────────────────────────┤
│                     Audit Configuration                             │
│                                                                     │
│  AuditConfigId · TenantId · name · ConfigStatus (2)                │
│  logDataAccess · logDataModification · logSecurityEvents            │
│  logConfigurationChanges · enableDataMasking                        │
│  maskedFields[] · excludedServices[]                                │
│  minimumSeverity : AuditSeverity · rateLimitPerSecond : int         │
├─────────────────────────────────────────────────────────────────────┤
│                  Retention & Export                                  │
│                                                                     │
│  RetentionPolicy: RetentionPolicyId · TenantId · retentionDays     │
│    categories[] · RetentionStatus (3) · isDefault                   │
│  ExportJob: ExportJobId · TenantId · ExportFormat (2)               │
│    ExportStatus (4) · categories[] · totalRecords · downloadUrl     │
├─────────────────────────────────────────────────────────────────────┤
│               Enriched Event Logs                                   │
│                                                                     │
│  SecurityEvent: auditLogId · eventType · authMethod · clientId      │
│    identityProvider · AuditOutcome · failureReason · riskLevel      │
│  DataAccessLog: auditLogId · accessedBy · dataSubject               │
│    dataObjectType · accessedFields[] · purpose · channel            │
│  ConfigChangeLog: auditLogId · changedBy · configType               │
│    configObjectId · AuditAttribute[] changes · reason               │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Enumerations

| Enum | Count | Members |
|---|---|---|
| AuditCategory | 4 | securityEvents, configuration, dataAccess, dataModification |
| AuditSeverity | 4 | info, warning, error, critical |
| AuditAction | 19 | create, read_, update, delete_, login, logout, loginFailed, passwordChange, roleAssign, roleRevoke, policyChange, configChange, export_, dataAccess, consentChange, tokenIssue, tokenRevoke, mfaEnroll, mfaVerify |
| AuditOutcome | 4 | success, failure, denied, error |
| RetentionStatus | 3 | active, inactive, expired |
| ExportStatus | 4 | pending, inProgress, completed, failed |
| ExportFormat | 2 | json, csv |
| ConfigStatus | 2 | enabled, disabled |

---

## 6. Physical View (NPV)

### NPV-1 – Physical Deployment

```
┌─────────────────────────────────────────────────┐
│               Container / VM                     │
│                                                  │
│  ┌───────────────────────────────────────────┐   │
│  │   uim-auditlog-platform-service          │   │
│  │   (single D/vibe.d executable)            │   │
│  │                                           │   │
│  │   Listening: 0.0.0.0:8085                 │   │
│  │   Env: AL_HOST, AL_PORT                   │   │
│  │                                           │   │
│  │   ┌─────────────────────────────────────┐ │   │
│  │   │  In-Memory Stores                   │ │   │
│  │   │  (AuditLog, AuditConfig, Retention, │ │   │
│  │   │   Export, SecurityEvent,            │ │   │
│  │   │   DataAccessLog, ConfigChangeLog)   │ │   │
│  │   └─────────────────────────────────────┘ │   │
│  └───────────────────────────────────────────┘   │
│                                                  │
│  Binary: build/uim-auditlog-platform-service     │
│  Build:  dub build                               │
└─────────────────────────────────────────────────┘
```

### Deployment Constraints

| # | Constraint |
|---|---|
| 1 | Single statically-linked executable; no external runtime beyond libc/pthreads |
| 2 | Default port **8085**; overridable via `AL_PORT` environment variable |
| 3 | In-memory persistence — data does not survive process restart (swap for DB adapter in production) |
| 4 | Stateless HTTP — no session affinity required; horizontal scaling trivial behind a load balancer |
| 5 | Audit log entries are immutable — no update or delete operations on audit records |

---

## 7. Information View (NIV)

### NIV-1 – Information Structure

| Flow | Source | Destination | Data | Trigger |
|---|---|---|---|---|
| IF-1 | HTTP Client | AuditLogController | WriteAuditLogRequest | POST /api/v1/auditlog |
| IF-2 | AuditLogController | WriteAuditLogUseCase | Request DTO + tenantId | Route handler |
| IF-3 | WriteAuditLogUseCase | AuditConfigRepository | Config lookup by tenantId | Category/disable check |
| IF-4 | WriteAuditLogUseCase | AuditLogRepository | AuditLogEntry | Persist immutable entry |
| IF-5 | HTTP Client | SecurityEventController | WriteSecurityEventRequest | POST /api/v1/security-events |
| IF-6 | WriteSecurityEventUseCase | AuditLogRepository + SecurityEventRepository | AuditLogEntry + SecurityEvent | Dual-write (parent + enriched) |
| IF-7 | HTTP Client | DataAccessController | WriteDataAccessLogRequest | POST /api/v1/data-access |
| IF-8 | WriteDataAccessLogUseCase | AuditLogRepository + DataAccessLogRepository | AuditLogEntry + DataAccessLog | Dual-write (parent + enriched) |
| IF-9 | HTTP Client | ConfigChangeController | WriteConfigChangeLogRequest | POST /api/v1/config-changes |
| IF-10 | WriteConfigChangeUseCase | AuditLogRepository + ConfigChangeLogRepository | AuditLogEntry + ConfigChangeLog | Dual-write (parent + enriched) |
| IF-11 | ManageExportsUseCase | AuditLogRepository | Category/time filtered search | Export job creation |
| IF-12 | RetentionEnforcer | All 4 log repositories | removeOlderThan(cutoff) | Scheduled retention enforcement |

### Data Sensitivity

| Data Element | Classification | Handling |
|---|---|---|
| Audit log messages | Internal | Immutable, tenant-scoped |
| User ID / user name | PII | Logged for accountability, subject to data masking config |
| IP address / user agent | PII | Recorded for forensic analysis, subject to retention policy |
| Data access fields | PII-reference | Identifies which personal data fields were accessed (GDPR Art. 30) |
| Data subject identity | PII | Identifies the person whose data was accessed |
| Security event failure reason | Sensitive | May reveal credential issues; access-restricted |
| Config change old/new values | Sensitive | May contain security policy details |
| Masked fields configuration | Internal | Defines which fields are redacted in audit output |

---

## 8. Traceability Matrix

| Capability | Service(s) | Entity | Controller | Use Case |
|---|---|---|---|---|
| C1.1 Audit Log Writing | SVC-LOG-WRITE | AuditLogEntry, AuditConfig | AuditLogController | WriteAuditLogUseCase |
| C1.2 Audit Log Retrieval | SVC-LOG-QUERY, SVC-LOG-GET | AuditLogEntry | AuditLogController | RetrieveAuditLogsUseCase |
| C1.3 Retention Policies | SVC-RET-* | RetentionPolicy | RetentionController | ManageRetentionUseCase |
| C1.4 Audit Configuration | SVC-CFG-* | AuditConfig | AuditConfigController | ManageAuditConfigUseCase |
| C1.5 Export Management | SVC-EXP-* | ExportJob | ExportController | ManageExportsUseCase |
| C1.6 Security Events | SVC-SEC-WRITE | SecurityEvent, AuditLogEntry | SecurityEventController | WriteSecurityEventUseCase |
| C1.7 Data Access Logging | SVC-DAL-WRITE | DataAccessLog, AuditLogEntry | DataAccessController | WriteDataAccessLogUseCase |
| C1.8 Config Change Logging | SVC-CCL-WRITE | ConfigChangeLog, AuditLogEntry | ConfigChangeController | WriteConfigChangeUseCase |
| C1.9 Health | SVC-HEALTH | — | HealthController | — |
