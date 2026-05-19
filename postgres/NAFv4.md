# NAFv4 Architecture — PostgreSQL on SAP BTP, Hyperscaler Option

## 1. Overview (NAFv4 Architecture View)

This document describes the architecture of the **PostgreSQL on SAP BTP, Hyperscaler Option** UIM Platform service using the **NATO Architecture Framework version 4 (NAFv4)** viewpoints.

---

## 2. NAFv4 Viewpoints

### 2.1 Capability View (C1) — Strategic Capabilities

| Capability ID | Capability Name              | Description                                                   |
|---------------|------------------------------|---------------------------------------------------------------|
| CAP-PG-01     | Instance Lifecycle           | Provision, update, and delete managed PostgreSQL instances     |
| CAP-PG-02     | Credential Binding           | Bind instances to applications, manage credentials            |
| CAP-PG-03     | Plan Management              | Manage standard and premium service plans                     |
| CAP-PG-04     | Configuration Management     | Tune PostgreSQL parameters, audit log levels, locale          |
| CAP-PG-05     | Backup and Recovery          | Automated backup with configurable retention                  |
| CAP-PG-06     | User Management              | Create and manage PostgreSQL database users and roles         |
| CAP-PG-07     | Extension Management         | Enable/disable PostgreSQL extensions per instance             |
| CAP-PG-08     | Maintenance Scheduling       | Plan and execute instance maintenance windows                 |
| CAP-PG-09     | Multi-Hyperscaler Deployment | Support AWS, Azure, GCP, Alibaba Cloud targets                |
| CAP-PG-10     | High Availability            | Multi-AZ deployments for production workloads                 |

---

### 2.2 Service View (S1) — Services

| Service ID  | Service Name                | Exposed Via           | Consumer          |
|-------------|-----------------------------|-----------------------|-------------------|
| SVC-PG-01   | Instance CRUD REST API      | HTTP :8131            | BTP cockpit, CF   |
| SVC-PG-02   | Binding REST API            | HTTP :8131            | CF app binding    |
| SVC-PG-03   | Plan Query REST API         | HTTP :8131            | Marketplace       |
| SVC-PG-04   | Configuration REST API      | HTTP :8131            | Operators         |
| SVC-PG-05   | Backup Policy REST API      | HTTP :8131            | Operators         |
| SVC-PG-06   | DB User REST API            | HTTP :8131            | Operators, apps   |
| SVC-PG-07   | Extension REST API          | HTTP :8131            | Developers        |
| SVC-PG-08   | Maintenance Window API      | HTTP :8131            | Operations team   |
| SVC-PG-09   | CLI Interface               | CLI presentation layer| Ops engineers     |
| SVC-PG-10   | Web UI                      | Web MVC presentation  | Administrators    |
| SVC-PG-11   | GUI Descriptors             | GUI MVC (JSON)        | GUI front-end     |
| SVC-PG-12   | Health Check                | HTTP GET /health      | k8s probes        |

---

### 2.3 Logical Architecture View (L2) — Logical Components

```
┌──────────────────────────────────────────────────────────────────┐
│                        Presentation Layer                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────┐  ┌─────────┐ │
│  │  HTTP REST   │  │   CLI MVC    │  │  Web MVC │  │ GUI MVC │ │
│  │ Controllers  │  │  M / V / C   │  │ M / V / C│  │ M/V/C   │ │
│  └──────┬───────┘  └──────┬───────┘  └────┬─────┘  └────┬────┘ │
└─────────┼─────────────────┼───────────────┼──────────────┼──────┘
          │                 │               │              │
┌─────────▼─────────────────▼───────────────▼──────────────▼──────┐
│                        Application Layer                         │
│  ManageServiceInstances   ManageServiceBindings   ManagePlans    │
│  ManageConfigurations     ManageBackupPolicies    ManageDBUsers  │
│  ManageExtensions         ManageMaintenanceWindows               │
│  DTOs: ServiceInstanceDTO, ServiceBindingDTO, ConfigurationDTO   │
└─────────────────────────────┬────────────────────────────────────┘
                              │
┌─────────────────────────────▼────────────────────────────────────┐
│                          Domain Layer                            │
│  Entities: ServiceInstance, ServiceBinding, ServicePlan,         │
│            Configuration, BackupPolicy, DatabaseUser,            │
│            DatabaseExtension, MaintenanceWindow                  │
│  Port Interfaces: *Repository (8 interfaces)                     │
│  Enums: InstanceStatus, BindingStatus, PlanTier, Hyperscaler,    │
│         PostgresVersion, SslMode, BackupStatus, UserStatus,      │
│         ExtensionStatus, MaintenanceStatus                       │
└─────────────────────────────┬────────────────────────────────────┘
                              │
┌─────────────────────────────▼────────────────────────────────────┐
│                      Infrastructure Layer                        │
│  ┌───────────────┐  ┌───────────────┐  ┌────────────────────┐   │
│  │MemoryRepos (8)│  │ FileRepos (8) │  │ MongoRepos (8)     │   │
│  └───────────────┘  └───────────────┘  └────────────────────┘   │
│  config.d — SrvConfig + loadConfig()                            │
│  container.d — buildContainer(), persistence backend switch      │
└──────────────────────────────────────────────────────────────────┘
```

---

### 2.4 Physical Architecture View (P2) — Node Deployment

| Node                    | Component                         | Technology         |
|-------------------------|-----------------------------------|--------------------|
| Kubernetes Pod          | uim-postgres-platform-service     | D / LDC / vibe.d   |
| K8s Service (ClusterIP) | postgres-service :8131            | Kubernetes         |
| ConfigMap               | postgres-config                   | Kubernetes         |
| Optional: MongoDB       | Persistence backend               | MongoDB            |
| Optional: PVC           | File persistence                  | Kubernetes PVC     |

---

### 2.5 Data Architecture (D1) — Data Entities and Flows

| Entity             | Key Attributes                                            | Persistence  |
|--------------------|-----------------------------------------------------------|--------------|
| ServiceInstance    | id, tenantId, name, engineVersion, memoryGb, storageGb, multiAz | All 3 |
| ServiceBinding     | id, tenantId, instanceId, username, sslMode, connectionString | All 3 |
| ServicePlan        | id, tenantId, name, tier, memoryGb, storageGb             | All 3       |
| Configuration      | id, tenantId, instanceId, auditLogLevels, backupRetentionPeriod | All 3 |
| BackupPolicy       | id, tenantId, instanceId, retentionPeriod, status         | All 3       |
| DatabaseUser       | id, tenantId, instanceId, username, roles, status         | All 3       |
| DatabaseExtension  | id, tenantId, instanceId, extensionName, status           | All 3       |
| MaintenanceWindow  | id, tenantId, instanceId, dayOfWeek, startHourUtc         | All 3       |

---

### 2.6 Security View (SecV) — Security Architecture

| Concern                  | Mechanism                                                      |
|--------------------------|----------------------------------------------------------------|
| Authentication           | X-Tenant-ID header (multi-tenant isolation)                    |
| Connection Security      | TLS/SSL for all database connections (sslMode field)           |
| Password Management      | Connection strings not stored in logs; credentials via binding |
| Audit Logging            | Configurable audit_log_level (DDL, DML, ROLE, READ)           |
| Network Isolation        | ClusterIP service (no external exposure by default)            |
| Non-root Container       | Runs as `appuser` in Docker/Podman                             |
| Secret Rotation          | Binding delete + recreate for credential rotation              |

---

### 2.7 Standards and Technology (S4)

| Standard / Technology | Usage                                |
|-----------------------|--------------------------------------|
| D Language (LDC 1.40.1) | Service implementation             |
| vibe.d 0.10.x          | HTTP server, JSON, routing          |
| vibe.db.mongo          | MongoDB persistence adapter         |
| PostgreSQL 13–16       | Target managed database engine      |
| OCI (Docker/Podman)    | Container packaging                 |
| Kubernetes 1.27+       | Container orchestration             |
| NAFv4                  | Architecture documentation          |
| Apache 2.0             | Open-source license                 |

---

### 2.8 Behaviour View (B2) — State Machine (Service Instance)

```
[provisioning] ──success──► [active]
[provisioning] ──failure──► [failed]
[active]       ──update──►  [updating]
[updating]     ──success──► [active]
[updating]     ──failure──► [failed]
[active]       ──delete──►  [deleting]
[deleting]     ──success──► [deleted]
[failed]       ──delete──►  [deleting]
```

---

## 3. Compliance

This architecture complies with:
- SAP BTP service broker API conventions (bind/unbind, provision/deprovision)
- OWASP Top 10 security guidelines
- 12-Factor App methodology
- NAFv4 viewpoint coverage: C1, S1, L2, P2, D1, SecV, S4, B2
