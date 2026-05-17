# NAF v4 Architecture Description — Credential Store Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Credential Store Service — namespace-scoped credential management, keyring
> versioning, service bindings, and credential access audit.

---

## 1. NAF v4 Grid Mapping

| NAF View | Viewpoint | Covered Below |
|---|---|---|
| **NCV** – NATO Capability View | C1 Capability Taxonomy, C2 Enterprise Vision | §2 |
| **NSV** – NATO Service View | NSOV-1 Service Taxonomy, NSOV-2 Service Definitions | §3 |
| **NOV** – NATO Operational View | NOV-2 Operational Node Connectivity | §4 |
| **NLV** – NATO Logical View | NLV-1 Logical Data Model | §5 |
| **NPV** – NATO Physical View | NPV-1 Physical Deployment | §6 |
| **NIV** – NATO Information View | NIV-1 Information Structure | §7 |

---

## 2. Capability View (NCV)

### C1 – Capability Taxonomy

```
Credential Store
├── C1.1  Namespace Management
│   ├── C1.1.1  Create / update / delete namespaces
│   └── C1.1.2  Namespace-scoped access control
│
├── C1.2  Credential Lifecycle
│   ├── C1.2.1  Store credentials (password, key, certificate, OAuth2)
│   ├── C1.2.2  Retrieve credentials with audit trail
│   ├── C1.2.3  Update and rotate credentials
│   └── C1.2.4  Expiry management
│
├── C1.3  Keyring Versioning
│   ├── C1.3.1  Named keyring with multiple versions
│   └── C1.3.2  Encrypted key storage
│
├── C1.4  Service Binding
│   ├── C1.4.1  Bind applications to namespaces
│   └── C1.4.2  Binding key generation
│
└── C1.5  Audit Trail
    └── C1.5.1  Immutable read/write audit per credential operation
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide a secure, namespace-scoped credential store modelled on SAP Credential Store for BTP. |
| **Vision** | Enable applications to securely store and retrieve passwords, keys, and certificates without hardcoding secrets, with full audit visibility. |
| **Scope** | Credential CRUD, namespace isolation, keyring versioning, service binding, and access audit. |
| **Stakeholders** | Application Developers, Security Officers, Platform Operators. |

---

## 3. Service View (NSV)

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-NS-CRUD | Namespace | `/api/v1/namespaces` | GET, POST, PUT, DELETE |
| SVC-CR-CRUD | Credential | `/api/v1/credentials` | GET, POST, PUT, DELETE |
| SVC-KV-CRUD | Keyring Version | `/api/v1/keyring-versions` | GET, POST, DELETE |
| SVC-SB-CRUD | Service Binding | `/api/v1/service-bindings` | GET, POST, DELETE |
| SVC-AL-LIST | Audit Log | `/api/v1/audit-log` | GET |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Application /      │ ─────────────────> │  Credential Store Service    │
│  Platform Operator  │                    │  port 8095                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `Namespace` | Root aggregate; scopes Credentials, KeyringVersions, ServiceBindings, AuditLogEntries |
| `Credential` | Belongs to Namespace; typed (password/key/certificate/OAuth2); expiry-aware |
| `KeyringVersion` | Belongs to Namespace; named keyring with version number |
| `ServiceBinding` | Links application to Namespace; carries binding key |
| `AuditLogEntry` | Append-only; correlates to Namespace and Credential operation |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: credential-store-config
│   CREDENTIAL_STORE_HOST: "0.0.0.0"
│   CREDENTIAL_STORE_PORT: "8095"
├── Deployment: credential-store  port: 8095
└── Service: credential-store (ClusterIP :8095)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Namespace scoping | Mirrors SAP Credential Store's namespace isolation model |
| AD-2 | Immutable audit log | Guarantees access audit trail integrity |
| AD-3 | Keyring versioning | Supports credential rotation without breaking consumers |
| AD-4 | In-memory repositories | Fast testing; swap for encrypted RDBMS in production |
| AD-5 | Port 8095 | Consistent UIM platform port allocation |
