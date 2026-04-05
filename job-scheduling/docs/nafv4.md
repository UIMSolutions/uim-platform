# NAF v4 Architecture Document

## Job Scheduling Service - UIM Platform

**Version:** 1.0
**Date:** 2026-04-05
**Classification:** UNCLASSIFIED
**Status:** Baseline

---

## 1. Architecture Context (NAF v4 Grid Reference)

This document maps the Job Scheduling Service architecture to the NATO Architecture Framework v4 viewpoints.

| NAF v4 View | Covered | Section |
|---|---|---|
| C1 - Capability Taxonomy | Yes | Section 2 |
| C2 - Enterprise Vision | Yes | Section 3 |
| S1 - Service Taxonomy | Yes | Section 4 |
| S3 - Service Interfaces | Yes | Section 5 |
| S4 - Service Functions | Yes | Section 6 |
| L2 - Logical Scenario | Yes | Section 7 |
| L4 - Logical Activities | Yes | Section 8 |
| L7 - Logical Data Model | Yes | Section 9 |
| P1 - Resource Types | Yes | Section 10 |
| P2 - Resource Structure | Yes | Section 11 |
| P4 - Resource Functions | Yes | Section 12 |
| Ar - Architecture Metadata | Yes | Section 13 |

---

## 2. C1 - Capability Taxonomy

### 2.1 Capability Overview

The Job Scheduling Service provides automated task scheduling and execution management capabilities for the UIM Cloud Platform.

### 2.2 Capability Hierarchy

```
C-ROOT: Cloud Platform Automation
├── C-JS-01: Job Lifecycle Management
│   ├── C-JS-01.1: Job Creation and Configuration
│   ├── C-JS-01.2: Job Retrieval and Search
│   ├── C-JS-01.3: Job Update and Reconfiguration
│   └── C-JS-01.4: Job Deletion and Cleanup
├── C-JS-02: Schedule Management
│   ├── C-JS-02.1: One-Time Schedule Definition
│   ├── C-JS-02.2: Recurring Schedule Definition (Cron)
│   ├── C-JS-02.3: Repeat Interval Scheduling
│   ├── C-JS-02.4: Human-Readable Schedule Formats
│   ├── C-JS-02.5: Bulk Schedule Activation/Deactivation
│   └── C-JS-02.6: Schedule Search (Cross-Job)
├── C-JS-03: Execution Monitoring
│   ├── C-JS-03.1: Run Log Tracking
│   ├── C-JS-03.2: Status Transition Management
│   ├── C-JS-03.3: Execution Duration Recording
│   └── C-JS-03.4: Asynchronous Status Callback
├── C-JS-04: Multi-Tenancy
│   ├── C-JS-04.1: Tenant Isolation
│   └── C-JS-04.2: Per-Tenant Configuration
└── C-JS-05: Operational Monitoring
    ├── C-JS-05.1: Health Check
    └── C-JS-05.2: Job Count Statistics
```

---

## 3. C2 - Enterprise Vision

### 3.1 Purpose Statement

Provide a runtime-agnostic, multi-tenant job scheduling service that enables applications on the UIM Cloud Platform to define, manage, and monitor one-time and recurring jobs through a uniform REST API.

### 3.2 Strategic Goals

| ID | Goal | Priority |
|----|------|----------|
| SG-01 | Enable flexible scheduling of HTTP endpoint invocations | High |
| SG-02 | Support both synchronous and asynchronous job execution | High |
| SG-03 | Provide complete execution audit trail via run logs | Medium |
| SG-04 | Ensure tenant data isolation in multi-tenant deployments | High |
| SG-05 | Cloud-native deployment (Docker, Podman, Kubernetes) | High |
| SG-06 | Minimal resource footprint (< 256Mi memory limit) | Medium |

### 3.3 Key Constraints

| ID | Constraint |
|----|-----------|
| CON-01 | All timestamps in UTC |
| CON-02 | POST request body size limited to 100 KB |
| CON-03 | Tenant identification via X-Tenant-Id HTTP header |
| CON-04 | In-memory persistence (no external database dependency for MVP) |

---

## 4. S1 - Service Taxonomy

### 4.1 Service Inventory

```
SVC-ROOT: Job Scheduling Platform Service
├── SVC-JS-01: Job Management Service
│   ├── Create Job (with optional inline schedules)
│   ├── Retrieve Job (by ID)
│   ├── Retrieve All Jobs (by tenant)
│   ├── Update Job (by ID)
│   ├── Delete Job (cascade delete schedules)
│   ├── Count Jobs (active/inactive/total)
│   └── Search Jobs (by query)
├── SVC-JS-02: Schedule Management Service
│   ├── Create Schedule (for a job)
│   ├── Retrieve Schedule (by ID)
│   ├── Retrieve All Schedules (for a job)
│   ├── Update Schedule
│   ├── Delete Schedule
│   ├── Activate/Deactivate All Schedules
│   └── Search Schedules (cross-job)
├── SVC-JS-03: Run Log Service
│   ├── Retrieve Run Logs (by job)
│   ├── Retrieve Run Logs (by schedule)
│   └── Update Run Log Status (async callback)
├── SVC-JS-04: Configuration Service
│   ├── Retrieve Global Parameters
│   └── Update Global Parameters
└── SVC-JS-05: Health Service
    └── Health Check
```

---

## 5. S3 - Service Interfaces

### 5.1 REST API Interface Specification

**Base URL:** `/api/v1/scheduler`
**Protocol:** HTTP/1.1
**Content-Type:** application/json
**Authentication:** X-Tenant-Id header (tenant identification)

#### 5.1.1 Job Endpoints

| Operation | Method | URI | Request | Response |
|-----------|--------|-----|---------|----------|
| Create Job | POST | `/jobs` | CreateJobRequest | 201 {id, message} |
| List Jobs | GET | `/jobs` | - | 200 {total, results[]} |
| Get Job | GET | `/jobs/{jobId}` | - | 200 {Job} |
| Update Job | PUT | `/jobs/{jobId}` | UpdateJobRequest | 200 {id, message} |
| Delete Job | DELETE | `/jobs/{jobId}` | - | 204 |
| Count Jobs | GET | `/jobs/count` | - | 200 {total, active, inactive} |
| Search Jobs | GET | `/jobs/search?q=` | - | 200 {total, results[]} |

#### 5.1.2 Schedule Endpoints

| Operation | Method | URI | Request | Response |
|-----------|--------|-----|---------|----------|
| Create Schedule | POST | `/jobs/{jobId}/schedules` | CreateScheduleRequest | 201 {id, jobId, message} |
| List Schedules | GET | `/jobs/{jobId}/schedules` | - | 200 {total, results[]} |
| Get Schedule | GET | `/jobs/{jobId}/schedules/{scheduleId}` | - | 200 {Schedule} |
| Update Schedule | PUT | `/jobs/{jobId}/schedules/{scheduleId}` | UpdateScheduleRequest | 200 {id, message} |
| Delete Schedule | DELETE | `/jobs/{jobId}/schedules/{scheduleId}` | - | 204 |
| Activate All | PUT | `/jobs/{jobId}/schedules/activate` | {active: bool} | 200 {message} |
| Search Schedules | GET | `/schedules/search?q=` | - | 200 {total, results[]} |

#### 5.1.3 Run Log Endpoints

| Operation | Method | URI | Request | Response |
|-----------|--------|-----|---------|----------|
| Logs by Job | GET | `/jobs/{jobId}/runLogs` | - | 200 {total, results[]} |
| Logs by Schedule | GET | `/jobs/{jobId}/schedules/{scheduleId}/runLogs` | - | 200 {total, results[]} |
| Update Status | PUT | `/jobs/{jobId}/runLogs/{runLogId}` | UpdateRunLogRequest | 200 {id, message} |

#### 5.1.4 Configuration Endpoints

| Operation | Method | URI | Request | Response |
|-----------|--------|-----|---------|----------|
| Get Config | GET | `/configuration` | - | 200 {Configuration} |
| Update Config | PUT | `/configuration` | UpdateConfigurationRequest | 200 {message} |

#### 5.1.5 Health Endpoint

| Operation | Method | URI | Response |
|-----------|--------|-----|----------|
| Health Check | GET | `/api/v1/health` | 200 {status, service} |

### 5.2 Error Response Format

```json
{
  "error": {
    "message": "Human-readable error description",
    "code": 400
  }
}
```

### 5.3 Request Headers

| Header | Required | Description |
|--------|----------|-------------|
| X-Tenant-Id | Yes | Tenant identifier for multi-tenancy |
| Content-Type | For POST/PUT | application/json |

---

## 6. S4 - Service Functions

### 6.1 Functional Decomposition

```
F-JS-01: Job Management
  F-JS-01.1: Validate job input (name required, actionUrl for HTTP jobs)
  F-JS-01.2: Generate unique job ID (UUID v4)
  F-JS-01.3: Persist job entity with timestamps
  F-JS-01.4: Cascade delete schedules on job deletion
  F-JS-01.5: Search jobs by name/description substring match

F-JS-02: Schedule Management
  F-JS-02.1: Validate cron expression (5-part format)
  F-JS-02.2: Support multiple schedule formats
  F-JS-02.3: Bulk toggle schedule active status
  F-JS-02.4: Cross-job schedule search

F-JS-03: Execution Tracking
  F-JS-03.1: Enforce valid status transitions
  F-JS-03.2: Record timestamps at each lifecycle stage
  F-JS-03.3: Calculate execution duration

F-JS-04: Configuration Management
  F-JS-04.1: Provide sensible defaults when no config exists
  F-JS-04.2: Create-or-update semantics (upsert)
```

---

## 7. L2 - Logical Scenario

### 7.1 Primary Scenarios

#### Scenario 1: Job Creation with Schedules

```
1. Client sends POST /api/v1/scheduler/jobs with job data and inline schedules
2. JobController parses request, extracts tenant ID from header
3. ManageJobsUseCase validates input and creates Job entity
4. Job is persisted via JobRepository port
5. For each inline schedule: ManageSchedulesUseCase creates Schedule entity
6. Each Schedule is persisted via ScheduleRepository port
7. 201 Created response returned with job ID
```

#### Scenario 2: Schedule Execution Tracking

```
1. Scheduler engine triggers a schedule (creates RunLog with "scheduled" status)
2. Job action endpoint is invoked (status transitions to "triggered" then "running")
3. On completion: status set to "completed" with duration recorded
4. On failure: status set to "failed" with error message
5. If max retries exceeded: status transitions to "deadLettered"
```

#### Scenario 3: Bulk Schedule Management

```
1. Client sends PUT /api/v1/scheduler/jobs/{id}/schedules/activate with {active: false}
2. ScheduleController extracts job ID and tenant ID
3. ManageSchedulesUseCase retrieves all schedules for the job
4. Each schedule's active flag and status are updated
5. All schedules persisted via ScheduleRepository
6. Confirmation response returned
```

---

## 8. L4 - Logical Activities

### 8.1 Job Creation Activity Flow

```
[Start] --> (Receive HTTP Request)
          --> (Parse JSON Body)
          --> (Extract Tenant ID from Header)
          --> <Validate Input?>
          -- invalid --> (Return 400 Error) --> [End]
          -- valid --> (Generate UUID)
          --> (Build Job Entity)
          --> (Set Timestamps)
          --> (Persist to Repository)
          --> <Has Inline Schedules?>
          -- no --> (Return 201 Created) --> [End]
          -- yes --> (For Each Schedule)
              --> (Validate Cron if Provided)
              --> (Build Schedule Entity)
              --> (Persist Schedule)
              --> (Loop or Continue)
          --> (Return 201 Created) --> [End]
```

### 8.2 Run Status Transition Activity

```
[Scheduled] --trigger--> [Triggered]
[Triggered] --invoke-->  [Running]
[Running]   --success--> [Completed]   (terminal)
[Running]   --error-->   [Failed]
[Failed]    --exhaust--> [DeadLettered] (terminal)
```

---

## 9. L7 - Logical Data Model

### 9.1 Entity Relationship Model

```
┌──────────────────────────┐    1     ┌──────────────────────────────┐
│         Job              │────┬────│         Schedule              │
├──────────────────────────┤    │    ├──────────────────────────────┤
│ PK  id: JobId            │    │    │ PK  id: ScheduleId           │
│     tenantId: TenantId   │    │    │ FK  jobId: JobId             │
│     name: string         │    │    │     tenantId: TenantId       │
│     description: string  │    │    │     description: string      │
│     actionUrl: string    │    │    │     type: ScheduleType       │
│     httpMethod: enum     │    │    │     format: ScheduleFormat   │
│     type: JobType        │    │    │     status: ScheduleStatus   │
│     status: JobStatus    │    │    │     active: bool             │
│     active: bool         │    │    │     cronExpression: string   │
│     startTime: long      │    │    │     humanReadable: string    │
│     endTime: long        │    │    │     repeatInterval: long     │
│     createdAt: long      │    0..* │     repeatAt: string         │
│     modifiedAt: long     │         │     time: string             │
└──────────────────────────┘         │     startTime: long          │
                                     │     endTime: long            │
                                     │     nextRunAt: long          │
                                     │     createdAt: long          │
                                     │     modifiedAt: long         │
                                     └──────────┬───────────────────┘
                                           1    │
                                                │    0..*
                                     ┌──────────┴───────────────────┐
                                     │         RunLog               │
                                     ├──────────────────────────────┤
                                     │ PK  id: RunLogId             │
                                     │ FK  scheduleId: ScheduleId   │
                                     │ FK  jobId: JobId             │
                                     │     tenantId: TenantId       │
                                     │     status: RunStatus        │
                                     │     statusMessage: string    │
                                     │     httpStatus: int          │
                                     │     scheduledAt: long        │
                                     │     triggeredAt: long        │
                                     │     completedAt: long        │
                                     │     executionDurationMs: long│
                                     │     createdAt: long          │
                                     └──────────────────────────────┘

┌──────────────────────────────┐
│      Configuration           │
├──────────────────────────────┤
│ PK  id: ConfigId             │
│     tenantId: TenantId       │
│     defaultRetries: int      │
│     defaultRetryDelayMs: long│
│     maxRunDurationMs: long   │
│     enableAsyncMode: bool    │
│     enableAlertNotifications │
│     createdAt: long          │
│     modifiedAt: long         │
└──────────────────────────────┘
```

### 9.2 Data Dictionary

| Entity | Attribute | Type | Description |
|--------|-----------|------|-------------|
| Job | id | UUID string | Unique job identifier |
| Job | tenantId | string | Owning tenant |
| Job | name | string | Human-readable job name |
| Job | actionUrl | string | HTTP endpoint to invoke |
| Job | httpMethod | enum | GET, POST, PUT, DELETE, PATCH |
| Job | type | enum | httpEndpoint, cloudFoundryTask |
| Job | status | enum | active, inactive |
| Schedule | cronExpression | string | 5-part cron (min hour dom month dow) |
| Schedule | repeatInterval | long | Seconds between executions |
| Schedule | repeatAt | string | Time-of-day for repeat |
| Schedule | format | enum | cron, humanReadable, repeatInterval, repeatAt |
| RunLog | status | enum | scheduled, triggered, running, completed, failed, deadLettered |
| RunLog | executionDurationMs | long | Wall-clock execution time in milliseconds |
| Configuration | defaultRetries | int | Max retry attempts per run |
| Configuration | maxRunDurationMs | long | Timeout for job execution |

---

## 10. P1 - Resource Types

### 10.1 Software Resources

| Resource | Type | Version | Purpose |
|----------|------|---------|---------|
| D Language (DMD/LDC) | Runtime | LDC 1.40.1 | Primary language |
| vibe-d | Framework | 0.10.3 | HTTP server, routing, JSON |
| uim-framework | Library | 26.3.5 | Platform base classes |
| uim-platform:service | Library | internal | Shared service base (SAPController, UIMUseCase) |

### 10.2 Infrastructure Resources

| Resource | Type | Purpose |
|----------|------|---------|
| Ubuntu 24.04 | OS | Runtime container base |
| Docker / Podman | Container | Build and run |
| Kubernetes | Orchestrator | Production deployment |

---

## 11. P2 - Resource Structure

### 11.1 Source Code Structure

```
job-scheduling/
├── dub.sdl                                    # Build configuration
├── Dockerfile                                 # Docker multi-stage build
├── Containerfile                              # Podman build
├── README.md                                  # Usage documentation
├── k8s/                                       # Kubernetes manifests
│   ├── deployment.yaml
│   ├── service.yaml
│   └── configmap.yaml
├── docs/                                      # Architecture documentation
│   ├── architecture.puml                      # UML diagrams (PlantUML)
│   └── nafv4.md                               # This document
└── source/
    ├── app.d                                  # Entry point
    └── uim/platform/job_scheduling/
        ├── package.d                          # Root module re-exports
        ├── domain/                            # CORE (no external deps)
        │   ├── types.d                        # ID aliases, enums
        │   ├── entities/                      # Job, Schedule, RunLog, Configuration
        │   ├── ports/repositories/            # Interface contracts
        │   └── services/                      # Domain logic (validators, trackers)
        ├── application/                       # USE CASES
        │   ├── dto.d                          # Request/Response DTOs
        │   └── usecases/manage/               # ManageJobs/Schedules/RunLogs/Configurations
        ├── presentation/                      # DRIVING ADAPTERS
        │   └── http/
        │       ├── json_utils.d               # JSON extraction helpers
        │       └── controllers/               # HTTP route handlers
        └── infrastructure/                    # DRIVEN ADAPTERS
            ├── config.d                       # AppConfig + env loading
            ├── container.d                    # DI wiring
            └── persistence/memory/            # In-memory repository impls
```

### 11.2 Package Dependency Graph

```
app.d
 └── infrastructure/container.d (buildContainer)
      ├── infrastructure/persistence/memory/*  (MemoryXxxRepository)
      │    └── domain/ports/repositories/*     (interfaces)
      │         └── domain/entities/*          (structs)
      │              └── domain/types          (aliases, enums)
      ├── application/usecases/manage/*        (ManageXxxUseCase)
      │    ├── domain/ports/repositories/*
      │    ├── domain/services/*               (validators)
      │    └── application/dto                 (request/result DTOs)
      └── presentation/http/controllers/*      (XxxController)
           ├── application/usecases/*
           ├── application/dto
           └── presentation/http/json_utils
```

---

## 12. P4 - Resource Functions

### 12.1 Container Build Process

```
Stage 1: Builder (dlang2/ldc-ubuntu:1.40.1)
  1. Copy dub.sdl, dub.selections.json
  2. Copy source/
  3. dub build --build=release --config=defaultRun
  Output: build/uim-job-scheduling-platform-service

Stage 2: Runtime (ubuntu:24.04)
  1. Install ca-certificates, curl
  2. Create non-root appuser
  3. Copy binary from builder
  4. Expose port 8096
  5. Configure health check
  6. Run as appuser
```

### 12.2 Startup Sequence

```
1. loadConfig()          - Read JOB_SCHEDULING_HOST, JOB_SCHEDULING_PORT from env
2. buildContainer()      - Create repos -> use cases -> controllers (DI wiring)
3. new URLRouter()       - Initialize HTTP router
4. registerRoutes()      - Register all controller routes to router
5. listenHTTP()          - Bind to configured host:port
6. runApplication()      - Start vibe-d event loop
```

### 12.3 Kubernetes Deployment Parameters

| Parameter | Value |
|-----------|-------|
| Replicas | 1 |
| Container Port | 8096/TCP |
| Service Type | ClusterIP |
| Memory Request | 64Mi |
| Memory Limit | 256Mi |
| CPU Request | 100m |
| CPU Limit | 500m |
| Liveness Probe | GET /api/v1/health (period: 30s) |
| Readiness Probe | GET /api/v1/health (period: 10s) |
| Security | runAsNonRoot, readOnlyRootFilesystem, no privilege escalation |

---

## 13. Ar - Architecture Metadata

| Field | Value |
|-------|-------|
| Architecture Name | Job Scheduling Service |
| Version | 1.0 |
| Framework | NAF v4 |
| Status | Baseline |
| Author | UIM Platform Team |
| Date Created | 2026-04-05 |
| Classification | UNCLASSIFIED |
| Platform | UIM Cloud Platform |
| Repository | UIMSolutions/uim-platform |
| Subpackage | job-scheduling |
| Language | D (dlang) |
| Framework | vibe-d 0.10.3 + uim-framework 26.3.5 |
| Architecture Style | Hexagonal (Ports and Adapters) + Clean Architecture |
| Deployment | Docker / Podman / Kubernetes |
