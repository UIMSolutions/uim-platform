# UIM Databricks — UML Diagrams

## Class Diagram — Domain Layer

```mermaid
classDiagram
  class TenantEntity~Id~ {
    +TenantId tenantId
    +Id id
  }

  class Workspace {
    +string name
    +string region
    +WorkspaceTier tier
    +WorkspaceStatus status
    +string url
    +string cloudProvider
  }

  class Cluster {
    +WorkspaceId workspaceId
    +string name
    +ClusterType clusterType
    +ClusterState state
    +int numWorkers
    +string sparkVersion
  }

  class Notebook {
    +WorkspaceId workspaceId
    +string path
    +string name
    +NotebookLanguage language
    +NotebookStatus status
  }

  class Job {
    +WorkspaceId workspaceId
    +string name
    +JobStatus status
    +string schedule
  }

  class JobRun {
    +JobId jobId
    +WorkspaceId workspaceId
    +RunState state
    +RunTrigger triggerType
  }

  class DeltaTable {
    +WorkspaceId workspaceId
    +string catalogName
    +string schemaName
    +string tableName
    +TableType tableType
  }

  class DataProduct {
    +WorkspaceId workspaceId
    +string name
    +DataProductStatus status
    +ShareMode shareMode
  }

  class MlExperiment {
    +WorkspaceId workspaceId
    +string name
    +string lifecycleStage
  }

  class MlModel {
    +WorkspaceId workspaceId
    +string name
    +ModelStage latestStage
  }

  class SqlWarehouse {
    +WorkspaceId workspaceId
    +string name
    +WarehouseType warehouseType
    +WarehouseSize size
    +WarehouseState state
  }

  TenantEntity <|-- Workspace
  TenantEntity <|-- Cluster
  TenantEntity <|-- Notebook
  TenantEntity <|-- Job
  TenantEntity <|-- JobRun
  TenantEntity <|-- DeltaTable
  TenantEntity <|-- DataProduct
  TenantEntity <|-- MlExperiment
  TenantEntity <|-- MlModel
  TenantEntity <|-- SqlWarehouse

  Workspace "1" --> "*" Cluster
  Workspace "1" --> "*" Notebook
  Workspace "1" --> "*" Job
  Job "1" --> "*" JobRun
```

## Component Diagram — Architecture Layers

```mermaid
graph TB
  subgraph Presentation
    HTTP[HTTP Controllers<br/>vibe.d REST]
    CLI[CLI Controllers<br/>command-line]
    WEB[Web Controllers<br/>Diet templates]
    GUI[GUI Controllers<br/>gtk-d]
  end
  subgraph Application
    UC[Use Cases<br/>ManageXxxUseCase]
    DTO[DTOs<br/>CreateXxxRequest / UseCaseResult]
  end
  subgraph Domain
    ENT[Entities<br/>Workspace, Cluster, ...]
    PORT[Repository Ports<br/>IXxxRepository]
    ENUM[Enumerations<br/>ClusterState, RunState, ...]
  end
  subgraph Infrastructure
    MEM[Memory Repositories]
    FILE[File Repositories<br/>stub]
    MONGO[MongoDB Repositories<br/>stub]
    CNF[Config / DI Container]
  end

  HTTP --> UC
  CLI --> UC
  WEB --> UC
  GUI --> UC
  UC --> PORT
  UC --> DTO
  PORT --> ENT
  MEM --> PORT
  FILE --> PORT
  MONGO --> PORT
  CNF --> MEM
```

## Sequence Diagram — Create Cluster

```mermaid
sequenceDiagram
  participant Client
  participant ClusterController
  participant ManageClustersUseCase
  participant MemoryClusterRepository

  Client->>ClusterController: POST /api/v1/databricks/clusters
  ClusterController->>ManageClustersUseCase: create(CreateClusterRequest)
  ManageClustersUseCase->>MemoryClusterRepository: save(cluster)
  MemoryClusterRepository-->>ManageClustersUseCase: cluster
  ManageClustersUseCase-->>ClusterController: UseCaseResult!Cluster
  ClusterController-->>Client: 201 Created + JSON
```

## Sequence Diagram — ML Model Stage Promotion

```mermaid
sequenceDiagram
  participant Client
  participant MlModelController
  participant ManageMlModelsUseCase
  participant MemoryMlModelRepository

  Client->>MlModelController: PUT /api/v1/databricks/models/{id}
  Note right of Client: body: {"latestStage": "production"}
  MlModelController->>ManageMlModelsUseCase: update(UpdateMlModelRequest)
  ManageMlModelsUseCase->>MemoryMlModelRepository: find(tenantId, id)
  MemoryMlModelRepository-->>ManageMlModelsUseCase: MlModel
  ManageMlModelsUseCase->>MemoryMlModelRepository: save(updated)
  MemoryMlModelRepository-->>ManageMlModelsUseCase: MlModel
  ManageMlModelsUseCase-->>MlModelController: UseCaseResult!MlModel
  MlModelController-->>Client: 200 OK + JSON
```
