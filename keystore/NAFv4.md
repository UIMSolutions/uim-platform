# NAF v4 Architecture Description — Keystore Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Keystore Service — cryptographic keystore management for certificates,
> key pairs, and key passwords modelled on SAP Keystore Service.

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
Keystore
├── C1.1  Keystore Management
│   └── C1.1.1  Create and manage named keystores
│
├── C1.2  Key Entry Management
│   ├── C1.2.1  Import certificates and key pairs
│   └── C1.2.2  Alias-based key lookup
│
├── C1.3  Key Password Management
│   └── C1.3.1  Encrypted key password storage
│
└── C1.4  Cross-Cutting
    ├── C1.4.1  Tenant isolation
    └── C1.4.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide keystore management modelled on SAP BTP Keystore Service. |
| **Vision** | Give integration and application developers a central, tenant-isolated store for certificates and private key material. |
| **Scope** | Keystores, key entries (cert + key pair), and key passwords. |
| **Stakeholders** | Integration Developers, Security Architects, Platform Operators. |

---

## 3. Service View (NSV)

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-KS-CRUD | Keystore Entity | `/api/v1/keystores` | GET, POST, DELETE |
| SVC-KE-CRUD | Key Entry | `/api/v1/key-entries` | GET, POST, DELETE |
| SVC-KP-CRUD | Key Password | `/api/v1/key-passwords` | GET, POST, DELETE |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Integration Dev /  │ ─────────────────> │  Keystore Service            │
│  Platform Admin     │                    │  port 8115                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `KeystoreEntity` | Named keystore container |
| `KeyEntry` | Certificate or key pair within a Keystore |
| `KeyPassword` | Encrypted password for a KeyEntry |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: keystore-config
│   KEYSTORE_HOST: "0.0.0.0"
│   KEYSTORE_PORT: "8115"
├── Deployment: keystore  port: 8115
└── Service: keystore (ClusterIP :8115)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Alias-based key lookup | Mirrors SAP BTP Keystore alias API |
| AD-2 | Separate password store | Encrypted at rest separately from key material |
| AD-3 | Tenant isolation | Each tenant has independent keystores |
| AD-4 | In-memory repositories | Fast testing; swap for HSM/KMS in production |
| AD-5 | Port 8115 | Consistent UIM platform port allocation |
