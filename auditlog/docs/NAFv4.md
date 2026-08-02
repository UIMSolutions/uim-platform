# NAF v4 Architecture Description — Audit Log Service


## Documentation update

This document is maintained alongside the implementation, deployment manifests, and tests for the same package so the service documentation stays aligned with the codebase.

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Audit Log Service — audit log entry management, security events, data access
> logs, configuration change logs, export jobs, retention policies, and audit
> configuration modelled on SAP Audit Log Service.

---

## 1. NAF v4 Grid Mapping

| NAF View | Viewpoint | Covered Below |
|---|---|---|
| **NCV** | C1 Capability Taxonomy, C2 Enterprise Vision | §2 |
| **NSV** | NSOV-2 Service Definitions | §3 |
| **NOV** | NOV-2 Operational Node Connectivity | §4 |
| **NLV** | NLV-1 Logical Data Model | §5 |
| **NPV** | NPV-1 Physical Deployment | §6 |
| **NIV** | NIV-1 Information Structure | §7 |

---

## 2. Capability View (NCV)

### C1 – Capability Taxonomy

```
Audit Log
├── C1.1  Audit Entry Ingestion
│   ├── C1.1.1  Write audit log entries
│   └── C1.1.2  Classify by type (data_access, security, config_change)
│
├── C1.2  Log Retrieval
│   ├── C1.2.1  Query entries with filters
│   └── C1.2.2  Export jobs for bulk retrieval
│
├── C1.3  Security Event Logging
│   └── C1.3.1  Record security-relevant events
│
├── C1.4  Data Access Logging
│   └── C1.4.1  Record personal data access
│
├── C1.5  Configuration Change Logging
│   └── C1.5.1  Record configuration changes
│
├── C1.6  Retention Management
│   └── C1.6.1  Retention policies per entry type
│
└── C1.7  Cross-Cutting
    ├── C1.7.1  Tenant isolation
    └── C1.7.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide audit log management modelled on SAP Audit Log Service. |
| **Vision** | Enable every BTP application to write tamper-evident audit logs that satisfy regulatory and internal compliance requirements. |
| **Scope** | Audit log entries, security events, data access logs, config change logs, export jobs, audit config, and retention policies. |
| **Stakeholders** | Compliance Officers, Security Analysts, Platform Operators. |

---

## 3. Service View (NSV)

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-ALE-CRUD | Audit Log Entry | `/api/v1/audit-log-entries` | GET, POST |
| SVC-SE-CRUD | Security Event | `/api/v1/security-events` | GET, POST |
| SVC-DAL-CRUD | Data Access Log | `/api/v1/data-access-logs` | GET, POST |
| SVC-CCL-CRUD | Config Change Log | `/api/v1/config-change-logs` | GET, POST |
| SVC-EJ-CRUD | Export Job | `/api/v1/export-jobs` | GET, POST, DELETE |
| SVC-AC-CRUD | Audit Config | `/api/v1/audit-configs` | GET, POST, PUT |
| SVC-RP-CRUD | Retention Policy | `/api/v1/retention-policies` | GET, POST, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  BTP Application /  │ ─────────────────> │  Audit Log Service           │
│  Compliance Officer │                    │  port 8085                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `AuditLogEntry` | Base audit record |
| `SecurityEvent` | Security-relevant log entry |
| `DataAccessLog` | Personal data access event |
| `ConfigChangeLog` | Configuration change record |
| `ExportJob` | Bulk audit log export task |
| `AuditConfig` | Logging configuration per application |
| `RetentionPolicy` | Retention period per log type |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: auditlog-config
│   AUDITLOG_HOST: "0.0.0.0"
│   AUDITLOG_PORT: "8085"
├── Deployment: auditlog  port: 8085
└── Service: auditlog (ClusterIP :8085)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Write-once log entries | Tamper evidence |
| AD-2 | Three log type subtypes | Aligns with SAP audit categories |
| AD-3 | Export jobs | Offload compliance archives |
| AD-4 | Retention policies | Regulatory compliance |
| AD-5 | Port 8085 | Consistent UIM platform port allocation |
