# Build Apps — NAFv4 Architecture Views

## C1 — Capability Taxonomy

```mermaid
graph TB
    BA[Build Apps Service]
    BA --> AM[Application Management]
    BA --> PGM[Page Management]
    BA --> UCM[UI Component Management]
    BA --> DEM[Data Entity Management]
    BA --> DCM[Data Connection Management]
    BA --> LFM[Logic Flow Management]
    BA --> ABM[App Build Management]
    BA --> PMM[Project Member Management]

    AM --> AM1[Create Application]
    AM --> AM2[Configure App Type]
    AM --> AM3[Version Management]
    AM --> AM4[Theme Configuration]

    PGM --> PGM1[Create Pages]
    PGM --> PGM2[Drag-and-Drop Layout]
    PGM --> PGM3[Navigation Config]
    PGM --> PGM4[Data Bindings]

    UCM --> UCM1[Component Library]
    UCM --> UCM2[Custom Components]
    UCM --> UCM3[Property Schemas]
    UCM --> UCM4[Event Definitions]

    DEM --> DEM1[Define Data Models]
    DEM --> DEM2[Field Definitions]
    DEM --> DEM3[Validation Rules]
    DEM --> DEM4[Index Configuration]

    DCM --> DCM1[SAP BTP Destinations]
    DCM --> DCM2[OData / REST APIs]
    DCM --> DCM3[SAP S/4HANA]
    DCM --> DCM4[Authentication Management]

    LFM --> LFM1[Visual Logic Builder]
    LFM --> LFM2[Event Triggers]
    LFM --> LFM3[Flow Steps]
    LFM --> LFM4[Error Handling]

    ABM --> ABM1[Web Builds]
    ABM --> ABM2[iOS Builds]
    ABM --> ABM3[Android Builds]
    ABM --> ABM4[Signing Config]

    PMM --> PMM1[Role Assignment]
    PMM --> PMM2[Permission Management]
    PMM --> PMM3[Invitation Flow]
```

## C2 — Service Taxonomy

```mermaid
graph TB
    subgraph "Build Apps Platform Service"
        API[REST API Layer]
        APP[Application Layer]
        DOM[Domain Layer]
        INF[Infrastructure Layer]
    end

    subgraph "Consumed Services"
        IAS[Identity Authentication]
        DEST[SAP BTP Destination Service]
        OBJ[Object Store Service]
        CIS[Cloud Integration]
    end

    API --> APP
    APP --> DOM
    DOM --> INF

    API -.-> IAS
    INF -.-> DEST
    INF -.-> OBJ
    INF -.-> CIS
```

## L1 — Logical Data Model

```mermaid
erDiagram
    APPLICATION ||--o{ PAGE : contains
    APPLICATION ||--o{ DATA_ENTITY : defines
    APPLICATION ||--o{ DATA_CONNECTION : connects
    APPLICATION ||--o{ LOGIC_FLOW : uses
    APPLICATION ||--o{ APP_BUILD : builds
    APPLICATION ||--o{ PROJECT_MEMBER : has

    PAGE ||--o{ LOGIC_FLOW : triggers

    APPLICATION {
        string id PK
        string tenantId
        string name
        string type
        string status
        string version
        string owner
    }

    PAGE {
        string id PK
        string applicationId FK
        string name
        string type
        string layoutConfig
        string componentTree
        int sortOrder
        bool isHomePage
    }

    DATA_ENTITY {
        string id PK
        string applicationId FK
        string name
        string fields
        string validationRules
    }

    DATA_CONNECTION {
        string id PK
        string applicationId FK
        string name
        string type
        string authMethod
        string endpoint
    }

    LOGIC_FLOW {
        string id PK
        string applicationId FK
        string pageId FK
        string name
        string trigger
        string steps
    }

    APP_BUILD {
        string id PK
        string applicationId FK
        string buildTarget
        string buildStatus
        string version
        string artifactUrl
    }

    PROJECT_MEMBER {
        string id PK
        string applicationId FK
        string userId
        string role
        string permissions
    }
```

## L2 — Service Architecture

```mermaid
graph TB
    subgraph "Presentation Layer"
        R[URLRouter]
        AC[ApplicationController]
        PC[PageController]
        UIC[UIComponentController]
        DEC[DataEntityController]
        DCC[DataConnectionController]
        LFC[LogicFlowController]
        ABC[AppBuildController]
        PMC[ProjectMemberController]
        HC[HealthController]
    end

    subgraph "Application Layer"
        MAU[ManageApplicationsUseCase]
        MPU[ManagePagesUseCase]
        MUIC[ManageUIComponentsUseCase]
        MDEU[ManageDataEntitiesUseCase]
        MDCU[ManageDataConnectionsUseCase]
        MLFU[ManageLogicFlowsUseCase]
        MABU[ManageAppBuildsUseCase]
        MPMU[ManageProjectMembersUseCase]
    end

    subgraph "Domain Layer"
        E[Entities]
        RI[Repository Interfaces]
        V[BuildAppsValidator]
    end

    subgraph "Infrastructure Layer"
        CFG[AppConfig]
        CNT[Container / DI]
        MR[Memory Repositories]
    end

    R --> AC & PC & UIC & DEC & DCC & LFC & ABC & PMC & HC
    AC --> MAU
    PC --> MPU
    UIC --> MUIC
    DEC --> MDEU
    DCC --> MDCU
    LFC --> MLFU
    ABC --> MABU
    PMC --> MPMU
    MAU & MPU & MUIC & MDEU & MDCU & MLFU & MABU & MPMU --> RI
    MR -.->|implements| RI
```

## L4 — Activity Flow (Create Application)

```mermaid
flowchart TD
    A[Client sends POST /api/v1/build-apps/applications] --> B[ApplicationController receives request]
    B --> C[Parse JSON body into ApplicationDTO]
    C --> D[ManageApplicationsUseCase.create]
    D --> E[BuildAppsValidator.validateApplication]
    E --> F{Valid?}
    F -->|No| G[Return CommandResult error]
    G --> H[Controller responds 400]
    F -->|Yes| I[Generate ApplicationId]
    I --> J[ApplicationRepository.save]
    J --> K[Return CommandResult success]
    K --> L[Controller responds 201 Created]
```

## P1 — Physical Deployment

```mermaid
graph TB
    subgraph "Kubernetes Cluster"
        subgraph "uim-platform namespace"
            CM[ConfigMap: build-apps-config]
            DEP[Deployment: build-apps]
            SVC[Service: build-apps ClusterIP:8112]

            DEP --> POD[Pod: build-apps]
            POD --> CONT[Container: uim-build-apps-platform-service]
            CM -.-> POD
            SVC --> POD
        end
    end

    CLIENT[External Client] --> SVC
```

## S1 — Security

```mermaid
graph LR
    subgraph "Security Boundary"
        API[REST API :8112]
        AUTH[Tenant ID Header Authentication]
        VAL[Input Validation - BuildAppsValidator]
        CTRL[Controller Error Handling]
    end

    CLIENT[Client] --> AUTH
    AUTH --> API
    API --> VAL
    VAL --> CTRL
```

## Sv1 — Service Contract

| Property | Value |
|----------|-------|
| Service Name | Build Apps Platform Service |
| Service ID | `uim-build-apps-platform-service` |
| Version | 1.0.0 |
| Protocol | HTTP/REST |
| Port | 8112 |
| Base Path | `/api/v1/build-apps` |
| Health Endpoint | `/health` |
| Authentication | Tenant ID header |
| Content Type | `application/json` |
| Namespace | `uim-platform` |
| Container Image | `uim-platform/build-apps:latest` |
