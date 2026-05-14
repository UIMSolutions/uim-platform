# UML — Application Autoscaler Service

## Component Diagram (Hexagonal Architecture)

```
┌──────────────────────────────────────────────────────────────────────┐
│                   APPLICATION AUTOSCALER SERVICE                     │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │  PRESENTATION LAYER (Driving Adapters)                       │   │
│  │                                                              │   │
│  │  ScalingPolicyController  AppBindingController               │   │
│  │  CustomMetricController   ScalingEngineController            │   │
│  │  ScalingHistoryController HealthController                   │   │
│  └────────────────────────────┬─────────────────────────────────┘   │
│                               │ calls                               │
│  ┌────────────────────────────▼─────────────────────────────────┐   │
│  │  APPLICATION LAYER (Use Cases)                               │   │
│  │                                                              │   │
│  │  ManageScalingPoliciesUseCase                                │   │
│  │  ManageAppBindingsUseCase                                    │   │
│  │  ManageCustomMetricsUseCase                                  │   │
│  │  ScalingEngineUseCase                                        │   │
│  │  ManageScalingHistoryUseCase                                 │   │
│  └────────────────────────────┬─────────────────────────────────┘   │
│                               │ uses                                │
│  ┌────────────────────────────▼─────────────────────────────────┐   │
│  │  DOMAIN LAYER (Core)                                         │   │
│  │                                                              │   │
│  │  Entities: ScalingPolicyEntity, AppBindingEntity,            │   │
│  │            ScalingRuleEntity, RecurringScheduleEntity,       │   │
│  │            SpecificDateScheduleEntity, CustomMetricEntity,   │   │
│  │            ScalingHistoryEntity                              │   │
│  │                                                              │   │
│  │  Ports (interfaces): ScalingPolicyRepository,                │   │
│  │    AppBindingRepository, CustomMetricRepository,             │   │
│  │    ScalingHistoryRepository                                  │   │
│  │                                                              │   │
│  │  Domain Service: ScalingEvaluatorService                     │   │
│  └────────────────────────────┬─────────────────────────────────┘   │
│                               │ implemented by                      │
│  ┌────────────────────────────▼─────────────────────────────────┐   │
│  │  INFRASTRUCTURE LAYER (Driven Adapters)                      │   │
│  │                                                              │   │
│  │  MemoryScalingPolicyRepository                               │   │
│  │  MemoryAppBindingRepository                                  │   │
│  │  MemoryCustomMetricRepository                                │   │
│  │  MemoryScalingHistoryRepository                              │   │
│  │  Container (DI) · SrvConfig · loadConfig()                  │   │
│  └──────────────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Class Diagram — Domain

```
ScalingPolicyEntity
  + id: PolicyId
  + appId: AppBindingId
  + tenantId: TenantId
  + instanceMinCount: int
  + instanceMaxCount: int
  + status: PolicyStatus
  + timezone: string
  + customMetricAllowFrom: MetricAllowFrom
  + scalingRules: ScalingRuleEntity[]
  + recurringSchedules: RecurringScheduleEntity[]
  + specificDateSchedules: SpecificDateScheduleEntity[]
  + createdAt / updatedAt: long
  + toJson(): Json

ScalingRuleEntity
  + id: ScalingRuleId
  + metricType: MetricType
  + customMetricName: string
  + threshold: int
  + operator: ScalingOperator
  + breachDurationSecs: int
  + coolDownSecs: int
  + adjustment: string
  + toJson(): Json

RecurringScheduleEntity
  + id / startTime / endTime / startDate / endDate: string
  + daysOfWeek: int[] | daysOfMonth: int[]
  + instanceMinCount / instanceMaxCount / initialMinInstanceCount: int

SpecificDateScheduleEntity
  + id / startDateTime / endDateTime: string
  + instanceMinCount / instanceMaxCount / initialMinInstanceCount: int

AppBindingEntity
  + id / tenantId / appGuid / appName / serviceInstanceId: string
  + policyId: PolicyId
  + currentInstances: int
  + boundAt / updatedAt: long

CustomMetricEntity
  + id / appId / metricName / unit: string
  + value: double
  + timestamp: long

ScalingHistoryEntity
  + id / appId / tenantId: string
  + direction: ScalingDirection
  + status: ScalingStatus
  + reason / message: string
  + oldInstances / newInstances: int
  + timestamp: long
```

---

## Sequence Diagram — Scaling Trigger Flow

```
Client              ScalingEngineController      ScalingEngineUseCase
  |                          |                           |
  |  POST /scaling/trigger   |                           |
  |─────────────────────────>|                           |
  |                          |  triggerScaling(req)      |
  |                          |──────────────────────────>|
  |                          |                           | findByAppGuid()
  |                          |                           |──────> BindingRepo
  |                          |                           | findById(policyId)
  |                          |                           |──────> PolicyRepo
  |                          |                           | evaluate(policy, metric, value, instances)
  |                          |                           |──────> ScalingEvaluatorService
  |                          |                           | save(ScalingHistoryEntity)
  |                          |                           |──────> HistoryRepo
  |                          |                           | update(binding.currentInstances)
  |                          |                           |──────> BindingRepo
  |                          |  CommandResult(id)        |
  |                          |<──────────────────────────|
  |  200 { scaling_history_id }
  |<─────────────────────────|
```

---

## Sequence Diagram — Policy CRUD

```
Client              ScalingPolicyController     ManageScalingPoliciesUseCase    PolicyRepo
  |  POST /policies        |                              |                         |
  |───────────────────────>|                              |                         |
  |                        |  createPolicy(request)       |                         |
  |                        |─────────────────────────────>|                         |
  |                        |                              |  save(policy)            |
  |                        |                              |────────────────────────>|
  |                        |  CommandResult(id)           |                         |
  |                        |<─────────────────────────────|                         |
  |  201 { id }            |
  |<───────────────────────|
```

---

## Enum Reference

| Enum             | Values                                                                     |
|------------------|----------------------------------------------------------------------------|
| `MetricType`     | memoryused, memoryutil, cpu, cpuutil, disk, diskutil, throughput, responsetime, custom_ |
| `ScalingOperator`| lt (<), gt (>), lte (<=), gte (>=)                                        |
| `ScalingDirection`| scaleOut, scaleIn, none                                                   |
| `ScalingStatus`  | succeeded, failed, ignored                                                 |
| `PolicyStatus`   | active, inactive, deleted_                                                 |
| `MetricAllowFrom`| sameApp, boundApp                                                          |
