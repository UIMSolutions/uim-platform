# NAF v4 Architecture Description — Destination Service


## Documentation update

This document is maintained alongside the implementation, deployment manifests, and tests for the same package so the service documentation stays aligned with the codebase.

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Destination Service — outbound connectivity configuration, destination lookup,
> fragment composition, certificate management, and authentication token retrieval.

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
Destination
├── C1.1  Destination Management
│   ├── C1.1.1  CRUD for subaccount and service instance destinations
│   └── C1.1.2  Proxy type and authentication configuration
│
├── C1.2  Destination Fragments
│   └── C1.2.1  Modular destination overrides and extensions
│
├── C1.3  Destination Lookup
│   ├── C1.3.1  Resolve destination by name and subaccount
│   └── C1.3.2  Merged destination resolution with fragments
│
├── C1.4  Certificate Management
│   ├── C1.4.1  Upload and store mTLS certificates
│   └── C1.4.2  Certificate expiry tracking
│
├── C1.5  Authentication Token
│   └── C1.5.1  Retrieve OAuth/JWT tokens for configured destinations
│
└── C1.6  Cross-Cutting
    ├── C1.6.1  Tenant isolation
    └── C1.6.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide outbound connectivity management modelled on SAP BTP Destination Service. |
| **Vision** | Enable BTP applications to centralise remote system URLs and authentication credentials, retrieve merged destination configurations, and obtain valid authentication tokens at runtime. |
| **Scope** | Destination CRUD, fragment composition, lookup API, certificate store, auth token retrieval. |
| **Stakeholders** | Application Developers, Integration Architects, Platform Operators. |

---

## 3. Service View (NSV)

### NSOV-2 – Service Definitions

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-DEST-CRUD | Destination | `/api/v1/destinations` | GET, POST, PUT, DELETE |
| SVC-FRAG-CRUD | Destination Fragment | `/api/v1/destination-fragments` | GET, POST, DELETE |
| SVC-LOOKUP | Destination Lookup | `/api/v1/destination-lookup` | GET |
| SVC-CERT-CRUD | Certificate | `/api/v1/certificates` | GET, POST, DELETE |
| SVC-TOK-LIST | Auth Token | `/api/v1/auth-tokens` | GET |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  BTP Application    │ ─────────────────> │  Destination Service         │
│  / Platform Ops     │                    │  port 8094                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `Destination` | Root; typed (HTTP, RFC, MAIL, LDAP); holds auth config |
| `DestinationFragment` | Overrides specific properties of a parent Destination |
| `DestinationLookup` | Resolution event; merges Destination + Fragment |
| `Certificate` | mTLS certificate; linked to Destination for client auth |
| `AuthToken` | OAuth/JWT token scoped to a Destination; time-limited |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: destination-config
│   DESTINATION_HOST: "0.0.0.0"
│   DESTINATION_PORT: "8094"
├── Deployment: destination  port: 8094
└── Service: destination (ClusterIP :8094)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Fragment composition model | Mirrors SAP Destination Service's fragment override mechanism |
| AD-2 | Certificate store | Supports mTLS-based outbound authentication |
| AD-3 | Lookup API | Single resolution endpoint as per BTP Destination Service pattern |
| AD-4 | In-memory repositories | Fast testing; swap for encrypted store in production |
| AD-5 | Port 8094 | Consistent UIM platform port allocation |
