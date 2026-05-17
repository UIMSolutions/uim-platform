# UML — Analytics Service

## Class Diagram — Domain Entities

```mermaid
classDiagram
    class Dashboard {
        +DashboardId id
        +TenantId tenantId
        +string name
        +string description
        +string status
        +string visibility
        +string[] pageIds
        +Json toJson()
    }
    class Story {
        +StoryId id
        +TenantId tenantId
        +string name
        +string description
        +string status
        +string[] sectionIds
        +Json toJson()
    }
    class Dataset {
        +DatasetId id
        +TenantId tenantId
        +string name
        +string description
        +string[] columnNames
        +Json toJson()
    }
    class Datasource {
        +DatasourceId id
        +TenantId tenantId
        +string name
        +string connectorType
        +string connectionString
        +string status
        +Json toJson()
    }
    class Widget {
        +WidgetId id
        +TenantId tenantId
        +DashboardId dashboardId
        +string chartType
        +string title
        +DatasetId datasetId
        +Json toJson()
    }
    class PlanningModel {
        +PlanningModelId id
        +TenantId tenantId
        +string name
        +string version
        +string status
        +string timeGranularity
        +Json toJson()
    }
    class Prediction {
        +PredictionId id
        +TenantId tenantId
        +DatasetId datasetId
        +string modelType
        +string targetColumn
        +string status
        +double accuracy
        +Json toJson()
    }

    Dashboard "1" --> "0..*" Widget : contains
    Dataset "1" --> "0..*" Widget : feeds
    Dataset "1" --> "0..*" Prediction : trains
    Datasource "1" --> "0..*" Dataset : provides
```

---

## Component Diagram

```mermaid
flowchart TB
    subgraph Presentation["Presentation Layer (HTTP)"]
        C1[DashboardController]
        C2[StoryController]
        C3[DatasetController]
        C4[DatasourceController]
        C5[WidgetController]
        C6[PlanningModelController]
        C7[PredictionController]
        HC[HealthController]
    end
    subgraph Application["Application Layer"]
        UC1[ManageDashboardsUseCase]
        UC2[ManageStoriesUseCase]
        UC3[ManageDatasetsUseCase]
        UC4[ManageDatasourcesUseCase]
        UC5[ManageWidgetsUseCase]
        UC6[ManagePlanningModelsUseCase]
        UC7[ManagePredictionsUseCase]
    end
    subgraph Infrastructure["Infrastructure Layer"]
        MEM[Memory Repositories ×7]
        CFG[SrvConfig — port 10003]
        CTR[Container / buildContainer]
    end

    C1 --> UC1
    C3 --> UC3
    C7 --> UC7
    UC1 --> MEM
    CTR --> UC1
    CTR --> MEM
```

---

## Sequence Diagram — Create Dashboard with Widgets

```mermaid
sequenceDiagram
    participant Client
    participant DC as DashboardController
    participant DUC as ManageDashboardsUseCase
    participant WC as WidgetController
    participant WUC as ManageWidgetsUseCase

    Client->>DC: POST /dashboards { name, visibility=public }
    DC->>DUC: createDashboard(dto)
    DUC-->>DC: CommandResult(true, dashboardId)
    DC-->>Client: 201 { id }

    Client->>WC: POST /widgets { dashboardId, chartType=bar, datasetId }
    WC->>WUC: createWidget(dto)
    WUC-->>WC: CommandResult(true, widgetId)
    WC-->>Client: 201 { id }

    Client->>DC: POST /dashboards/{id}/publish
    DC->>DUC: publishDashboard(id)
    DUC-->>DC: CommandResult(true, id)
    DC-->>Client: 200 { id }
```

---

## Sequence Diagram — Train Prediction Model

```mermaid
sequenceDiagram
    participant Client
    participant PC as PredictionController
    participant PUC as ManagePredictionsUseCase
    participant PR as PredictionRepository

    Client->>PC: POST /predictions { datasetId, modelType=regression, targetColumn }
    PC->>PUC: createPrediction(dto)
    PUC->>PR: save(prediction — status=created)
    PUC-->>PC: CommandResult(true, id)
    PC-->>Client: 201 { id }

    Client->>PC: POST /predictions/{id}/train
    PC->>PUC: trainPrediction(id)
    PUC->>PR: update(status=training)
    PUC-->>PC: CommandResult(true, id)
    PC-->>Client: 200 { id }
```
