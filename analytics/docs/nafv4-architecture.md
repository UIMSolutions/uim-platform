# NAF v4 Architecture Description — UIM Analytics Platform Service

> NATO Architecture Framework v4 (NAF v4) description for the UIM Platform
> Analytics Service — enterprise BI, planning, and predictive analytics.

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
Analytics Platform
├── C1.1  Business Intelligence
│   ├── C1.1.1  Dashboard Management
│   │   ├── Multi-page dashboards with widget placement
│   │   ├── Publishing lifecycle (Draft → Published → Archived)
│   │   └── Visibility scoping (Private / Team / Organization / Public)
│   ├── C1.1.2  Story-Based Analytics
│   │   ├── Narrative sections combining text and visualizations
│   │   └── Section management with heading and narrative content
│   ├── C1.1.3  Visualizations (Widgets)
│   │   ├── 20 chart types (Bar, Line, Pie, Scatter, KPI, GeoMap, Sankey, etc.)
│   │   ├── Dimension/Measure bindings with aggregation
│   │   └── Filter specifications (10 operators)
│   └── C1.1.4  Server-Side Analytics Engine
│       └── 13 aggregation types (Sum, Average, Median, Variance, StdDev, etc.)
│
├── C1.2  Data Management
│   ├── C1.2.1  Datasets (Data Models)
│   │   ├── Typed columns: Dimension / Measure / Attribute
│   │   ├── Column data types: String, Integer, Decimal, Date, DateTime, Boolean
│   │   └── Default aggregation assignment
│   └── C1.2.2  Data Source Connections
│       ├── 9 connector types (Database, CSV, Excel, OData, REST API, HANA, S3, Google Sheets, Live)
│       ├── Connection testing
│       └── Import scheduling (cron-based)
│
├── C1.3  Planning & Budgeting
│   ├── C1.3.1  Planning Model Management
│   │   ├── Version management (Actual / Plan / Forecast / What-If)
│   │   ├── Time granularity (Yearly → Hourly)
│   │   └── Approval workflow (Draft → InProgress → Locked → Approved → Published)
│   └── C1.3.2  Forecasting Engine
│       ├── Simple exponential smoothing
│       ├── Holt's method (level + trend)
│       └── Moving average
│
├── C1.4  Predictive Analytics (Smart Predict)
│   ├── C1.4.1  ML Model Types
│   │   ├── Classification
│   │   ├── Regression
│   │   ├── Time Series
│   │   ├── Clustering
│   │   └── Anomaly Detection
│   ├── C1.4.2  Model Training
│   │   └── Configurable target column, features, horizon, train/test split
│   └── C1.4.3  Model Evaluation
│       └── Accuracy, RMSE, confidence level, model summary
│
└── C1.5  Cross-Cutting Concerns
    ├── C1.5.1  Export (PDF, CSV, Excel)
    └── C1.5.2  Notifications (User / Group)
```

### C2 – Enterprise Vision

| Aspect | Description |
|---|---|
| **Mission** | Provide self-service business intelligence, collaborative planning, and predictive analytics as a composable microservice. |
| **Vision** | Enable data-driven decision-making through interactive dashboards, narrative stories, forecasting models, and machine learning predictions — modelled after SAP Analytics Cloud. |
| **Scope** | All structured and semi-structured data flowing through the UIM Platform that requires visualization, aggregation, planning, or prediction. |
| **Stakeholders** | Business Analysts, Data Scientists, Financial Planners, C-Level Executives, Application Developers. |

---

## 3. Service View (NSV)

### NSOV-1 – Service Taxonomy

```
Analytics Service Offerings
├── SVC-DASH   Dashboard Service
│   ├── SVC-DASH-CRUD    CRUD operations
│   ├── SVC-DASH-PAGE    Page management
│   └── SVC-DASH-PUB     Publish workflow
│
├── SVC-STORY  Story Service
│   ├── SVC-STORY-CRUD   CRUD operations
│   └── SVC-STORY-PUB    Publish workflow
│
├── SVC-DS     Dataset Service
│   └── SVC-DS-CRUD      CRUD operations
│
├── SVC-WDG    Widget Service
│   └── SVC-WDG-CRUD     CRUD operations
│
├── SVC-SRC    Data Source Service
│   ├── SVC-SRC-CRUD     CRUD operations
│   └── SVC-SRC-TEST     Connection testing
│
├── SVC-PLAN   Planning Service
│   ├── SVC-PLAN-CRUD    CRUD operations
│   ├── SVC-PLAN-LOCK    Model locking
│   └── SVC-PLAN-APR     Model approval
│
├── SVC-PRED   Prediction Service
│   ├── SVC-PRED-CRUD    CRUD operations
│   └── SVC-PRED-TRAIN   Model training
│
└── SVC-HLTH   Health Service
    └── SVC-HLTH-CHECK   Liveness probe
```

### NSOV-2 – Service Definitions

| Service ID | Name | Interface | Protocol | Path Prefix | Methods |
|---|---|---|---|---|---|
| SVC-DASH-CRUD | Dashboard Management | REST/JSON | HTTP/1.1 | `/api/v1/dashboards` | GET, POST, DELETE |
| SVC-DASH-PAGE | Dashboard Pages | REST/JSON | HTTP/1.1 | `/api/v1/dashboards/{id}/pages` | POST |
| SVC-DASH-PUB | Dashboard Publish | REST/JSON | HTTP/1.1 | `/api/v1/dashboards/{id}/publish` | POST |
| SVC-STORY-CRUD | Story Management | REST/JSON | HTTP/1.1 | `/api/v1/stories` | GET, POST, DELETE |
| SVC-STORY-PUB | Story Publish | REST/JSON | HTTP/1.1 | `/api/v1/stories/{id}/publish` | POST |
| SVC-DS-CRUD | Dataset Management | REST/JSON | HTTP/1.1 | `/api/v1/datasets` | GET, POST, DELETE |
| SVC-WDG-CRUD | Widget Management | REST/JSON | HTTP/1.1 | `/api/v1/widgets` | GET, POST, DELETE |
| SVC-SRC-CRUD | Data Source Management | REST/JSON | HTTP/1.1 | `/api/v1/datasources` | GET, POST, DELETE |
| SVC-SRC-TEST | Connection Testing | REST/JSON | HTTP/1.1 | `/api/v1/datasources/{id}/test` | POST |
| SVC-PLAN-CRUD | Planning Model Management | REST/JSON | HTTP/1.1 | `/api/v1/planning` | GET, POST, DELETE |
| SVC-PLAN-LOCK | Planning Lock | REST/JSON | HTTP/1.1 | `/api/v1/planning/{id}/lock` | POST |
| SVC-PLAN-APR | Planning Approval | REST/JSON | HTTP/1.1 | `/api/v1/planning/{id}/approve` | POST |
| SVC-PRED-CRUD | Prediction Management | REST/JSON | HTTP/1.1 | `/api/v1/predictions` | GET, POST, DELETE |
| SVC-PRED-TRAIN | Model Training | REST/JSON | HTTP/1.1 | `/api/v1/predictions/{id}/train` | POST |
| SVC-HLTH-CHECK | Health Check | REST/JSON | HTTP/1.1 | `/api/v1/health` | GET |

---

## 4. Operational View (NOV)

### NOV-2 – Operational Node Connectivity

```
                                ┌─────────────────────────┐
                                │    API Gateway / LB      │
                                └────────────┬────────────┘
                                             │ HTTP :8082
                                             ▼
                  ┌──────────────────────────────────────────────────┐
                  │           Analytics Platform Service              │
                  │                                                  │
                  │  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
                  │  │Dashboard │  │  Story   │  │ Dataset  │      │
                  │  │ Handler  │  │ Handler  │  │ Handler  │      │
                  │  └────┬─────┘  └────┬─────┘  └────┬─────┘      │
                  │  ┌────┴────┐  ┌─────┴────┐  ┌─────┴────┐      │
                  │  │Widget   │  │DataSource│  │Planning  │      │
                  │  │Handler  │  │ Handler  │  │ Handler  │      │
                  │  └────┬────┘  └────┬─────┘  └────┬─────┘      │
                  │  ┌────┴────┐       │             │              │
                  │  │Predict. │       │             │              │
                  │  │Handler  │       │             │              │
                  │  └────┬────┘       │             │              │
                  │       │            │             │              │
                  │  ┌────▼────────────▼─────────────▼──────┐      │
                  │  │         Use Case Layer                │      │
                  │  │  7 use case classes orchestrating     │      │
                  │  │  domain logic & repository access     │      │
                  │  └────────────────┬─────────────────────┘      │
                  │                   │                              │
                  │  ┌────────────────▼───────────────────────┐     │
                  │  │         Domain Services                │     │
                  │  │  AnalyticsEngine (13 aggregations)     │     │
                  │  │  ForecastingEngine (3 algorithms)      │     │
                  │  └────────────────┬───────────────────────┘     │
                  │                   │                              │
                  │  ┌────────────────▼───────────────────────┐     │
                  │  │     In-Memory Repository Adapters       │     │
                  │  │ (7 repositories, swappable via ports)   │     │
                  │  └─────────────────────────────────────────┘     │
                  │                                                  │
                  │  ┌─────────────────────────────────────────┐     │
                  │  │     External Adapters (Outgoing Ports)   │     │
                  │  │  StubDataConnector | CsvExport | Console │     │
                  │  └─────────────────────────────────────────┘     │
                  └──────────────────────────────────────────────────┘
                                             │
                             ┌───────────────┼───────────────┐
                             ▼               ▼               ▼
                     ┌──────────┐   ┌──────────────┐  ┌────────────┐
                     │ Audit Log│   │ Identity &   │  │  Portal    │
                     │ Service  │   │ Directory    │  │  Service   │
                     └──────────┘   └──────────────┘  └────────────┘
```

**Operational Information Exchanges:**

| Exchange | From | To | Content | Frequency |
|---|---|---|---|---|
| OIE-1 | Client | Analytics | Dashboard / Story / Widget definitions | On demand |
| OIE-2 | Client | Analytics | Dataset & data source specifications | On demand |
| OIE-3 | Client | Analytics | Planning model versions & approvals | On demand |
| OIE-4 | Client | Analytics | Prediction training requests | On demand |
| OIE-5 | Analytics | External DB | Data fetch via DataConnector port | Per import |
| OIE-6 | Analytics | Client | Export artifacts (CSV/PDF/Excel) | On demand |
| OIE-7 | Analytics | Notification | Planning / prediction status alerts | Per state change |
| OIE-8 | Analytics | Audit Log | Operation audit trail | Per operation |

---

## 5. Logical View (NLV)

### NLV-1 – Logical Data Model

```
┌──────────────────────────────────────────────────────────────────┐
│  BI Artifacts Domain                                              │
│                                                                   │
│  ┌──────────────────┐       ┌──────────────────────┐            │
│  │  Dashboard        │──1:N──│  Page                 │            │
│  ├──────────────────┤       ├──────────────────────┤            │
│  │ id: EntityId      │       │ id: EntityId          │            │
│  │ name              │       │ title                 │            │
│  │ description       │       │ widgetIds: EntityId[] │            │
│  │ ownerId: EntityId │       └──────────────────────┘            │
│  │ visibility        │                                            │
│  │ status            │       ┌──────────────────────┐            │
│  │ tags: string[]    │       │  Section              │            │
│  │ audit: AuditInfo  │       ├──────────────────────┤            │
│  └──────────────────┘       │ id: EntityId          │            │
│                              │ heading, narrative    │            │
│  ┌──────────────────┐──1:N──│ widgetIds: EntityId[] │            │
│  │  Story            │       └──────────────────────┘            │
│  ├──────────────────┤                                            │
│  │ id: EntityId      │                                            │
│  │ title, description│                                            │
│  │ ownerId: EntityId │                                            │
│  │ visibility, status│                                            │
│  │ tags, audit       │                                            │
│  └──────────────────┘                                            │
│                                                                   │
│  ┌──────────────────────────┐                                    │
│  │  Widget                   │                                    │
│  ├──────────────────────────┤                                    │
│  │ id: EntityId              │                                    │
│  │ title                     │                                    │
│  │ chartType: ChartType      │  (20 chart types)                 │
│  │ datasetId: EntityId       │──→ Dataset                        │
│  │ dimensions: Binding[]     │                                    │
│  │ measures: Binding[]       │                                    │
│  │ filters: FilterSpec[]     │  (10 filter operators)            │
│  │ style: WidgetStyle        │                                    │
│  │ audit: AuditInfo          │                                    │
│  └──────────────────────────┘                                    │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Data Domain                                                      │
│                                                                   │
│  ┌──────────────────┐       ┌──────────────────────┐            │
│  │  DataSource       │──1:N──│  Dataset              │            │
│  ├──────────────────┤       ├──────────────────────┤            │
│  │ id: EntityId      │       │ id: EntityId          │            │
│  │ name              │       │ name, description     │            │
│  │ sourceType: enum  │       │ dataSourceId          │            │
│  │   (9 types)       │       │ columns: Column[]     │            │
│  │ connection: Info  │       │ status, audit         │            │
│  │ schedule: Import  │       └──────────┬───────────┘            │
│  │ connStatus: enum  │                  │ 1:N                     │
│  │ audit: AuditInfo  │       ┌──────────▼───────────┐            │
│  └──────────────────┘       │  Column               │            │
│                              ├──────────────────────┤            │
│                              │ name                  │            │
│                              │ role: ColumnRole      │            │
│                              │   (Dimension/Measure) │            │
│                              │ dataType: ColumnType  │            │
│                              │ defaultAggregation    │            │
│                              └──────────────────────┘            │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Planning Domain                                                  │
│                                                                   │
│  ┌──────────────────┐       ┌──────────────────────┐            │
│  │  PlanningModel    │──1:N──│  PlanningVersion      │            │
│  ├──────────────────┤       ├──────────────────────┤            │
│  │ id: EntityId      │       │ id: EntityId          │            │
│  │ name, description │       │ name                  │            │
│  │ datasetId → Dataset       │ versionType: enum     │            │
│  │ granularity: enum │       │   (Actual/Plan/       │            │
│  │   (Yearly→Hourly)│       │    Forecast/WhatIf)   │            │
│  │ planStatus: enum  │       │ isReadOnly: bool      │            │
│  │   (Draft→Published)       └──────────────────────┘            │
│  │ audit: AuditInfo  │                                            │
│  └──────────────────┘                                            │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│  Prediction Domain                                                │
│                                                                   │
│  ┌──────────────────────────────────────────┐                    │
│  │  Prediction                               │                    │
│  ├──────────────────────────────────────────┤                    │
│  │ id: EntityId                              │                    │
│  │ name, description                         │                    │
│  │ datasetId → Dataset                       │                    │
│  │ predictionType: PredictionType            │                    │
│  │   (Classification / Regression /           │                    │
│  │    TimeSeries / Clustering /                │                    │
│  │    AnomalyDetection)                       │                    │
│  │ config: PredictionConfig                   │                    │
│  │   targetColumn, featureColumns[],          │                    │
│  │   horizonPeriods (12), trainTestSplit (0.8) │                    │
│  │ lastResult: PredictionResult               │                    │
│  │   accuracy, rmse, confidenceLevel,         │                    │
│  │   modelSummary                             │                    │
│  │ predStatus: PredictionStatus               │                    │
│  │   (Created → Training → Ready / Failed)    │                    │
│  │ audit: AuditInfo                           │                    │
│  └──────────────────────────────────────────┘                    │
└──────────────────────────────────────────────────────────────────┘
```

**Key Enumerations:**

| Enum | Values |
|---|---|
| Visibility | Private, Team, Organization, Public |
| ArtifactStatus | Draft, Published, Archived |
| ChartType | Bar, Column, Line, Area, Pie, Donut, Scatter, Bubble, Heatmap, Treemap, Waterfall, Gauge, KPI, Table, CrossTab, GeoMap, Sankey, BoxPlot, Histogram, Combo |
| AggregationType | Sum, Average, Count, CountDistinct, Min, Max, Median, Variance, StdDev, First, Last, RunningTotal, WeightedAverage |
| TimeGranularity | Yearly, Quarterly, Monthly, Weekly, Daily, Hourly |
| ColumnRole | Dimension, Measure, Attribute |
| ColumnDataType | String, Integer, Decimal, Date, DateTime, Boolean |
| DataSourceType | Database, CSV, Excel, OData, RestAPI, HANA, S3, GoogleSheets, LiveConnection |
| DataSourceStatus | Connected, Disconnected, Error, Importing |
| PlanningStatus | Draft, InProgress, Locked, Approved, Published |
| VersionType | Actual, Plan, Forecast, WhatIf |
| PredictionType | Classification, Regression, TimeSeries, Clustering, AnomalyDetection |
| PredictionStatus | Created, Training, Ready, Failed, Archived |
| FilterOperator | Equals, NotEquals, GreaterThan, LessThan, Between, In, NotIn, Contains, IsNull, IsNotNull |

---

## 6. Physical View (NPV)

### NPV-1 – Physical Deployment

```
┌─────────────────────────────────────────────────────────────┐
│  Deployment Node: Application Server                         │
│  OS: Linux                                                   │
│  Runtime: Native D binary (compiled with dub + DMD/LDC)     │
│                                                              │
│  ┌────────────────────────────────────────────────────┐     │
│  │  Artifact: analytics (executable)                   │     │
│  │  Source:   analytics/source/**/*.d                  │     │
│  │  Binary:   analytics/build/analytics                │     │
│  │  Port:     8082 (configurable ANALYTICS_PORT)       │     │
│  │  Protocol: HTTP/1.1 (vibe.d event loop)             │     │
│  └────────────────────────────────────────────────────┘     │
│                                                              │
│  Environment Variables:                                      │
│  ┌────────────────┬──────────┬──────────────────────┐       │
│  │ Name           │ Default  │ Description           │       │
│  ├────────────────┼──────────┼──────────────────────┤       │
│  │ ANALYTICS_HOST │ 0.0.0.0  │ HTTP bind address     │       │
│  │ ANALYTICS_PORT │ 8082     │ HTTP listen port      │       │
│  └────────────────┴──────────┴──────────────────────┘       │
│                                                              │
│  Dependencies:                                               │
│  ┌────────────────────────────┬──────────┐                  │
│  │ Package                    │ Version  │                  │
│  ├────────────────────────────┼──────────┤                  │
│  │ vibe-d                     │ ~>0.10.1 │                  │
│  │ vibe-d:tls                 │ ~>0.10.1 │                  │
│  └────────────────────────────┴──────────┘                  │
│                                                              │
│  Persistence: In-memory (ephemeral)                          │
│  Scaling: Stateless – horizontally scalable with external    │
│           persistence adapter                                │
└─────────────────────────────────────────────────────────────┘
```

**Deployment Constraints:**

| Constraint | Description |
|---|---|
| DC-1 | Single-process, multi-threaded via vibe.d fibers |
| DC-2 | In-memory persistence is non-durable; data is lost on restart |
| DC-3 | Swapping to durable persistence requires implementing 7 repository interfaces |
| DC-4 | External service adapters (DataConnector, ExportPort, NotificationPort) are development stubs — replace for production |
| DC-5 | CORS middleware enabled — configure allowed origins for production |

---

## 7. Information View (NIV)

### NIV-1 – Information Structure

**Information Flows:**

| Flow ID | Source | Target | Data | Format | Trigger |
|---|---|---|---|---|---|
| IF-1 | Client | DashboardHandler | Dashboard definition, page additions | JSON | User action |
| IF-2 | Client | StoryHandler | Story definition, section additions | JSON | User action |
| IF-3 | Client | DatasetHandler | Dataset schema (columns, types) | JSON | User action |
| IF-4 | Client | WidgetHandler | Widget config (chart type, bindings, filters) | JSON | User action |
| IF-5 | Client | DataSourceHandler | Connection parameters | JSON | User action |
| IF-6 | DataSourceUseCases | DataConnector | Connection string for testing | Internal | API call |
| IF-7 | Client | PlanningHandler | Planning model definition, lock/approve | JSON | User action |
| IF-8 | Client | PredictionHandler | Prediction config, training trigger | JSON | User action |
| IF-9 | PredictionUseCases | Client | Training results (accuracy, RMSE) | JSON | Response |
| IF-10 | ExportPort | Client | Export file bytes (PDF/CSV/Excel) | Binary/text | On demand |
| IF-11 | NotificationPort | User | Status change alerts | Console/email | Per state change |

**Data Sensitivity:**

| Data Element | Classification | Handling |
|---|---|---|
| Data source credentials | Secret | Connection info stored in ConnectionInfo struct; username exposed, password not stored |
| Dataset records | Business-confidential | Passed through DataConnector; not persisted in analytics layer |
| Dashboard / Story content | Business-internal | Owner-scoped with visibility controls |
| Planning versions | Financial-confidential | Approval workflow with lock mechanism |
| Prediction models | Proprietary / business-sensitive | Training results include accuracy metrics |

---

## 8. Traceability Matrix

| Capability | Service(s) | Entity/ies | Handler | Use Case |
|---|---|---|---|---|
| C1.1.1 Dashboards | SVC-DASH-* | Dashboard, Page | DashboardHandler | DashboardUseCases |
| C1.1.2 Stories | SVC-STORY-* | Story, Section | StoryHandler | StoryUseCases |
| C1.1.3 Widgets | SVC-WDG-* | Widget | WidgetHandler | WidgetUseCases |
| C1.1.4 Analytics Engine | (internal) | — | — | AnalyticsEngine |
| C1.2.1 Datasets | SVC-DS-* | Dataset, Column | DatasetHandler | DatasetUseCases |
| C1.2.2 Data Sources | SVC-SRC-* | DataSource | DataSourceHandler | DataSourceUseCases |
| C1.3.1 Planning | SVC-PLAN-* | PlanningModel, PlanningVersion | PlanningHandler | PlanningUseCases |
| C1.3.2 Forecasting | (internal) | — | — | ForecastingEngine |
| C1.4 Predictions | SVC-PRED-* | Prediction | PredictionHandler | PredictionUseCases |
| C1.5.1 Export | (outgoing port) | — | — | ExportPort / CsvExportAdapter |
| C1.5.2 Notifications | (outgoing port) | — | — | NotificationPort / ConsoleNotificationAdapter |

---

*Document generated for the UIM Platform Analytics Service.*
*Authors: UIM Platform Team*
*© 2018–2026 UIM Platform Team — Proprietary*
