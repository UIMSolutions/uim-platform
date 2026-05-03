# Custom Domain Service - UML Diagrams

## Domain Model (Class Diagram)

```mermaid
classDiagram
    class CustomDomain {
        +string id
        +TenantId tenantId
        +string domainName
        +DomainStatus status
        +DomainEnvironment environment
        +string organizationId
        +string spaceId
        +string activeCertificateId
        +string tlsConfigurationId
        +bool isShared
        +string sharedWithOrgs
        +bool clientAuthEnabled
        +UserId createdBy
        +UserId updatedBy
        +string createdAt
        +string updatedAt
    }

    class PrivateKey {
        +string id
        +TenantId tenantId
        +string subject
        +string[] domains
        +KeyAlgorithm algorithm
        +int keySize
        +KeyStatus status
        +string publicKeyFingerprint
        +string csrPem
        +UserId createdBy
        +string createdAt
    }

    class Certificate {
        +string id
        +TenantId tenantId
        +string keyId
        +CertificateType type
        +CertificateStatus status
        +string subjectDn
        +string issuerDn
        +string serialNumber
        +string fingerprint
        +string[] subjectAlternativeNames
        +CertificateChainEntry[] chain
        +string[] activatedDomains
        +string validFrom
        +string validTo
        +string activatedAt
        +UserId createdBy
        +string createdAt
    }

    class TlsConfiguration {
        +string id
        +TenantId tenantId
        +string name
        +string description
        +TlsProtocolVersion minProtocolVersion
        +TlsProtocolVersion maxProtocolVersion
        +CipherSuite[] cipherSuites
        +bool http2Enabled
        +bool hstsEnabled
        +long hstsMaxAge
        +bool hstsIncludeSubDomains
        +UserId createdBy
        +UserId updatedBy
        +string createdAt
        +string updatedAt
    }

    class DomainMapping {
        +string id
        +TenantId tenantId
        +string customDomainId
        +string standardRoute
        +string customRoute
        +MappingType mappingType
        +MappingStatus status
        +string applicationName
        +string organizationId
        +string spaceId
        +UserId createdBy
        +string createdAt
        +string updatedAt
    }

    class TrustedCertificate {
        +string id
        +TenantId tenantId
        +string customDomainId
        +string certificatePem
        +string subjectDn
        +string issuerDn
        +string serialNumber
        +string fingerprint
        +TrustedCertificateStatus status
        +ClientAuthMode authMode
        +string validFrom
        +string validTo
        +UserId createdBy
        +string createdAt
    }

    class DnsRecord {
        +string id
        +TenantId tenantId
        +string customDomainId
        +DnsRecordType recordType
        +string hostname
        +string value
        +int ttl
        +DnsValidationStatus validationStatus
        +string lastValidatedAt
        +UserId createdBy
        +string createdAt
        +string updatedAt
    }

    class DomainDashboard {
        +string id
        +TenantId tenantId
        +long totalDomains
        +long activeDomains
        +long totalCertificates
        +long activeCertificates
        +long totalMappings
        +long activeMappings
        +HealthStatus overallHealth
        +DashboardMetric[] metrics
        +CertificateExpirationWarning[] expirationWarnings
        +string lastUpdatedAt
    }

    CustomDomain "1" --> "0..*" DomainMapping : has mappings
    CustomDomain "1" --> "0..*" TrustedCertificate : has trusted certs
    CustomDomain "1" --> "0..*" DnsRecord : has DNS records
    CustomDomain "1" --> "0..1" TlsConfiguration : configured with
    CustomDomain "1" --> "0..1" Certificate : active certificate
    PrivateKey "1" --> "0..*" Certificate : generates
    Certificate "1" --> "0..*" CustomDomain : activated on
```

## Enumerations

```mermaid
classDiagram
    class DomainStatus {
        <<enumeration>>
        pending
        active
        inactive
        error
        deleting
    }

    class CertificateStatus {
        <<enumeration>>
        pending
        issued
        active
        expired
        revoked
        error
    }

    class KeyAlgorithm {
        <<enumeration>>
        rsa2048
        rsa4096
        ecdsaP256
        ecdsaP384
    }

    class TlsProtocolVersion {
        <<enumeration>>
        tls1_0
        tls1_1
        tls1_2
        tls1_3
    }

    class DnsRecordType {
        <<enumeration>>
        cname
        aRecord
        txtRecord
    }

    class MappingType {
        <<enumeration>>
        standard
        wildcard
        pathBased
    }
```

## Hexagonal Architecture (Component Diagram)

```mermaid
graph TB
    subgraph "Driving Adapters (Primary)"
        HTTP["HTTP Controllers<br/>(vibe.d)"]
    end

    subgraph "Application Core"
        subgraph "Application Layer"
            UC1["ManageCustomDomainsUseCase"]
            UC2["ManagePrivateKeysUseCase"]
            UC3["ManageCertificatesUseCase"]
            UC4["ManageTlsConfigurationsUseCase"]
            UC5["ManageDomainMappingsUseCase"]
            UC6["ManageTrustedCertificatesUseCase"]
            UC7["ManageDnsRecordsUseCase"]
            UC8["ManageDomainDashboardsUseCase"]
        end

        subgraph "Domain Layer"
            E1["CustomDomain"]
            E2["PrivateKey"]
            E3["Certificate"]
            E4["TlsConfiguration"]
            E5["DomainMapping"]
            E6["TrustedCertificate"]
            E7["DnsRecord"]
            E8["DomainDashboard"]
            VS["DomainValidator"]
        end

        subgraph "Ports (Interfaces)"
            P1["CustomDomainRepository"]
            P2["PrivateKeyRepository"]
            P3["CertificateRepository"]
            P4["TlsConfigurationRepository"]
            P5["DomainMappingRepository"]
            P6["TrustedCertificateRepository"]
            P7["DnsRecordRepository"]
            P8["DomainDashboardRepository"]
        end
    end

    subgraph "Driven Adapters (Secondary)"
        MEM["Memory Repositories"]
        FILE["File Repositories<br/>(placeholder)"]
        MONGO["MongoDB Repositories<br/>(placeholder)"]
    end

    HTTP --> UC1
    HTTP --> UC2
    HTTP --> UC3
    HTTP --> UC4
    HTTP --> UC5
    HTTP --> UC6
    HTTP --> UC7
    HTTP --> UC8

    UC1 --> P1
    UC2 --> P2
    UC3 --> P3
    UC4 --> P4
    UC5 --> P5
    UC6 --> P6
    UC7 --> P7
    UC8 --> P8

    MEM -.-> P1
    MEM -.-> P2
    MEM -.-> P3
    MEM -.-> P4
    MEM -.-> P5
    MEM -.-> P6
    MEM -.-> P7
    MEM -.-> P8

    FILE -.-> P1
    MONGO -.-> P1
```

## Certificate Lifecycle (Sequence Diagram)

```mermaid
sequenceDiagram
    actor User
    participant API as HTTP API
    participant DomUC as ManageCustomDomainsUseCase
    participant KeyUC as ManagePrivateKeysUseCase
    participant CertUC as ManageCertificatesUseCase
    participant TlsUC as ManageTlsConfigurationsUseCase
    participant MapUC as ManageDomainMappingsUseCase
    participant DnsUC as ManageDnsRecordsUseCase
    participant Repo as Repositories

    User->>API: POST /domains {domainName}
    API->>DomUC: create(request)
    DomUC->>Repo: save(domain)
    Repo-->>DomUC: success
    DomUC-->>API: CommandResult{id}
    API-->>User: 201 Created

    User->>API: POST /keys {subject, algorithm}
    API->>KeyUC: create(request)
    KeyUC->>Repo: save(key + CSR)
    Repo-->>KeyUC: success
    KeyUC-->>API: CommandResult{id}
    API-->>User: 201 Created

    User->>API: POST /certificates {keyId}
    API->>CertUC: create(request)
    CertUC->>Repo: save(certificate)
    Repo-->>CertUC: success
    CertUC-->>API: CommandResult{id}
    API-->>User: 201 Created

    Note over User: Submit CSR to CA, receive signed cert

    User->>API: POST /certificates/{id}/upload-chain
    API->>CertUC: uploadChain(request)
    CertUC->>Repo: update(certificate)
    Repo-->>CertUC: success
    CertUC-->>API: CommandResult{id}
    API-->>User: 200 OK

    User->>API: POST /certificates/{id}/activate
    API->>CertUC: activate(request)
    CertUC->>Repo: update(certificate.status=active)
    Repo-->>CertUC: success
    CertUC-->>API: CommandResult{id}
    API-->>User: 200 OK

    User->>API: POST /tls-configurations {minVersion, http2}
    API->>TlsUC: create(request)
    TlsUC->>Repo: save(tlsConfig)
    Repo-->>TlsUC: success
    TlsUC-->>API: CommandResult{id}
    API-->>User: 201 Created

    User->>API: POST /dns-records {domainId, type, value}
    API->>DnsUC: create(request)
    DnsUC->>Repo: save(dnsRecord)
    Repo-->>DnsUC: success
    DnsUC-->>API: CommandResult{id}
    API-->>User: 201 Created

    User->>API: POST /mappings {standardRoute, customRoute}
    API->>MapUC: create(request)
    MapUC->>Repo: save(mapping)
    Repo-->>MapUC: success
    MapUC-->>API: CommandResult{id}
    API-->>User: 201 Created
```

## Deployment (Component Diagram)

```mermaid
graph LR
    subgraph "Kubernetes Cluster"
        subgraph "Pod: cloud-custom-domain"
            APP["Custom Domain Service<br/>:8101"]
        end
        SVC["K8s Service<br/>ClusterIP:8101"]
        CM["ConfigMap<br/>cloud-custom-domain-config"]
    end

    subgraph "Container Build"
        DF["Dockerfile / Containerfile"]
        IMG["Container Image<br/>uim-platform/cloud-custom-domain"]
    end

    CLIENT["API Client"] --> SVC
    SVC --> APP
    CM -.-> APP
    DF --> IMG
    IMG --> APP
```

## Request Processing Flow (Activity Diagram)

```mermaid
flowchart TD
    A[HTTP Request] --> B{Route Match?}
    B -->|No| C[404 Not Found]
    B -->|Yes| D[Controller Handler]
    D --> E[Parse JSON Body]
    E --> F[Extract Tenant ID from Header]
    F --> G[Build Request DTO]
    G --> H[Call Use Case]
    H --> I{Validation OK?}
    I -->|No| J[Return 400 Bad Request]
    I -->|Yes| K[Execute Repository Operation]
    K --> L{Success?}
    L -->|No| M[Return 404 Not Found]
    L -->|Yes| N[Return 200/201 JSON Response]
```
