# Task Center Service - NATO Architecture Framework v4 (NAFv4)

## 1. Concepts (C1 - Capability Taxonomy)

### 1.1 Service Purpose

The Task Center Service provides a **unified task federation and processing** capability for enterprise environments. It aggregates tasks from multiple heterogeneous source systems into a single inbox, enabling efficient task management across organizational boundaries.

### 1.2 Capability Taxonomy

| Capability ID | Capability Name | Description |
|--------------|----------------|-------------|
| C-TC-001 | Task Federation | Aggregate tasks from multiple provider systems into unified cache |
| C-TC-002 | Task Processing | Execute task actions (approve, reject, forward, claim, release, escalate) |
| C-TC-003 | Task Definition Management | Define and manage task types, categories, and schemas |
| C-TC-004 | Provider Connectivity | Register and manage connections to source task systems |
| C-TC-005 | Substitution Management | Configure delegation rules for task handling during absences |
| C-TC-006 | Task Collaboration | Enable comments and attachments on tasks |
| C-TC-007 | Action Audit Trail | Track all task actions for compliance and traceability |
| C-TC-008 | Filter Management | Personal saved filter configurations for task retrieval |
| C-TC-009 | Health Monitoring | Runtime health and readiness probing |

## 2. Service Specification (S1 - Service Taxonomy)

### 2.1 Service Interfaces

| Interface | Protocol | Base Path | Description |
|-----------|----------|-----------|-------------|
| Task API | REST/HTTP | `/api/v1/task-center/tasks` | CRUD + lifecycle actions for tasks |
| Definition API | REST/HTTP | `/api/v1/task-center/definitions` | Task type management |
| Provider API | REST/HTTP | `/api/v1/task-center/providers` | Source system connector management |
| Comment API | REST/HTTP | `/api/v1/task-center/comments` | Task commenting |
| Attachment API | REST/HTTP | `/api/v1/task-center/attachments` | Task attachment metadata |
| Substitution API | REST/HTTP | `/api/v1/task-center/substitutions` | Delegation rule management |
| Action API | REST/HTTP | `/api/v1/task-center/actions` | Task action audit log |
| Filter API | REST/HTTP | `/api/v1/task-center/filters` | Saved user filter management |
| Health API | REST/HTTP | `/health` | Liveness and readiness probe |

### 2.2 Service Qualities

| Quality Attribute | Target | Implementation |
|------------------|--------|----------------|
| Availability | 99.9% | Kubernetes liveness/readiness probes |
| Scalability | Horizontal | Stateless container design, replicas |
| Multi-tenancy | Full | X-Tenant-Id header isolation |
| Response Time | < 200ms | In-memory repository, vibe.d async I/O |
| Interoperability | REST/JSON | Standard HTTP methods and JSON payloads |

## 3. Operational Viewpoint (NOV - NATO Operational View)

### 3.1 Operational Node Connectivity (NOV-2)

```
+-------------------+       +-------------------+       +-------------------+
|   SAP S/4HANA     |       |  SAP SuccessFactors|       |    SAP Ariba      |
|   (Task Provider)  |       |  (Task Provider)   |       |  (Task Provider)  |
+--------+----------+       +--------+----------+       +--------+----------+
         |                           |                           |
         |    Task Federation        |    Task Federation        |
         v                           v                           v
+--------+---------------------------+---------------------------+----------+
|                        Task Center Service                                 |
|                                                                            |
|  +---------------+  +---------------+  +---------------+                   |
|  | Task Cache    |  | Provider Mgmt |  | Substitution  |                   |
|  | (Unified      |  | (Connector    |  | Mgmt (Deleg-  |                   |
|  |  Inbox)       |  |  Registry)    |  |  ation Rules) |                   |
|  +---------------+  +---------------+  +---------------+                   |
|                                                                            |
|  +---------------+  +---------------+  +---------------+                   |
|  | Action Audit  |  | Comments /    |  | Saved Filters |                   |
|  | (Compliance)  |  | Attachments   |  | (Personal)    |                   |
|  +---------------+  +---------------+  +---------------+                   |
+--------+------------------------------------------------------------------+
         |
         | REST API (JSON)
         v
+--------+----------+
|   End Users /     |
|   Applications    |
+-------------------+
```

### 3.2 Operational Activity (NOV-5)

| Activity | Input | Output | Actor |
|----------|-------|--------|-------|
| Browse Tasks | Filter criteria | Task list | End User |
| Process Task | Task ID + Action | Updated task | End User |
| Claim Task | Task ID + User | Reserved task | End User |
| Forward Task | Task ID + Target user | Forwarded task | End User |
| Register Provider | Provider config | Active connector | Admin |
| Sync Provider | Provider ID | Updated task cache | Admin / Scheduler |
| Configure Substitution | Rule parameters | Active delegation | End User |
| Review Audit | Task ID | Action history | Auditor |

## 4. Systems Viewpoint (NSV - NATO Systems View)

### 4.1 System Interface Description (NSV-1)

```
+-------------------------------------------------------------------+
|                    Task Center Microservice                        |
|                                                                    |
|   +-----------+    +-------------+    +-------------------+        |
|   | Presenta- |    | Application |    | Infrastructure    |        |
|   | tion      |--->| Layer       |--->| Layer             |        |
|   | Layer     |    |             |    |                   |        |
|   |           |    | Use Cases:  |    | - MemoryRepos     |        |
|   | 8 REST    |    | - Tasks     |    | - AppConfig       |        |
|   | Controllers    | - Defs      |    | - Container (DI)  |        |
|   |           |    | - Providers |    |                   |        |
|   |           |    | - Comments  |    +-------------------+        |
|   |           |    | - Attach.   |            |                    |
|   |           |    | - Substit.  |            v                    |
|   |           |    | - Actions   |    +-------------------+        |
|   |           |    | - Filters   |    | Domain Layer      |        |
|   +-----------+    +-------------+    | - Entities (8)    |        |
|                                       | - Repo Interfaces |        |
|                                       | - TaskValidator   |        |
|                                       | - Value Types     |        |
|                                       +-------------------+        |
+-------------------------------------------------------------------+
```

### 4.2 System Technology (NSV-2)

| Component | Technology | Version |
|-----------|-----------|---------|
| Language | D (dlang) | DMD/LDC |
| Web Framework | vibe.d | 0.10.x |
| Container Runtime | Docker / Podman | Latest |
| Orchestration | Kubernetes | 1.28+ |
| Build System | DUB | Latest |
| Base Image | Alpine Linux | 3.20 |

### 4.3 System Connectivity (NSV-6)

| From | To | Protocol | Port | Description |
|------|----|----------|------|-------------|
| Client | Task Center | HTTP/REST | 8103 | API requests |
| Kubernetes | Task Center | HTTP | 8103 | Health probes |
| Task Center | Task Providers | HTTP/REST | Varies | Task federation (future) |

## 5. Technical Standards (NTV - NATO Technical View)

### 5.1 Standards Profile (NTV-1)

| Category | Standard | Notes |
|----------|----------|-------|
| Architecture | Clean / Hexagonal Architecture | Ports and Adapters pattern |
| API Design | RESTful HTTP/JSON | Resource-oriented endpoints |
| Multi-tenancy | Header-based (X-Tenant-Id) | Tenant isolation at repository level |
| Authentication Types | OAuth2, Basic, Certificate, API Key, SAML | Provider auth schemes |
| Container | OCI Container Image | Docker/Podman compatible |
| Orchestration | Kubernetes Deployment | ConfigMap, Service, Deployment |
| Health Checks | Kubernetes probes (liveness/readiness) | /health endpoint |

### 5.2 Data Model Standards

| Entity | Key Fields | Lifecycle States |
|--------|-----------|-----------------|
| Task | tenantId, id, taskDefinitionId, providerId | open, inProgress, completed, cancelled, failed, forwarded, reserved |
| TaskDefinition | tenantId, id, providerId, name | isActive: true/false |
| TaskProvider | tenantId, id, providerType | active, inactive, error, syncing |
| SubstitutionRule | tenantId, id, userId, substituteId | active, inactive, expired, pending |
| TaskComment | tenantId, id, taskId, author | Created/Deleted |
| TaskAttachment | tenantId, id, taskId, fileName | uploaded, processing, available, deleted |
| TaskAction | tenantId, id, taskId, actionType | Immutable audit record |
| UserTaskFilter | tenantId, id, userId, name | isDefault: true/false |

## 6. Deployment View

### 6.1 Container Deployment

```
+----------------------------------+
|       Kubernetes Cluster          |
|                                   |
|  +-----------------------------+  |
|  |  Namespace: uim-platform    |  |
|  |                             |  |
|  |  +--------+ +-----------+  |  |
|  |  | Config | | Service   |  |  |
|  |  | Map    | | (ClusterIP|  |  |
|  |  |        | |  :8103)   |  |  |
|  |  +--------+ +-----+-----+  |  |
|  |                    |        |  |
|  |              +-----v-----+  |  |
|  |              | Deployment|  |  |
|  |              | (1+ pods) |  |  |
|  |              |           |  |  |
|  |              | Container:|  |  |
|  |              | task-     |  |  |
|  |              | center    |  |  |
|  |              | :8103     |  |  |
|  |              +-----------+  |  |
|  +-----------------------------+  |
+----------------------------------+
```

### 6.2 Build Pipeline

| Stage | Command | Artifact |
|-------|---------|----------|
| Compile | `dub build --compiler=ldc2 -b release` | Binary executable |
| Containerize | `docker build -t uim-platform/task-center:latest .` | OCI image |
| Deploy | `kubectl apply -f k8s/` | Kubernetes resources |

## 7. Information Exchange (NIV - NATO Information View)

### 7.1 Information Exchange Matrix

| Producer | Consumer | Information | Format | Frequency |
|----------|----------|-------------|--------|-----------|
| Task Providers | Task Center | Federated tasks | REST/JSON | On sync |
| End Users | Task Center | Task actions | REST/JSON | On demand |
| Task Center | End Users | Task lists, details | REST/JSON | On request |
| Admins | Task Center | Provider config | REST/JSON | As needed |
| Task Center | Auditors | Action audit trail | REST/JSON | On request |
| End Users | Task Center | Substitution rules | REST/JSON | As needed |
