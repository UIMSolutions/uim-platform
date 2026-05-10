# Master Data Governance — NAFv4 Architecture Views

## C1 — Capability Taxonomy

```mermaid
graph TB
    MDG[Master Data Governance Service]

    MDG --> BPM[Business Partner Management]
    MDG --> CRW[Change Request Workflow]
    MDG --> DQM[Data Quality Management]
    MDG --> REP[Replication Management]
    MDG --> HLT[Health Monitoring]

    BPM --> BPM1[Create Business Partner]
    BPM --> BPM2[Update BP Attributes]
    BPM --> BPM3[BP Category Classification]
    BPM --> BPM4[BP Role Assignment]
    BPM --> BPM5[Address Management]
    BPM --> BPM6[Tax Information]
    BPM --> BPM7[Bank Details]
    BPM --> BPM8[Search and Filter]
    BPM --> BPM9[Block / Mark for Deletion]

    CRW --> CRW1[Draft Change Request]
    CRW --> CRW2[Submit for Review]
    CRW --> CRW3[Review and Approve]
    CRW --> CRW4[Reject with Comments]
    CRW --> CRW5[Request Revision]
    CRW --> CRW6[Withdraw Request]
    CRW --> CRW7[Audit Trail]

    DQM --> DQM1[Define Quality Rules]
    DQM --> DQM2[Field-Level Validation]
    DQM --> DQM3[Rule Severity Levels]
    DQM --> DQM4[BP Category Scoping]
    DQM --> DQM5[Score Calculation]
    DQM --> DQM6[Completeness Scoring]
    DQM --> DQM7[Consistency Scoring]
    DQM --> DQM8[Accuracy Scoring]
    DQM --> DQM9[Quality Status Classification]

    REP --> REP1[Trigger Replication]
    REP --> REP2[Full Replication]
    REP --> REP3[Delta Replication]
    REP --> REP4[Selective Replication]
    REP --> REP5[Batch Processing]
    REP --> REP6[Retry Management]
    REP --> REP7[Cancel Replication]
    REP --> REP8[Correlation Tracking]

    HLT --> HLT1[Health Check Endpoint]
    HLT --> HLT2[Service Status]
```

## C2 — Service Taxonomy

```mermaid
graph TB
    subgraph "Master Data Governance Platform Service"
        API[REST API Layer - vibe.d]
        APP[Application Layer - Use Cases]
        DOM[Domain Layer - Entities and Ports]
        INF[Infrastructure Layer - Adapters]
    end

    subgraph "Consumed / Integrated Services"
        IAS[Identity Authentication Service]
        IPS[Identity Provisioning Service]
        MDI[Master Data Integration]
        S4H[SAP S/4HANA Cloud]
        ECC[SAP ECC On-Premise]
        AUD[Auditlog Service]
        DEST[Destination Service]
    end

    API --> APP
    APP --> DOM
    DOM --> INF

    API -.->|Auth token validation| IAS
    INF -.->|User provisioning| IPS
    INF -.->|BP replication| MDI
    INF -.->|BP replication| S4H
    INF -.->|BP replication| ECC
    INF -.->|Change request audit| AUD
    INF -.->|Target system connectivity| DEST
```

## C3 — System Context

```mermaid
graph TB
    subgraph External Users
        BPA[Business Partner Admin]
        DQA[Data Quality Analyst]
        GVA[Governance Approver]
        SYS[Integration Systems]
    end

    subgraph "UIM Platform"
        MDG[Master Data Governance Service :8108]
        MDI[Master Data Integration Service]
        IAS[Identity Authentication Service]
        AUD[Auditlog Service]
    end

    subgraph "Target Systems"
        S4H[SAP S/4HANA Cloud]
        ECC[SAP ECC]
        CUS[Custom Systems]
    end

    BPA -->|Manage BPs via REST API| MDG
    DQA -->|Define quality rules and view scores| MDG
    GVA -->|Approve or reject change requests| MDG
    SYS -->|Trigger replications| MDG

    MDG -->|Replicate approved BPs| MDI
    MDG -->|Validate tokens| IAS
    MDG -->|Write audit events| AUD
    MDI -->|Distribute BPs| S4H
    MDI -->|Distribute BPs| ECC
    MDI -->|Distribute BPs| CUS
```

## L1 — Logical Architecture

```mermaid
graph LR
    subgraph "Domain"
        BP[BusinessPartner]
        CR[ChangeRequest]
        DQR[DataQualityRule]
        DQS[DataQualityScore]
        RPL[Replication]
        VAL[MasterdataGovernanceValidator]
    end

    subgraph "Ports (Interfaces)"
        BPR[BusinessPartnerRepository]
        CRR[ChangeRequestRepository]
        DQRR[DataQualityRuleRepository]
        DQSR[DataQualityScoreRepository]
        RPLR[ReplicationRepository]
    end

    subgraph "Application"
        BPUC[ManageBusinessPartnersUseCase]
        CRUC[ManageChangeRequestsUseCase]
        DQRUC[ManageDataQualityRulesUseCase]
        DQSUC[ManageDataQualityScoresUseCase]
        RPLUC[ManageReplicationsUseCase]
    end

    subgraph "Adapters (Infrastructure)"
        MBPR[MemoryBusinessPartnerRepository]
        MCRR[MemoryChangeRequestRepository]
        MDQRR[MemoryDataQualityRuleRepository]
        MDQSR[MemoryDataQualityScoreRepository]
        MRPLR[MemoryReplicationRepository]
    end

    subgraph "Presentation"
        BPCTL[BusinessPartnerController]
        CRCTL[ChangeRequestController]
        DQRCTL[DataQualityRuleController]
        DQSCTL[DataQualityScoreController]
        RPLCTL[ReplicationController]
    end

    BP --> BPR
    CR --> CRR
    DQR --> DQRR
    DQS --> DQSR
    RPL --> RPLR

    BPUC --> BPR
    CRUC --> CRR
    DQRUC --> DQRR
    DQSUC --> DQSR
    RPLUC --> RPLR

    BPR -.->|implements| MBPR
    CRR -.->|implements| MCRR
    DQRR -.->|implements| MDQRR
    DQSR -.->|implements| MDQSR
    RPLR -.->|implements| MRPLR

    BPCTL --> BPUC
    CRCTL --> CRUC
    DQRCTL --> DQRUC
    DQSCTL --> DQSUC
    RPLCTL --> RPLUC
```

## L2 — Physical Deployment View

```mermaid
graph TB
    subgraph "Kubernetes Cluster - uim-platform namespace"
        subgraph "masterdata-governance Pod"
            BIN[uim-masterdata-governance-platform-service]
            ENV[Env: MASTERDATA_GOVERNANCE_HOST, MASTERDATA_GOVERNANCE_PORT]
        end
        CM[ConfigMap: masterdata-governance-config]
        SVC[Service: ClusterIP :8108]
        DEP[Deployment: 1 replica]
    end

    subgraph "Container Registry"
        IMG[uim-platform/masterdata-governance:latest]
    end

    subgraph "Build Stage - Alpine:3.20 + LDC"
        SRC[D source code]
        DUB[dub build - ldc2 release]
        BLD[Binary artifact]
    end

    SRC --> DUB --> BLD --> IMG
    IMG --> DEP
    CM --> DEP
    DEP --> BIN
    SVC --> BIN
```

## S1 — Standards and Compliance

| Standard | Application |
|----------|-------------|
| **REST / HTTP 1.1** | All API endpoints follow REST conventions |
| **JSON** | Request and response payloads |
| **SAP BP Data Model** | BusinessPartner entity aligns with SAP BP core attributes (category, roles, address, tax, bank) |
| **SAP MDG Change Request** | Workflow states aligned with SAP MDG CR lifecycle (draft, submitted, inReview, approved, rejected, revisionRequested, withdrawn) |
| **Apache 2.0 License** | Open source license |
| **D Language (dlang)** | Implementation language |
| **vibe.d 0.10.x** | HTTP server framework |
| **Hexagonal Architecture** | Ports and adapters separation |
| **Clean Architecture** | Dependency inversion, layer isolation |
| **Kubernetes** | Container orchestration |
| **OCI-compatible containers** | Docker and Podman compatible |

## S2 — Quality Attributes

| Attribute | Design Decision |
|-----------|----------------|
| **Modularity** | 4 architectural layers with strict dependency direction |
| **Testability** | Repository interfaces allow mock injection |
| **Scalability** | Stateless design — horizontal scaling via Kubernetes replicas |
| **Observability** | `/health` endpoint for liveness/readiness probes |
| **Security** | Tenant isolation via TenantId on all entities and queries |
| **Portability** | Container-based deployment via Docker/Podman/Kubernetes |
| **Maintainability** | DI container wires all dependencies, single responsibility per class |
