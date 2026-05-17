# UML — Usage Data Management Service

## Package Structure

```
uim.platform.usage_data
├── domain
│   ├── enumerations       (ReportStatus, Environment, MetricUnit, CommercialModel, AccountType)
│   ├── values             (UsageRecordId, MonthlyUsageReportId, DailyUsageReportId, MonthlyCostReportId, ServiceMetricId)
│   ├── entities           (UsageRecord, MonthlyUsageReport, DailyUsageReport, MonthlyCostReport, ServiceMetric)
│   └── repositories       (5 repository interfaces — domain ports)
├── app
│   ├── dto                (Request/Response DTOs for each entity)
│   └── usecases           (UsageRecordUseCases, MonthlyUsageReportUseCases,
│                           DailyUsageReportUseCases, MonthlyCostReportUseCases, ServiceMetricUseCases)
├── infrastructure
│   ├── config             (ServiceConfig)
│   ├── adapters           (stub — no external adapters in MVP)
│   ├── persistence
│   │   └── memory
│   │       └── repositories  (5 in-memory adapter classes)
│   └── web
│       ├── middleware     (corsMiddleware, requestLogger)
│       ├── routes         (registerRoutes)
│       └── handlers       (6 handler classes)
└── helpers
```

## Domain Entity Relationships

```
GlobalAccount (string)
 └── MonthlyUsageReport  1──* MetricUsageItem
 └── DailyUsageReport    1──* MetricUsageItem
 └── MonthlyCostReport   1──* CostItem
 └── UsageRecord (raw)

Subaccount (string)
 └── DailyUsageReport
 └── MonthlyCostReport
 └── UsageRecord

ServiceMetric  ←──(referenced by)──  MetricUsageItem, CostItem, UsageRecord
```

## Hexagonal Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│  Driving side (HTTP)                                                 │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  vibe.d URLRouter → registerRoutes → Handlers (6)             │  │
│  └───────────────────────────┬───────────────────────────────────┘  │
│                              ▼                                       │
│  ┌───────────────────────────────────────────────────────────────┐  │
│  │  Application Layer: Use Cases (5)                              │  │
│  └─────────┬──────────────────────────────────┬──────────────────┘  │
│            ▼  domain port (interface)          ▼                     │
│  ┌─────────────────────────┐       ┌──────────────────────────────┐ │
│  │  Domain (entities,      │       │  Infrastructure Adapters     │ │
│  │  values, enumerations)  │       │  MemoryXxxRepository (5)     │ │
│  └─────────────────────────┘       └──────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────┘
```

## Sequence — Submit Usage Record

```
Client
  │  POST /api/v1/usage-data/usage-records
  ▼
UsageRecordHandler.submit
  │  CreateUsageRecordRequest
  ▼
UsageRecordUseCases.submitRecord
  │  UsageRecord.create(...)
  ▼
MemoryUsageRecordRepository.save
  │  → UsageRecordResponse
  ◄── 201 Created
```

## Sequence — Generate Monthly Usage Report

```
Client
  │  POST /api/v1/usage-data/reports/monthly
  ▼
MonthlyUsageReportHandler.create
  │  CreateMonthlyUsageReportRequest
  ▼
MonthlyUsageReportUseCases.createReport
  │  MonthlyUsageReport.create(globalAccountId, year, month)
  ▼
MemoryMonthlyUsageReportRepository.save
  │  → MonthlyUsageReportResponse
  ◄── 201 Created
```

## Class Diagram — Domain Entities (simplified)

```
UsageRecord
  id: UsageRecordId
  globalAccountId: string
  subaccountId: string
  serviceId: string
  planId: string
  metricName: string
  metricValue: double
  environment: Environment
  chargebackPeriod: string  (YYYY-MM)

MonthlyUsageReport
  id: MonthlyUsageReportId
  globalAccountId: string
  reportingYear: int
  reportingMonth: int
  status: ReportStatus
  usageItems: MetricUsageItem[]

DailyUsageReport
  id: DailyUsageReportId
  globalAccountId: string
  subaccountId: string
  reportDate: string  (YYYY-MM-DD)
  status: ReportStatus
  usageItems: MetricUsageItem[]

MonthlyCostReport
  id: MonthlyCostReportId
  globalAccountId: string
  subaccountId: string
  reportingYear: int
  reportingMonth: int
  currency: string
  totalCost: double
  commercialModel: CommercialModel
  status: ReportStatus
  costItems: CostItem[]

ServiceMetric
  id: ServiceMetricId
  serviceId: string
  planId: string
  metricName: string
  unit: MetricUnit
  isBillable: bool
  commercialModel: CommercialModel
```
