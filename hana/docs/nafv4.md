# NAF v4 Architecture Document

## HANA Cloud Service — UIM Platform

**Version:** 1.0
**Date:** 2026-04-05
**Classification:** UNCLASSIFIED
**Status:** Baseline

---

## 1. Architecture Context (NAF v4 Grid Reference)

| NAF v4 View | Covered | Section |
|---|---|---|
| C1 — Capability Taxonomy | Yes | Section 2 |
| C2 — Enterprise Vision | Yes | Section 3 |
| S1 — Service Taxonomy | Yes | Section 4 |
| S3 — Service Interfaces | Yes | Section 5 |
| S4 — Service Functions | Yes | Section 6 |
| L2 — Logical Scenario | Yes | Section 7 |
| L4 — Logical Activities | Yes | Section 8 |
| L7 — Logical Data Model | Yes | Section 9 |
| P1 — Resource Types | Yes | Section 10 |
| P2 — Resource Structure | Yes | Section 11 |
| P4 — Resource Functions | Yes | Section 12 |
| Ar — Architecture Metadata | Yes | Section 13 |

---

## 2. C1 — Capability Taxonomy

### 2.1 Capability Overview

The HANA Cloud Service provides comprehensive SAP HANA database-as-a-service management capabilities for the UIM Cloud Platform, covering the full lifecycle of instances, storage, users, security, replication, and operations.

### 2.2 Capability Hierarchy

```
C-ROOT: Cloud Database Management
├── C-HC-01: Instance Lifecycle Management
│   ├── C-HC-01.1: Instance Provisioning (create, configure type/size/region)
│   ├── C-HC-01.2: Instance Operations (start, stop, restart)
│   ├── C-HC-01.3: Instance Scaling (update memory, vCPUs, storage)
│   ├── C-HC-01.4: Instance Retrieval and Listing
│   └── C-HC-01.5: Instance Decommissioning (delete with cleanup)
├── C-HC-02: Data Lake Management
│   ├── C-HC-02.1: Data Lake Provisioning (with tiered storage)
│   ├── C-HC-02.2: Storage Tier Management (hot, warm, cold)
│   ├── C-HC-02.3: Multi-Format Support (Parquet, CSV, ORC, JSON, Avro)
│   └── C-HC-02.4: Compute Node Scaling
├── C-HC-03: Schema Management
│   ├── C-HC-03.1: Schema Creation (standard, HDI, virtual, system, temporary)
│   ├── C-HC-03.2: Schema Ownership Transfer
│   └── C-HC-03.3: Schema Metrics (table/view/procedure counts, size)
├── C-HC-04: User & Security Management
│   ├── C-HC-04.1: User Provisioning (multi-auth: password, Kerberos, SAML, X.509, JWT, LDAP)
│   ├── C-HC-04.2: Role and Privilege Assignment
│   ├── C-HC-04.3: User Status Management (active, deactivated, locked, expired)
│   ├── C-HC-04.4: Password Policy Enforcement
│   └── C-HC-04.5: IP Whitelisting
├── C-HC-05: Backup & Recovery
│   ├── C-HC-05.1: Backup Scheduling (cron-based)
│   ├── C-HC-05.2: Multi-Type Backup (full, incremental, differential, log, snapshot)
│   ├── C-HC-05.3: Backup Encryption
│   └── C-HC-05.4: Retention Policy Management
├── C-HC-06: Monitoring & Alerting
│   ├── C-HC-06.1: Threshold-Based Alert Definitions
│   ├── C-HC-06.2: Multi-Category Monitoring (performance, availability, storage, memory, CPU, replication, backup, security, configuration)
│   ├── C-HC-06.3: Alert Severity Levels (info, warning, error, critical)
│   └── C-HC-06.4: Alert Acknowledgment Workflow
├── C-HC-07: HDI Container Management
│   ├── C-HC-07.1: Container Provisioning
│   ├── C-HC-07.2: Schema Grant Management
│   └── C-HC-07.3: Artifact Tracking
├── C-HC-08: Data Replication
│   ├── C-HC-08.1: Replication Task Definition (real-time, scheduled, snapshot, log-based)
│   ├── C-HC-08.2: Table Mapping Configuration (source→target)
│   ├── C-HC-08.3: Execution Tracking (rows replicated, error count)
│   └── C-HC-08.4: Schedule-Based Execution
├── C-HC-09: Configuration Management
│   ├── C-HC-09.1: Multi-Scope Parameters (system, database, tenant, session)
│   ├── C-HC-09.2: Multi-Type Values (string, integer, boolean, decimal, duration)
│   ├── C-HC-09.3: Read-Only and Restart-Required Flags
│   └── C-HC-09.4: Section-Based Organization
├── C-HC-10: Connection Management
│   ├── C-HC-10.1: Multi-Driver Support (JDBC, ODBC, hdbsql, Node.js, Python, Java, Go, .NET)
│   ├── C-HC-10.2: Connection Pooling (min/max, idle timeout)
│   ├── C-HC-10.3: TLS Configuration
│   └── C-HC-10.4: Custom Connection Properties
└── C-HC-11: Operational Monitoring
    └── C-HC-11.1: Health Check
```

---

## 3. C2 — Enterprise Vision

### 3.1 Purpose Statement

Provide a comprehensive, multi-tenant HANA Cloud database management service that enables applications on the UIM Cloud Platform to provision, operate, monitor, and secure SAP HANA database instances through a uniform REST API — analogous to the SAP BTP HANA Cloud service.

### 3.2 Strategic Goals

| ID | Goal | Priority |
|----|------|----------|
| SG-01 | Full HANA instance lifecycle management (create → run → scale → delete) | High |
| SG-02 | Multi-authentication user management with fine-grained privileges | High |
| SG-03 | Automated backup scheduling with encryption and retention policies | High |
| SG-04 | Real-time and scheduled data replication with table-level mapping | Medium |
| SG-05 | Comprehensive threshold-based alerting with acknowledgment workflow | Medium |
| SG-06 | HDI container management for cloud application development | Medium |
| SG-07 | Data Lake integration with tiered storage (hot/warm/cold) | Medium |
| SG-08 | Multi-driver connection management with connection pooling | Medium |
| SG-09 | Tenant data isolation in multi-tenant deployments | High |
| SG-10 | Cloud-native deployment (Docker, Podman, Kubernetes) | High |

### 3.3 Key Constraints

| ID | Constraint |
|----|-----------|
| CON-01 | All timestamps in UTC epoch milliseconds |
| CON-02 | Tenant identification via X-Tenant-Id HTTP header |
| CON-03 | In-memory persistence for MVP (pluggable repository interfaces) |
| CON-04 | Single-process, event-driven architecture (vibe-d) |
| CON-05 | Port 8097 default, configurable via environment variables |

---

## 4. S1 — Service Taxonomy

### 4.1 Service Inventory

```
SVC-ROOT: HANA Cloud Platform Service
├── SVC-HC-01: Instance Service
│   ├── Create Instance (with type, size, region, networking)
│   ├── List Instances (by tenant)
│   ├── Get Instance (by ID)
│   ├── Update Instance (scale, reconfigure)
│   ├── Delete Instance
│   └── Perform Action (start / stop / restart)
├── SVC-HC-02: Data Lake Service
│   ├── Create Data Lake (with storage tiers, compute nodes)
│   ├── List Data Lakes
│   ├── Get Data Lake
│   ├── Update Data Lake
│   └── Delete Data Lake
├── SVC-HC-03: Schema Service
│   ├── Create Schema
│   ├── List Schemas
│   ├── Get Schema
│   ├── Update Schema
│   └── Delete Schema
├── SVC-HC-04: Database User Service
│   ├── Create User (with auth type, roles, privileges)
│   ├── List Users
│   ├── Get User
│   ├── Update User
│   └── Delete User
├── SVC-HC-05: Backup Service
│   ├── Create Backup (with schedule, encryption)
│   ├── List Backups
│   ├── Get Backup
│   ├── Update Backup
│   └── Delete Backup
├── SVC-HC-06: Alert Service
│   ├── Create Alert Definition
│   ├── List Alerts
│   ├── Get Alert
│   ├── Update Alert
│   ├── Delete Alert
│   └── Acknowledge Alert
├── SVC-HC-07: HDI Container Service
│   ├── Create HDI Container
│   ├── List HDI Containers
│   ├── Get HDI Container
│   ├── Update HDI Container
│   └── Delete HDI Container
├── SVC-HC-08: Replication Task Service
│   ├── Create Task (with mode, mappings, schedule)
│   ├── List Tasks
│   ├── Get Task
│   ├── Update Task
│   └── Delete Task
├── SVC-HC-09: Configuration Service
│   ├── Create Parameter
│   ├── List Parameters
│   ├── Get Parameter
│   ├── Update Parameter
│   └── Delete Parameter
├── SVC-HC-10: Database Connection Service
│   ├── Create Connection (with pool config, TLS)
│   ├── List Connections
│   ├── Get Connection
│   ├── Update Connection
│   └── Delete Connection
└── SVC-HC-11: Health Service
    └── Health Check
```

---

## 5. S3 — Service Interfaces

### 5.1 REST API Interface Specification

**Base URL:** `/api/v1/hana`
**Protocol:** HTTP/1.1
**Content-Type:** application/json
**Authentication:** X-Tenant-Id header (tenant identification)

#### 5.1.1 Instance Endpoints

| Operation | Method | URI | Description |
|-----------|--------|-----|-------------|
| Create | POST | `/instances` | Provision a new HANA instance |
| List | GET | `/instances` | List all instances for the tenant |
| Get | GET | `/instances/{id}` | Retrieve instance by ID |
| Update | PUT | `/instances/{id}` | Update instance configuration |
| Delete | DELETE | `/instances/{id}` | Decommission an instance |
| Action | POST | `/instances/{id}/actions` | Start, stop, or restart |

#### 5.1.2 Data Lake Endpoints

| Operation | Method | URI | Description |
|-----------|--------|-----|-------------|
| Create | POST | `/dataLakes` | Create a data lake |
| List | GET | `/dataLakes` | List data lakes |
| Get | GET | `/dataLakes/{id}` | Get data lake details |
| Update | PUT | `/dataLakes/{id}` | Update data lake |
| Delete | DELETE | `/dataLakes/{id}` | Delete data lake |

#### 5.1.3 Schema Endpoints

| Operation | Method | URI | Description |
|-----------|--------|-----|-------------|
| Create | POST | `/schemas` | Create a schema |
| List | GET | `/schemas` | List schemas |
| Get | GET | `/schemas/{id}` | Get schema details |
| Update | PUT | `/schemas/{id}` | Update schema |
| Delete | DELETE | `/schemas/{id}` | Delete schema |

#### 5.1.4 Database User Endpoints

| Operation | Method | URI | Description |
|-----------|--------|-----|-------------|
| Create | POST | `/users` | Create a database user |
| List | GET | `/users` | List users |
| Get | GET | `/users/{id}` | Get user details |
| Update | PUT | `/users/{id}` | Update user |
| Delete | DELETE | `/users/{id}` | Delete user |

#### 5.1.5 Backup Endpoints

| Operation | Method | URI | Description |
|-----------|--------|-----|-------------|
| Create | POST | `/backups` | Create/schedule backup |
| List | GET | `/backups` | List backups |
| Get | GET | `/backups/{id}` | Get backup details |
| Update | PUT | `/backups/{id}` | Update backup |
| Delete | DELETE | `/backups/{id}` | Delete backup record |

#### 5.1.6 Alert Endpoints

| Operation | Method | URI | Description |
|-----------|--------|-----|-------------|
| Create | POST | `/alerts` | Create alert definition |
| List | GET | `/alerts` | List alerts |
| Get | GET | `/alerts/{id}` | Get alert details |
| Update | PUT | `/alerts/{id}` | Update alert |
| Delete | DELETE | `/alerts/{id}` | Delete alert |
| Acknowledge | PUT | `/alerts/{id}/acknowledge` | Acknowledge alert |

#### 5.1.7 HDI Container Endpoints

| Operation | Method | URI | Description |
|-----------|--------|-----|-------------|
| Create | POST | `/hdiContainers` | Create HDI container |
| List | GET | `/hdiContainers` | List HDI containers |
| Get | GET | `/hdiContainers/{id}` | Get HDI container |
| Update | PUT | `/hdiContainers/{id}` | Update HDI container |
| Delete | DELETE | `/hdiContainers/{id}` | Delete HDI container |

#### 5.1.8 Replication Task Endpoints

| Operation | Method | URI | Description |
|-----------|--------|-----|-------------|
| Create | POST | `/replicationTasks` | Create replication task |
| List | GET | `/replicationTasks` | List replication tasks |
| Get | GET | `/replicationTasks/{id}` | Get replication task |
| Update | PUT | `/replicationTasks/{id}` | Update replication task |
| Delete | DELETE | `/replicationTasks/{id}` | Delete replication task |

#### 5.1.9 Configuration Endpoints

| Operation | Method | URI | Description |
|-----------|--------|-----|-------------|
| Create | POST | `/configurations` | Create configuration parameter |
| List | GET | `/configurations` | List configurations |
| Get | GET | `/configurations/{id}` | Get configuration |
| Update | PUT | `/configurations/{id}` | Update configuration |
| Delete | DELETE | `/configurations/{id}` | Delete configuration |

#### 5.1.10 Database Connection Endpoints

| Operation | Method | URI | Description |
|-----------|--------|-----|-------------|
| Create | POST | `/connections` | Create connection |
| List | GET | `/connections` | List connections |
| Get | GET | `/connections/{id}` | Get connection |
| Update | PUT | `/connections/{id}` | Update connection |
| Delete | DELETE | `/connections/{id}` | Delete connection |

#### 5.1.11 Health Endpoint

| Operation | Method | URI | Description |
|-----------|--------|-----|-------------|
| Health | GET | `/api/v1/health` | Service health check |

### 5.2 Error Response Format

```json
{
  "error": {
    "message": "Human-readable error description",
    "code": 400
  }
}
```

### 5.3 Request Headers

| Header | Required | Description |
|--------|----------|-------------|
| X-Tenant-Id | Yes | Tenant identifier for multi-tenancy |
| Content-Type | For POST/PUT | application/json |

---

## 6. S4 — Service Functions

### 6.1 Functional Decomposition

```
F-HC-01: Instance Management
  F-HC-01.1: Validate instance input (name required)
  F-HC-01.2: Parse InstanceType, InstanceSize enums from strings
  F-HC-01.3: Generate unique instance ID (UUID v4)
  F-HC-01.4: Build entity with InstanceEndpoint, InstanceResource sub-structs
  F-HC-01.5: Set initial status = creating
  F-HC-01.6: Validate state transitions for start/stop/restart actions
  F-HC-01.7: IP whitelist management

F-HC-02: Data Lake Management
  F-HC-02.1: Create data lake linked to instance
  F-HC-02.2: Configure storage tiers (hot/warm/cold) with capacity
  F-HC-02.3: Track supported file formats (Parquet, CSV, ORC, JSON, Avro)
  F-HC-02.4: Scale compute nodes

F-HC-03: Schema Management
  F-HC-03.1: Create schemas of various types (standard, HDI, virtual, system, temporary)
  F-HC-03.2: Track schema metrics (table/view/procedure counts, size)
  F-HC-03.3: Manage schema ownership

F-HC-04: User & Security Management
  F-HC-04.1: Create users with configurable authentication type
  F-HC-04.2: Assign roles and privileges (system, object, analytic, package, application, role)
  F-HC-04.3: Enforce password change policy
  F-HC-04.4: Track failed login attempts, password expiry, last login

F-HC-05: Backup Management
  F-HC-05.1: Support multiple backup types
  F-HC-05.2: Configure cron-based backup schedules
  F-HC-05.3: Handle encryption key management
  F-HC-05.4: Enforce retention policies with expiration

F-HC-06: Alert Management
  F-HC-06.1: Define metric thresholds (warning, critical) with units
  F-HC-06.2: Track alert lifecycle (active → acknowledged → resolved / suppressed)
  F-HC-06.3: Record acknowledgment metadata (who, when)

F-HC-07: HDI Container Management
  F-HC-07.1: Provision containers with auto-generated schema names
  F-HC-07.2: Manage granted schema access
  F-HC-07.3: Track artifact count and container size

F-HC-08: Replication Task Management
  F-HC-08.1: Configure source/target connections
  F-HC-08.2: Define table-level mappings (source schema.table → target schema.table)
  F-HC-08.3: Support multiple replication modes
  F-HC-08.4: Track replicated rows and error counts

F-HC-09: Configuration Management
  F-HC-09.1: Organize parameters by section and scope
  F-HC-09.2: Track default vs current values
  F-HC-09.3: Flag read-only and restart-required parameters

F-HC-10: Connection Management
  F-HC-10.1: Support multiple connection drivers
  F-HC-10.2: Configure connection pools (min/max, timeouts)
  F-HC-10.3: TLS certificate management
  F-HC-10.4: Custom key-value connection properties
```

---

## 7. L2 — Logical Scenario

### 7.1 Scenario 1: Instance Provisioning

```
1. Client sends POST /api/v1/hana/instances with instance specification
2. InstanceController parses request JSON, extracts X-Tenant-Id
3. ManageInstancesUseCase validates input (name required)
4. UUID generated, InstanceType/InstanceSize parsed from strings
5. DatabaseInstance entity built with endpoint, resources, labels sub-structs
6. Status set to "creating", timestamps set
7. Instance saved via InstanceRepository port → MemoryInstanceRepository
8. 201 Created returned with instance ID
```

### 7.2 Scenario 2: Instance Action (Start/Stop/Restart)

```
1. Client sends POST /api/v1/hana/instances/{id}/actions with {action: "start"}
2. InstanceController extracts action type and tenant
3. ManageInstancesUseCase retrieves instance from repository
4. State transition validated (e.g., stopped → starting is valid)
5. Instance status updated, updatedAt timestamp set
6. Instance persisted via repository
7. 200 OK returned with confirmation
```

### 7.3 Scenario 3: Backup With Schedule

```
1. Client sends POST /api/v1/hana/backups with backup spec including cron schedule
2. ManageBackupsUseCase builds Backup entity with BackupSchedule sub-struct
3. Status set to "scheduled", encryption configured if requested
4. Retention policy set (retentionDays → expiresAt calculation)
5. Backup persisted
6. 201 Created returned
```

### 7.4 Scenario 4: Alert Acknowledgment

```
1. Client sends PUT /api/v1/hana/alerts/{id}/acknowledge
2. Alert retrieved from repository
3. Status transitions from "active" to "acknowledged"
4. acknowledgedBy and acknowledgedAt fields set
5. Updated alert persisted
6. 200 OK returned
```

### 7.5 Scenario 5: Replication Task Configuration

```
1. Client sends POST /api/v1/hana/replicationTasks with source/target connections and table mappings
2. ManageReplicationTasksUseCase builds ReplicationTask entity
3. ReplicationMapping[] constructed from sourceSchema.table → targetSchema.table pairs
4. Mode set (real-time, scheduled, snapshot, log-based)
5. Schedule expression stored if mode is "scheduled"
6. Task persisted with status "inactive"
7. 201 Created returned
```

---

## 8. L4 — Logical Activities

### 8.1 Instance Provisioning Activity Flow

```
[Start]
  → Receive HTTP POST Request
  → Parse JSON Body
  → Extract X-Tenant-Id Header
  → Validate Input (name required?)
    ── invalid → Return 400 Error → [End]
    ── valid →
  → Generate UUID
  → Parse InstanceType enum
  → Parse InstanceSize enum
  → Build InstanceEndpoint sub-struct
  → Build InstanceResource sub-struct (memoryGB, vcpus, storageGB)
  → Build InstanceLabel[] from labels
  → Set status = creating
  → Set createdAt = Clock.currStdTime()
  → Persist via InstanceRepository
  → Return 201 Created
  → [End]
```

### 8.2 Instance Lifecycle State Machine

```
[*] → creating
creating → running (provisioning complete)
creating → error (provisioning failed)
running → stopping (stop action)
running → updating (update request)
running → deleting (delete request)
running → suspended (suspend)
stopping → stopped (stop complete)
stopped → starting (start action)
stopped → deleting (delete request)
starting → running (start complete)
starting → error (start failed)
updating → running (update complete)
updating → error (update failed)
suspended → starting (resume)
error → starting (retry)
error → deleting (force delete)
deleting → [*] (deleted)
```

### 8.3 Alert Lifecycle State Machine

```
[*] → active (threshold breached)
active → acknowledged (acknowledge action)
active → resolved (metric recovered)
active → suppressed (suppress action)
acknowledged → resolved (metric recovered)
suppressed → active (unsuppress)
resolved → [*]
```

### 8.4 Backup Lifecycle State Machine

```
[*] → scheduled (backup created)
scheduled → running (execution start)
scheduled → cancelled (cancel action)
running → completed (success)
running → failed (error)
completed → [*]
failed → [*]
cancelled → [*]
```

---

## 9. L7 — Logical Data Model

### 9.1 Entity Relationship Model

```
┌──────────────────────────────┐
│      DatabaseInstance         │
├──────────────────────────────┤
│ PK id: DatabaseInstanceId             │
│    tenantId: TenantId         │
│    name: string               │
│    description: string        │
│    type: InstanceType         │
│    status: InstanceStatus     │
│    size: InstanceSize         │
│    version_: string           │
│    region: string             │
│    availabilityZone: string   │
│    endpoint: InstanceEndpoint │
│    resources: InstanceResource│
│    labels: InstanceLabel[]    │
│    enableScriptServer: bool   │
│    enableDocStore: bool       │
│    enableDataLake: bool       │
│    allowAllIpAccess: bool     │
│    whitelistedIps: string[]   │
│    createdAt: long            │
│    updatedAt: long           │
└──────────┬───────────────────┘
           │ 1
           │
     ┌─────┼─────┬──────┬──────┬──────┬──────┬──────┬──────┬──────┐
     │     │     │      │      │      │      │      │      │      │
    0..*  0..* 0..*   0..*   0..*   0..*   0..*   0..*   0..*   0..*
     │     │     │      │      │      │      │      │      │      │
┌────┴─┐ ┌─┴──┐ ┌┴───┐ ┌┴───┐ ┌┴───┐ ┌┴───┐ ┌┴────┐ ┌┴───┐ ┌┴───┐
│DataLk│ │Schm│ │DBUsr│ │Bakp│ │Alrt│ │HDI │ │ReplT│ │Conf│ │Conn│
└──────┘ └────┘ └─────┘ └────┘ └────┘ └────┘ └─────┘ └────┘ └────┘
```

### 9.2 Detailed Entity Specifications

#### DatabaseInstance
| Attribute | Type | Description |
|-----------|------|-------------|
| id | UUID string | Unique instance identifier |
| tenantId | string | Owning tenant |
| name | string | Instance display name |
| type | enum | hana, hanaExpress, hanaCloud, trial, free |
| status | enum | creating, running, stopped, starting, stopping, updating, deleting, error, suspended |
| size | enum | xs, s, m, l, xl, xxl, custom |
| endpoint | sub-struct | host, port, protocol |
| resources | sub-struct | memoryGB, vcpus, storageGB, usedStorageGB |

#### DataLake
| Attribute | Type | Description |
|-----------|------|-------------|
| id | UUID string | Data lake identifier |
| instanceId | string | Parent HANA instance |
| storage | DataLakeStorage[] | Tiered storage (hot, warm, cold) with capacity |
| supportedFormats | FileFormat[] | parquet, csv, orc, json, avro |
| computeNodes | int | Number of compute nodes |

#### Schema
| Attribute | Type | Description |
|-----------|------|-------------|
| id | UUID string | Schema identifier |
| type | SchemaType | standard, hdi, virtual, system, temporary |
| tableCount / viewCount / procedureCount | long | Object counts |
| sizeBytes | long | Total schema size |

#### DatabaseUser
| Attribute | Type | Description |
|-----------|------|-------------|
| id | UUID string | User identifier |
| authType | AuthType | password, kerberos, saml, x509, jwt, ldap |
| status | UserStatus | active, deactivated, locked, expired |
| roles | UserRole[] | Assigned roles |
| privileges | UserPrivilege[] | System, object, analytic, package, application, role privileges |

#### Backup
| Attribute | Type | Description |
|-----------|------|-------------|
| id | UUID string | Backup identifier |
| type | BackupType | full, incremental, differential, log, snapshot |
| status | BackupStatus | scheduled, running, completed, failed, cancelled |
| schedule | BackupSchedule | cronExpression, retentionDays, enabled |
| encrypted | bool | Encryption flag |

#### Alert
| Attribute | Type | Description |
|-----------|------|-------------|
| id | UUID string | Alert identifier |
| severity | AlertSeverity | info, warning, error, critical |
| status | AlertStatus | active, acknowledged, resolved, suppressed |
| category | AlertCategory | performance, availability, storage, memory, cpu, replication, backup, security, configuration |
| threshold | AlertThreshold | metric, warningValue, criticalValue, unit |

#### HDIContainer
| Attribute | Type | Description |
|-----------|------|-------------|
| id | UUID string | Container identifier |
| status | HDIContainerStatus | creating, active, inactive, error, deleting |
| grantedSchemas | string[] | Schemas with granted access |
| artifactCount | int | Deployed artifacts |

#### ReplicationTask
| Attribute | Type | Description |
|-----------|------|-------------|
| id | UUID string | Task identifier |
| mode | ReplicationMode | none, realtime, scheduled, snapshot, logBased |
| status | ReplicationTaskStatus | active, inactive, running, completed, failed, paused |
| mappings | ReplicationMapping[] | sourceSchema.table → targetSchema.table |
| rowsReplicated | long | Cumulative replicated rows |

#### Configuration
| Attribute | Type | Description |
|-----------|------|-------------|
| id | UUID string | Config parameter identifier |
| scope_ | ConfigScope | system, database, tenant, session |
| dataType | ConfigDataType | string_, integer, boolean_, decimal, duration |
| isReadOnly | bool | Read-only flag |
| requiresRestart | bool | Restart required after change |

#### DatabaseConnection
| Attribute | Type | Description |
|-----------|------|-------------|
| id | UUID string | Connection identifier |
| type | ConnectionType | jdbc, odbc, hdbsql, nodeJs, python, java, go, dotnet |
| status | ConnectionStatus | active, inactive, error, pooled |
| poolConfig | ConnectionPoolConfig | minConnections, maxConnections, idleTimeoutMs, connectionTimeoutMs |

---

## 10. P1 — Resource Types

### 10.1 Software Resources

| Resource | Type | Version | Purpose |
|----------|------|---------|---------|
| D Language (LDC) | Compiler/Runtime | 1.40.1 | Primary language |
| vibe-d | HTTP Framework | 0.10.x | HTTP server, routing, JSON |
| uim-framework | Library | 26.4.1 | Platform base classes |
| uim-platform:service | Library | internal | PlatformController, UIMUseCase base |

### 10.2 Infrastructure Resources

| Resource | Type | Purpose |
|----------|------|---------|
| Ubuntu 24.04 | OS | Runtime container base |
| Docker / Podman | Container | Build and run |
| Kubernetes | Orchestrator | Production deployment |

---

## 11. P2 — Resource Structure

### 11.1 Source Code Structure

```
hana/
├── dub.sdl                               # Build configuration
├── Dockerfile                            # Docker multi-stage build
├── Containerfile                         # Podman multi-stage build
├── k8s/                                  # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   └── configmap.yaml
├── docs/                                 # Architecture documentation
│   ├── uml.md                            # UML diagrams (Mermaid)
│   └── nafv4.md                          # This document
└── source/
    ├── app.d                             # Entry point
    └── uim/platform/hana/
        ├── package.d                     # Root re-exports
        ├── domain/                       # CORE (no external deps)
        │   ├── types.d                   # 20+ enums, 10 ID aliases
        │   ├── entities/                 # 10 entities with sub-structs
        │   ├── ports/repositories/       # 10 repository interfaces
        │   └── services/                 # InstanceValidator
        ├── application/                  # USE CASES
        │   ├── dto.d                     # Request/Result DTOs
        │   └── usecases/manage/          # 10 use case classes
        ├── presentation/                 # DRIVING ADAPTERS
        │   ├── package.d
        │   └── http/
        │       ├── json_utils.d          # JSON extraction helpers
        │       └── controllers/          # 11 controllers
        └── infrastructure/               # DRIVEN ADAPTERS
            ├── config.d                  # AppConfig + env loading
            ├── container.d               # DI wiring (10 repos → 10 use cases → 11 controllers)
            ├── files/                    # File-based persistence (future)
            ├── mongo/                    # MongoDB persistence (future)
            └── persistence/memory/       # 10 in-memory repository impls
```

### 11.2 Package Dependency Graph

```
app.d
 └── infrastructure/container.d (buildContainer)
      ├── infrastructure/persistence/memory/*   (10 MemoryXxxRepository)
      │    └── domain/ports/repositories/*      (10 interfaces)
      │         └── domain/entities/*           (10 entity structs)
      │              └── domain/types           (aliases + 20+ enums)
      ├── application/usecases/manage/*         (10 ManageXxxUseCase)
      │    ├── domain/ports/repositories/*
      │    ├── domain/services/*                (InstanceValidator)
      │    └── application/dto                  (request/result DTOs)
      └── presentation/http/controllers/*       (11 controllers)
           ├── application/usecases/*
           ├── application/dto
           └── presentation/http/json_utils
```

---

## 12. P4 — Resource Functions

### 12.1 Container Build Process

```
Stage 1: Builder (dlang2/ldc-ubuntu:1.40.1)
  1. Copy dub.sdl, dub.selections.json
  2. Copy source/
  3. dub build --build=release --config=defaultRun
  Output: build/uim-hana-platform-service

Stage 2: Runtime (ubuntu:24.04)
  1. Install ca-certificates, curl
  2. Create non-root appuser
  3. Copy binary from builder
  4. Expose port 8097
  5. Configure health check (GET /api/v1/health)
  6. Run as appuser
```

### 12.2 Startup Sequence

```
1. loadConfig()          — Read HANA_HOST, HANA_PORT from environment
2. buildContainer()      — Wire: 10 repos → 10 use cases → 11 controllers
3. new URLRouter()       — Initialize HTTP router
4. registerRoutes()      — Register all 11 controller route sets
5. listenHTTP()          — Bind to host:port (default 0.0.0.0:8097)
6. runApplication()      — Start vibe-d event loop
```

### 12.3 Kubernetes Deployment Parameters

| Parameter | Value |
|-----------|-------|
| Replicas | 1 |
| Container Port | 8097/TCP |
| Service Type | ClusterIP |
| Memory Request | 64Mi |
| Memory Limit | 256Mi |
| CPU Request | 100m |
| CPU Limit | 500m |
| Liveness Probe | GET /api/v1/health (period: 30s) |
| Readiness Probe | GET /api/v1/health (period: 10s) |
| Security | runAsNonRoot, readOnlyRootFilesystem, no privilege escalation |
| Config Source | ConfigMap: cloud-hana-config |

---

## 13. Ar — Architecture Metadata

| Field | Value |
|-------|-------|
| Architecture Name | HANA Cloud Service |
| Version | 1.0 |
| Framework | NAF v4 |
| Status | Baseline |
| Author | UIM Platform Team |
| Date Created | 2026-04-05 |
| Classification | UNCLASSIFIED |
| Platform | UIM Cloud Platform |
| Repository | UIMSolutions/uim-platform |
| Subpackage | hana |
| Language | D (dlang) |
| HTTP Framework | vibe-d 0.10.x |
| Base Framework | uim-framework 26.4.1 |
| Architecture Style | Hexagonal (Ports and Adapters) + Clean Architecture |
| Deployment | Docker / Podman / Kubernetes |
| Default Port | 8097 |
| Total Entities | 10 (with 10+ sub-structs) |
| Total Enums | 20+ |
| Total Controllers | 11 (10 domain + 1 health) |
| Total Use Cases | 10 |
| Total Repository Ports | 10 |
