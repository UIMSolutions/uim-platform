# NAF v4 Architecture Description — Custom Domain Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Custom Domain Service — custom domain registration, TLS certificate management,
> DNS records, domain mappings, and trust certificates modelled on SAP Custom Domain Service.

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
Custom Domain
├── C1.1  Domain Management
│   ├── C1.1.1  Register and activate custom domains
│   └── C1.1.2  Domain status monitoring
│
├── C1.2  Certificate Management
│   ├── C1.2.1  Upload TLS certificates and private keys
│   └── C1.2.2  Certificate renewal tracking
│
├── C1.3  Domain Mapping
│   └── C1.3.1  Map custom domains to BTP routes
│
├── C1.4  DNS Management
│   └── C1.4.1  DNS record CRUD
│
├── C1.5  Trust Certificates
│   └── C1.5.1  Manage trusted CA certificates
│
├── C1.6  Dashboard
│   └── C1.6.1  Domain health and expiry overview
│
└── C1.7  Cross-Cutting
    ├── C1.7.1  Tenant isolation
    └── C1.7.2  Health monitoring
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide custom domain management modelled on SAP Custom Domain Service. |
| **Vision** | Allow BTP customers to expose their applications under their own branded domain names with full TLS governance. |
| **Scope** | Custom domains, certificates, private keys, TLS configurations, domain mappings, DNS records, and trusted certificates. |
| **Stakeholders** | Platform Admins, Network Engineers, Application Owners. |

---

## 3. Service View (NSV)

| Service ID | Name | Path Prefix | Methods |
|---|---|---|---|
| SVC-DOM-CRUD | Custom Domain | `/api/v1/custom-domains` | GET, POST, DELETE |
| SVC-CERT-CRUD | Certificate | `/api/v1/certificates` | GET, POST, DELETE |
| SVC-KEY-CRUD | Private Key | `/api/v1/private-keys` | GET, POST, DELETE |
| SVC-TLS-CRUD | TLS Configuration | `/api/v1/tls-configurations` | GET, POST, PUT, DELETE |
| SVC-MAP-CRUD | Domain Mapping | `/api/v1/domain-mappings` | GET, POST, DELETE |
| SVC-DNS-CRUD | DNS Record | `/api/v1/dns-records` | GET, POST, DELETE |
| SVC-TRUST-CRUD | Trusted Certificate | `/api/v1/trusted-certificates` | GET, POST, DELETE |
| SVC-DASH-LIST | Domain Dashboard | `/api/v1/domain-dashboard` | GET |
| SVC-HLTH | Health Check | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

```
┌────────────────────┐   REST/HTTP/JSON   ┌──────────────────────────────┐
│  Platform Admin /   │ ─────────────────> │  Custom Domain Service       │
│  DevOps Team        │                    │  port 8101                    │
└────────────────────┘                    └──────────────────────────────┘
```

---

## 5. Logical View (NLV)

| Entity | Key Relationships |
|---|---|
| `CustomDomain` | Root; parent of DomainMappings |
| `Certificate` | TLS cert linked to CustomDomain |
| `PrivateKey` | Key paired with Certificate |
| `TlsConfiguration` | Certificate + key binding |
| `DomainMapping` | Maps CustomDomain to BTP route |
| `DnsRecord` | DNS entry for a CustomDomain |
| `TrustedCertificate` | CA cert for mutual TLS |
| `DomainDashboard` | Aggregated expiry / health view |

---

## 6. Physical View (NPV)

```
Kubernetes Cluster — Namespace: uim-platform
├── ConfigMap: custom-domain-config
│   CUSTOM_DOMAIN_HOST: "0.0.0.0"
│   CUSTOM_DOMAIN_PORT: "8101"
├── Deployment: custom-domain  port: 8101
└── Service: custom-domain (ClusterIP :8101)
```

---

## 7. Architecture Decisions

| ID | Decision | Rationale |
|---|---|---|
| AD-1 | Domain-centric model | Mirrors SAP Custom Domain Service |
| AD-2 | TLS configuration separation | Decouples cert from binding |
| AD-3 | DNS record management | Full domain lifecycle within service |
| AD-4 | In-memory repositories | Fast testing |
| AD-5 | Port 8101 | Consistent UIM platform port allocation |
