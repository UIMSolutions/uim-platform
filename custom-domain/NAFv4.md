# Custom Domain Service - NATO Architecture Framework v4 (NAF v4)

This document describes the Custom Domain Service using NATO Architecture Framework version 4 viewpoints, providing a standardized architectural description for interoperability and compliance.

## NAF v4 Overview

The NATO Architecture Framework v4 organizes architecture descriptions into viewpoints grouped by concerns. This document covers the most relevant viewpoints for the Custom Domain Service.

---

## 1. Concepts Viewpoint (C1 - Capability Taxonomy)

### 1.1 Capability Taxonomy

| Capability ID | Capability Name | Description |
|--------------|----------------|-------------|
| CAP-CD-001 | Custom Domain Management | Register, activate, deactivate, and share custom domain names |
| CAP-CD-002 | Cryptographic Key Management | Generate and manage RSA/ECDSA key pairs for TLS |
| CAP-CD-003 | Certificate Lifecycle Management | Request, upload, activate, and track TLS/SSL certificates |
| CAP-CD-004 | Transport Security Configuration | Configure TLS protocol versions, cipher suites, HSTS, HTTP/2 |
| CAP-CD-005 | Domain Route Mapping | Map standard application routes to custom domain routes |
| CAP-CD-006 | Client Authentication | Manage trusted CA certificates for mutual TLS (mTLS) |
| CAP-CD-007 | DNS Record Management | Create and validate DNS records for domain verification |
| CAP-CD-008 | Domain Health Monitoring | Dashboard with KPIs, certificate expiration warnings |

### 1.2 Capability Dependencies

```
CAP-CD-003 depends on CAP-CD-002 (certificates need keys)
CAP-CD-005 depends on CAP-CD-001 (mappings need domains)
CAP-CD-006 depends on CAP-CD-001 (trusted certs bound to domains)
CAP-CD-007 depends on CAP-CD-001 (DNS records bound to domains)
CAP-CD-004 depends on CAP-CD-001 (TLS config applied to domains)
CAP-CD-008 depends on CAP-CD-001, CAP-CD-003, CAP-CD-005 (aggregates metrics)
```

---

## 2. Service Viewpoint (S1 - Service Taxonomy)

### 2.1 Service Identification

| Attribute | Value |
|-----------|-------|
| Service Name | Custom Domain Service |
| Service ID | SVC-PLATFORM-CUSTOM-DOMAIN |
| Version | 1.0.0 |
| Protocol | HTTP/REST (JSON) |
| Port | 8101 |
| Base Path | `/api/v1/custom-domain/` |
| Health Endpoint | `/api/v1/health` |

### 2.2 Service Interface Taxonomy

| Interface ID | Interface Name | HTTP Method | Resource Path | Input | Output |
|-------------|---------------|-------------|---------------|-------|--------|
| IF-CD-001 | CreateDomain | POST | /domains | CreateCustomDomainRequest | CommandResult |
| IF-CD-002 | ListDomains | GET | /domains | X-Tenant-Id header | Domain[] |
| IF-CD-003 | GetDomain | GET | /domains/{id} | path id | Domain |
| IF-CD-004 | UpdateDomain | PUT | /domains/{id} | UpdateCustomDomainRequest | CommandResult |
| IF-CD-005 | ActivateDomain | POST | /domains/{id}/activate | path id | CommandResult |
| IF-CD-006 | DeactivateDomain | POST | /domains/{id}/deactivate | path id | CommandResult |
| IF-CD-007 | DeleteDomain | DELETE | /domains/{id} | path id | CommandResult |
| IF-CD-010 | CreateKey | POST | /keys | CreatePrivateKeyRequest | CommandResult |
| IF-CD-011 | ListKeys | GET | /keys | X-Tenant-Id header | PrivateKey[] |
| IF-CD-012 | GetKey | GET | /keys/{id} | path id | PrivateKey |
| IF-CD-013 | DeleteKey | DELETE | /keys/{id} | path id | CommandResult |
| IF-CD-020 | CreateCertificate | POST | /certificates | CreateCertificateRequest | CommandResult |
| IF-CD-021 | UploadChain | POST | /certificates/{id}/upload-chain | UploadCertificateChainRequest | CommandResult |
| IF-CD-022 | ActivateCertificate | POST | /certificates/{id}/activate | ActivateCertificateRequest | CommandResult |
| IF-CD-023 | DeactivateCertificate | POST | /certificates/{id}/deactivate | path id | CommandResult |
| IF-CD-024 | ListCertificates | GET | /certificates | X-Tenant-Id header | Certificate[] |
| IF-CD-025 | GetCertificate | GET | /certificates/{id} | path id | Certificate |
| IF-CD-026 | DeleteCertificate | DELETE | /certificates/{id} | path id | CommandResult |
| IF-CD-030 | CreateTlsConfig | POST | /tls-configurations | CreateTlsConfigurationRequest | CommandResult |
| IF-CD-031 | UpdateTlsConfig | PUT | /tls-configurations/{id} | UpdateTlsConfigurationRequest | CommandResult |
| IF-CD-032 | ListTlsConfigs | GET | /tls-configurations | X-Tenant-Id header | TlsConfiguration[] |
| IF-CD-033 | GetTlsConfig | GET | /tls-configurations/{id} | path id | TlsConfiguration |
| IF-CD-034 | DeleteTlsConfig | DELETE | /tls-configurations/{id} | path id | CommandResult |
| IF-CD-040 | CreateMapping | POST | /mappings | CreateDomainMappingRequest | CommandResult |
| IF-CD-041 | ListMappings | GET | /mappings | X-Tenant-Id header | DomainMapping[] |
| IF-CD-042 | GetMapping | GET | /mappings/{id} | path id | DomainMapping |
| IF-CD-043 | DeleteMapping | DELETE | /mappings/{id} | path id | CommandResult |
| IF-CD-050 | CreateTrustedCert | POST | /trusted-certificates | CreateTrustedCertificateRequest | CommandResult |
| IF-CD-051 | ListTrustedCerts | GET | /trusted-certificates | X-Tenant-Id header | TrustedCertificate[] |
| IF-CD-052 | GetTrustedCert | GET | /trusted-certificates/{id} | path id | TrustedCertificate |
| IF-CD-053 | DeleteTrustedCert | DELETE | /trusted-certificates/{id} | path id | CommandResult |
| IF-CD-060 | CreateDnsRecord | POST | /dns-records | CreateDnsRecordRequest | CommandResult |
| IF-CD-061 | UpdateDnsRecord | PUT | /dns-records/{id} | UpdateDnsRecordRequest | CommandResult |
| IF-CD-062 | ListDnsRecords | GET | /dns-records | X-Tenant-Id header | DnsRecord[] |
| IF-CD-063 | GetDnsRecord | GET | /dns-records/{id} | path id | DnsRecord |
| IF-CD-064 | DeleteDnsRecord | DELETE | /dns-records/{id} | path id | CommandResult |
| IF-CD-070 | GetDashboard | GET | /dashboard | X-Tenant-Id header | DomainDashboard |
| IF-CD-071 | RefreshDashboard | POST | /dashboard/refresh | RefreshDashboardRequest | CommandResult |

---

## 3. Systems Viewpoint (L1 - Node Types)

### 3.1 Logical Node Types

| Node Type | Description | Technology |
|-----------|-------------|------------|
| Application Server | Custom Domain Service runtime | D language / vibe.d HTTP server |
| In-Memory Store | Default persistence layer | D associative arrays |
| Container Runtime | OCI-compliant container | Docker / Podman |
| Orchestrator | Container orchestration | Kubernetes |
| Load Balancer | External traffic entry | Kubernetes Service (ClusterIP) |

### 3.2 Node Connectivity

```
[API Client] --> [K8s Service :8101] --> [Pod: Custom Domain Service]
                                              |
                                              v
                                     [In-Memory Store]
```

---

## 4. Technical Standards Viewpoint (Lr - Lines of Development)

### 4.1 Technical Standards Profile

| Standard Area | Standard | Version | Conformance |
|--------------|---------|---------|-------------|
| API Protocol | HTTP/1.1 | RFC 7230-7235 | Mandatory |
| Data Format | JSON | RFC 8259 | Mandatory |
| TLS | TLS 1.2, 1.3 | RFC 5246, 8446 | Mandatory |
| Container | OCI Image Spec | 1.0 | Mandatory |
| Orchestration | Kubernetes API | v1 | Mandatory |
| Key Algorithms | RSA | FIPS 186-4 | Mandatory |
| Key Algorithms | ECDSA (P-256, P-384) | FIPS 186-4 | Optional |
| Certificate Format | X.509 v3 | RFC 5280 | Mandatory |
| HSTS | HTTP Strict Transport Security | RFC 6797 | Optional |
| HTTP/2 | HTTP/2 | RFC 7540 | Optional |

### 4.2 Security Standards

| Aspect | Implementation |
|--------|---------------|
| Authentication | X-Tenant-Id header-based tenant isolation |
| Authorization | Role-based (future: OAuth2/OIDC integration) |
| Transport Security | TLS 1.2+ with configurable cipher suites |
| Client Authentication | Mutual TLS (mTLS) with trusted CA certificates |
| Container Security | Non-root user, read-only filesystem |
| Health Monitoring | HTTP health check endpoint with liveness/readiness probes |

---

## 5. Operational Viewpoint (P1 - Resource Structure)

### 5.1 Resource Types

| Resource | Kubernetes Kind | Name |
|----------|----------------|------|
| Workload | Deployment | cloud-custom-domain |
| Network | Service (ClusterIP) | cloud-custom-domain |
| Configuration | ConfigMap | cloud-custom-domain-config |

### 5.2 Resource Configuration

| Parameter | Source | Default |
|-----------|--------|---------|
| CUSTOM_DOMAIN_HOST | ConfigMap | 0.0.0.0 |
| CUSTOM_DOMAIN_PORT | ConfigMap | 8101 |
| Replicas | Deployment spec | 1 |
| Memory Request | Container resources | 64Mi |
| Memory Limit | Container resources | 256Mi |
| CPU Request | Container resources | 100m |
| CPU Limit | Container resources | 500m |

### 5.3 Health Probes

| Probe | Path | Port | Interval | Timeout |
|-------|------|------|----------|---------|
| Liveness | /api/v1/health | 8101 | 30s | 3s |
| Readiness | /api/v1/health | 8101 | 10s | 3s |
| Container HEALTHCHECK | /api/v1/health | 8101 | 30s | 3s |

---

## 6. Architecture Patterns (C2 - Enterprise Phase)

### 6.1 Clean / Hexagonal Architecture Layers

| Layer | Purpose | Components |
|-------|---------|------------|
| Domain | Core business logic, entities, value objects | 8 entities, types, domain validator |
| Application | Use cases, orchestration, DTOs | 8 use cases, request/result DTOs |
| Infrastructure | Technical adapters, DI container, config | Memory repositories, container, config |
| Presentation | HTTP interface, request/response handling | 8 REST controllers |

### 6.2 Dependency Rule

All dependencies point inward: Presentation -> Application -> Domain. Infrastructure implements Domain ports (repository interfaces) and is wired at startup via the Container (dependency injection).

```
Presentation (HTTP)
       |
       v
Application (Use Cases)
       |
       v
Domain (Entities + Ports)
       ^
       |
Infrastructure (Adapters)
```

### 6.3 Data Flow

1. HTTP request arrives at vibe.d router
2. Controller extracts tenant ID, parses JSON body, builds DTO
3. Use case validates input, executes business logic
4. Repository adapter persists/retrieves entities
5. Use case returns CommandResult or entity
6. Controller serializes response as JSON

---

## 7. Information Viewpoint (L2 - Logical Data Model)

### 7.1 Entity Relationships

| Source Entity | Relationship | Target Entity | Cardinality |
|--------------|-------------|---------------|-------------|
| CustomDomain | has active | Certificate | 1:0..1 |
| CustomDomain | configured with | TlsConfiguration | 1:0..1 |
| CustomDomain | has | DomainMapping | 1:0..* |
| CustomDomain | has | TrustedCertificate | 1:0..* |
| CustomDomain | has | DnsRecord | 1:0..* |
| PrivateKey | generates | Certificate | 1:0..* |
| Certificate | activated on | CustomDomain | 0..*:0..* |
| DomainDashboard | aggregates | CustomDomain, Certificate, DomainMapping | 1:0..* |

### 7.2 Tenant Isolation

All entities include a `tenantId` field. Queries are scoped by tenant ID extracted from the `X-Tenant-Id` HTTP header. This ensures strict data isolation between tenants in a multi-tenant deployment.

---

## 8. All-Viewpoint Summary (Ar1 - Architecture Overview)

```
+-------------------------------------------------------------------+
|                    Custom Domain Service v1.0                      |
+-------------------------------------------------------------------+
|  Capabilities: Domain Mgmt, Key Mgmt, Cert Lifecycle, TLS Config, |
|                Route Mapping, Client Auth, DNS, Dashboard          |
+-------------------------------------------------------------------+
|  Architecture: Clean/Hexagonal (4 layers, dependency inversion)    |
|  Technology:   D language, vibe.d, OCI containers, Kubernetes      |
|  Protocol:     REST/JSON over HTTP                                 |
|  Port:         8101                                                |
|  Security:     TLS 1.2+, mTLS, tenant isolation, non-root runtime |
|  Standards:    RFC 5280 (X.509), RFC 6797 (HSTS), RFC 7540 (HTTP/2)|
+-------------------------------------------------------------------+
```
