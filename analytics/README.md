# UIM Analytics Platform Service

A microservice for enterprise business intelligence, planning, and predictive
analytics, inspired by **SAP Analytics Cloud (SAC)**. Built with **D** and
**vibe.d**, following **Clean Architecture** and **Hexagonal Architecture**
(Ports & Adapters) principles.

Part of the [UIM Platform](https://www.sueel.de/uim/sap) suite.

## Features

| Capability                            | Description                                                                                                                                                                    |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Dashboards**                  | Multi-page analytical dashboards with widget placement, publishing lifecycle (Draft → Published → Archived), visibility scoping (Private / Team / Organization / Public)     |
| **Stories**                     | Narrative-driven analytics with sections combining text and visualizations                                                                                                     |
| **Datasets (Models)**           | Structured data models with typed columns (Dimension / Measure / Attribute), aggregation defaults, and data source binding                                                     |
| **Widgets (Visualizations)**    | 20 chart types (Bar, Line, Pie, Scatter, Heatmap, KPI, GeoMap, Sankey, etc.) with dimension/measure bindings, filters, and configurable styles                                 |
| **Data Sources (Connections)**  | 9 connector types (Database, CSV, Excel, OData, REST API, HANA, S3, Google Sheets, Live Connection) with connection testing and import scheduling                              |
| **Planning Models**             | Budget and forecast planning with versioning (Actual / Plan / Forecast / What-If), time granularity control, and approval workflows (Draft → Locked → Approved → Published) |
| **Predictions (Smart Predict)** | ML model types (Classification, Regression, Time Series, Clustering, Anomaly Detection) with training, accuracy metrics, and confidence levels                                 |
| **Analytics Engine**            | Server-side aggregations — Sum, Average, Count, CountDistinct, Min, Max, Median, Variance, StdDev, Running Total, Weighted Average                                            |
| **Forecasting Engine**          | Simple exponential smoothing, Holt's method (level + trend), and moving average                                                                                                |
| **Export**                      | PDF, CSV, and Excel export (CSV implemented, PDF/Excel stubs)                                                                                                                  |
| **Notifications**               | User and group notifications (console adapter for development)                                                                                                                 |

## Architecture

```
nalytics/
├── source/
│   ├── app.d                              # Entry point & composition root
│   └── analytics/
│       ├── domain/                        # Pure business logic (no dependencies)
│       │   ├── entities/                  #   Core domain classes
│       │   │   ├── dashboard.d            #     Multi-page dashboards
│       │   │   ├── story.d               #     Narrative analytics
│       │   │   ├── dataset.d             #     Data models (dimensions/measures)
│       │   │   ├── widget.d              #     Visualizations with chart types
│       │   │   ├── datasource.d          #     Connection definitions
│       │   │   ├── planningmodel.d       #     Planning with versions
│       │   │   └── prediction.d          #     ML model definitions
│       │   ├── repositories/              #   Repository interfaces (ports)
│       │   │   ├── dashboard.d
│       │   │   ├── story.d
│       │   │   ├── dataset.d
│       │   │   ├── widget.d
│       │   │   ├── datasource.d
│       │   │   ├── planning.d
│       │   │   └── prediction.d
│       │   ├── services/engines/          #   Stateless domain services
│       │   │   ├── analytics.d           #     Aggregation engine
│       │   │   └── forecasting.d         #     Time-series forecasting
│       │   └── values/                    #   Value objects & enums
│       │       ├── common.d              #     EntityId, AuditInfo, Visibility, ArtifactStatus
│       │       ├── aggregation.d         #     AggregationType (13 types)
│       │       ├── chart_type.d          #     ChartType (20 types)
│       │       └── time_granularity.d    #     Yearly → Hourly
│       ├── app/                           #   Application layer (use cases)
│       │   ├── dto/                       #     Request/Response DTOs
│       │   │   ├── dashboard.d
│       │   │   ├── story.d
│       │   │   ├── dataset.d
│       │   │   ├── widget.d
│       │   │   ├── datasource.d
│       │   │   ├── planning.d
│       │   │   └── prediction.d
│       │   ├── ports/                     #     Outgoing port interfaces
│       │   │   ├── data_connector.d      #       External data fetching
│       │   │   ├── export_port.d         #       PDF/CSV/Excel export
│       │   │   └── notification_port.d   #       User notifications
│       │   └── usecases/                  #     Application services
│       │       ├── dashboards.d
│       │       ├── stories.d
│       │       ├── datasets.d
│       │       ├── widgets.d
│       │       ├── datasources.d
│       │       ├── planning.d
│       │       └── predictions.d
│       └── infrastructure/                #   Technical adapters
│           ├── config.d                   #     Environment-based configuration
│           ├── adapters/                  #     Outgoing adapter implementations
│           │   ├── stub_data_connector.d #       Hardcoded test data connector
│           │   ├── csv_export.d          #       CSV/PDF/Excel export adapter
│           │   └── console_notification.d #      Console logging notifications
│           ├── persistence/memory/        #     In-memory repository implementations
│           │   └── repositories/
│           │       ├── dashboard.d
│           │       ├── story.d
│           │       ├── dataset.d
│           │       ├── widget.d
│           │       ├── datasource.d
│           │       ├── planning.d
│           │       └── prediction.d
│           └── web/                       #     HTTP driving adapters
│               ├── routes.d              #       Route registration
│               ├── middleware.d           #       CORS & request logging
│               └── handlers/
│                   ├── health.d
│                   ├── dashboard.d
│                   ├── story.d
│                   ├── dataset.d
│                   ├── widget.d
│                   ├── datasource.d
│                   ├── planning.d
│                   └── prediction.d
└── dub.sdl
```

## REST API

All endpoints are prefixed with `/api/v1/`. CORS and request logging middleware applied globally.

### Health

```
GET  /api/v1/health                   → {"status":"healthy","service":"analytics","version":"1.0.0"}
```

### Dashboards

```
GET    /api/v1/dashboards              List all dashboards
POST   /api/v1/dashboards              Create a dashboard
GET    /api/v1/dashboards/{id}         Get dashboard by ID
POST   /api/v1/dashboards/{id}/pages   Add a page to a dashboard
POST   /api/v1/dashboards/{id}/publish Publish a dashboard
DELETE /api/v1/dashboards/{id}         Delete a dashboard
```

### Stories

```
GET    /api/v1/stories                 List all stories
POST   /api/v1/stories                 Create a story
GET    /api/v1/stories/{id}            Get story by ID
POST   /api/v1/stories/{id}/publish    Publish a story
DELETE /api/v1/stories/{id}            Delete a story
```

### Datasets (Models)

```
GET    /api/v1/datasets                List all datasets
POST   /api/v1/datasets                Create a dataset
GET    /api/v1/datasets/{id}           Get dataset by ID
DELETE /api/v1/datasets/{id}           Delete a dataset
```

### Widgets (Visualizations)

```
GET    /api/v1/widgets                 List all widgets
POST   /api/v1/widgets                 Create a widget
GET    /api/v1/widgets/{id}            Get widget by ID
DELETE /api/v1/widgets/{id}            Delete a widget
```

### Data Sources (Connections)

```
GET    /api/v1/datasources             List all data sources
POST   /api/v1/datasources             Create a data source
GET    /api/v1/datasources/{id}        Get data source by ID
POST   /api/v1/datasources/{id}/test   Test connection
DELETE /api/v1/datasources/{id}        Delete a data source
```

### Planning Models

```
GET    /api/v1/planning                List all planning models
POST   /api/v1/planning                Create a planning model
GET    /api/v1/planning/{id}           Get planning model by ID
POST   /api/v1/planning/{id}/lock      Lock model for editing
POST   /api/v1/planning/{id}/approve   Approve a locked model
DELETE /api/v1/planning/{id}           Delete a planning model
```

### Predictions (Smart Predict)

```
GET    /api/v1/predictions             List all predictions
POST   /api/v1/predictions             Create a prediction
GET    /api/v1/predictions/{id}        Get prediction by ID
POST   /api/v1/predictions/{id}/train  Train the ML model
DELETE /api/v1/predictions/{id}        Delete a prediction
```

## Build and Run

```bash
# Build
cd analytics
dub build

# Run (default: 0.0.0.0:8082)
./build/analytics

# Override host/port via environment
ANALYTICS_HOST=127.0.0.1 ANALYTICS_PORT=9090 ./build/analytics
```

## Configuration

| Variable           | Default     | Description       |
| ------------------ | ----------- | ----------------- |
| `ANALYTICS_HOST` | `0.0.0.0` | HTTP bind address |
| `ANALYTICS_PORT` | `8082`    | HTTP listen port  |

## Domain Model Overview

### Value Objects & Enums

| Type                       | Values                                                                                                                                                    |
| -------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **EntityId**         | Strongly-typed UUID wrapper with `generate()`, equality, hashing                                                                                        |
| **AuditInfo**        | `createdAt`, `createdBy`, `updatedAt`, `updatedBy` with `create()` / `touch()`                                                                |
| **Visibility**       | Private, Team, Organization, Public                                                                                                                       |
| **ArtifactStatus**   | Draft, Published, Archived                                                                                                                                |
| **ChartType**        | Bar, Column, Line, Area, Pie, Donut, Scatter, Bubble, Heatmap, Treemap, Waterfall, Gauge, KPI, Table, CrossTab, GeoMap, Sankey, BoxPlot, Histogram, Combo |
| **AggregationType**  | Sum, Average, Count, CountDistinct, Min, Max, Median, Variance, StdDev, First, Last, RunningTotal, WeightedAverage                                        |
| **TimeGranularity**  | Yearly, Quarterly, Monthly, Weekly, Daily, Hourly                                                                                                         |
| **ColumnRole**       | Dimension, Measure, Attribute                                                                                                                             |
| **ColumnDataType**   | String, Integer, Decimal, Date, DateTime, Boolean                                                                                                         |
| **DataSourceType**   | Database, CSV, Excel, OData, RestAPI, HANA, S3, GoogleSheets, LiveConnection                                                                              |
| **DataSourceStatus** | Connected, Disconnected, Error, Importing                                                                                                                 |
| **PlanningStatus**   | Draft, InProgress, Locked, Approved, Published                                                                                                            |
| **VersionType**      | Actual, Plan, Forecast, WhatIf                                                                                                                            |
| **PredictionType**   | Classification, Regression, TimeSeries, Clustering, AnomalyDetection                                                                                      |
| **PredictionStatus** | Created, Training, Ready, Failed, Archived                                                                                                                |
| **FilterOperator**   | Equals, NotEquals, GreaterThan, LessThan, Between, In, NotIn, Contains, IsNull, IsNotNull                                                                 |

### Analytics Engine

Static aggregation functions operating on `double[]` arrays:

- `aggregate(values, type)` — dispatches to the appropriate aggregation
- `sum`, `minVal`, `maxVal`, `median`, `variance`, `unique`

### Forecasting Engine

Static time-series forecasting methods:

- `forecast(data, periods, alpha)` — simple exponential smoothing
- `forecastWithTrend(data, periods, alpha, beta)` — Holt's method (level + trend)
- `movingAverage(data, window)` — sliding window average

## HTTP Status Codes

| Code    | Usage                         |
| ------- | ----------------------------- |
| `200` | Successful GET or action POST |
| `201` | Successful resource creation  |
| `204` | Successful DELETE             |
| `400` | Invalid request body          |
| `404` | Resource not found            |

## Technology

- **Language:** D (dub package manager)
- **HTTP Framework:** vibe.d 0.10.x
- **Persistence:** In-memory (swappable via repository interfaces)
- **Architecture:** Clean + Hexagonal (Ports & Adapters) + DDD

## Testing

```bash
dub test
```

## License

See the repository root [LICENSE](../LICENSE) file.
