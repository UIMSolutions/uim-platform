# NAF v4 Architecture Description — Solution Lifecycle Management Service

## NCV — Capability Taxonomy

| ID | Capability | Description |
|---|---|---|
| C1 | Solution Package Management | Upload, validate, list, and delete MTA archive (.mtar) files |
| C1.1 | Archive Upload | Register MTA archive metadata and checksum for deployment |
| C1.2 | Archive Validation | Validate MTA descriptor (mtaId, version, target platforms) |
| C1.3 | Archive Deletion | Remove obsolete or superseded MTA archives |
| C2 | Solution Deployment | Deploy, update, and delete MTA solutions on target platforms |
| C2.1 | Standard Deployment | Deploy a solution available only within the deploying subaccount |
| C2.2 | Provided Deployment | Deploy a solution and expose it for subscription by other subaccounts |
| C2.3 | Solution Update | Re-deploy an existing solution from a new MTA archive version |
| C2.4 | Solution Deletion | Asynchronously undeploy and clean up a deployed solution |
| C3 | Subscription Lifecycle | Allow subaccounts to subscribe and unsubscribe to provided solutions |
| C3.1 | Subscribe | Subscribe a tenant to a provided solution |
| C3.2 | Unsubscribe | Revoke a subscription and clean up subscriber-side resources |
| C4 | Operation Tracking | Track and observe all long-running async operations |
| C4.1 | Operation Polling | Query operation progress and status |
| C4.2 | Operation Abort | Cancel a queued or running operation |
| C4.3 | Operation Logs | Retrieve streaming build/deploy log output |
| C5 | Extension Descriptor Support | Apply YAML extension descriptors to customise deployments per environment |
| C6 | Multi-Tenancy | All data strictly isolated per tenant via X-Tenant-Id header |
| C7 | Health Monitoring | Liveness/readiness probe for container orchestration |

---

## NSOV-1 — Service Overview

**Service Name:** Solution Lifecycle Management Service  
**Version:** 1.0.0  
**Port:** 8097  
**Protocol:** HTTP/1.1 REST JSON  
**Authentication:** Bearer token (X-Tenant-Id header for tenant scoping)  
**Classification:** Platform Service — MTA Deployment Infrastructure  

**Purpose:**  
Provides the full lifecycle management for Multi-Target Applications (MTA) packaged as `.mtar` archives. Supports deploy, update, subscribe, unsubscribe, and delete operations with async tracking and log streaming.

---

## NSOV-2 — Service Definitions

| Service ID | Name | Path Prefix | Capabilities |
|---|---|---|---|
| SLM-S01 | MTA Archive Service | `POST/GET/DELETE /api/v1/slm/mta-archives` | C1 |
| SLM-S02 | MTA Deploy Service | `POST /api/v1/slm/mtas` | C2.1, C2.2, C5 |
| SLM-S03 | MTA Update Service | `PUT /api/v1/slm/mtas/{id}` | C2.3, C5 |
| SLM-S04 | MTA Query Service | `GET /api/v1/slm/mtas, GET /api/v1/slm/mtas/{id}` | C2 |
| SLM-S05 | MTA Delete Service | `DELETE /api/v1/slm/mtas/{id}` | C2.4 |
| SLM-S06 | Operation Query Service | `GET /api/v1/slm/operations{,/*}` | C4.1 |
| SLM-S07 | Operation Poll Service | `POST /api/v1/slm/operations/{id}/poll` | C4.1 |
| SLM-S08 | Operation Abort Service | `POST /api/v1/slm/operations/{id}/abort` | C4.2 |
| SLM-S09 | Operation Log Service | `GET /api/v1/slm/operations/{id}/logs` | C4.3 |
| SLM-S10 | Subscription Service | `GET/POST /api/v1/slm/subscriptions` | C3.1, C6 |
| SLM-S11 | Unsubscription Service | `DELETE /api/v1/slm/subscriptions/{id}` | C3.2, C6 |
| SLM-S12 | Health Service | `GET /api/v1/health` | C7 |

---

## NOV — Operational Node Connectivity

```
┌──────────────────────────────────────────────────────────────────────────┐
│                     SAP BTP / Kubernetes Cluster                         │
│                                                                          │
│  ┌──────────────┐       REST/JSON        ┌───────────────────────────┐  │
│  │  Developer / │ ─────────────────────► │  SLM Service :8097        │  │
│  │  CI Pipeline │                        │  (uim-solution-lifecycle) │  │
│  └──────────────┘                        │                           │  │
│                                          │  ┌─────────────────────┐  │  │
│  ┌──────────────┐       REST/JSON        │  │ MtaArchiveController │  │  │
│  │  SAP BTP     │ ─────────────────────► │  │ MtaController        │  │  │
│  │  Cockpit     │                        │  │ MtaOperationCtrl     │  │  │
│  └──────────────┘                        │  │ MtaSubscriptionCtrl  │  │  │
│                                          │  └─────────────────────┘  │  │
│  ┌──────────────┐    Subscribe/Consume   │                           │  │
│  │  Subscriber  │ ─────────────────────► │  Domain: MtaArchive       │  │
│  │  Subaccount  │                        │         Mta               │  │
│  └──────────────┘                        │         MtaOperation      │  │
│                                          │         MtaSubscription   │  │
│  ┌──────────────┐    Health Probe        │                           │  │
│  │  k8s kubelet │ ─────────────────────► │  GET /api/v1/health       │  │
│  └──────────────┘                        └───────────────────────────┘  │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## NLV — Logical Data Model

### MtaArchive

| Field | Type | Description |
|---|---|---|
| id | MtaArchiveId (string) | Unique record ID |
| tenantId | string | Owning tenant |
| fileName | string | Original `.mtar` file name |
| mtaId | string | MTA application ID from descriptor |
| mtaVersion | string | Semantic version from descriptor |
| fileSizeBytes | long | Archive size in bytes |
| checksum | string | SHA-256 integrity hash |
| uploadedBy | string | User/service account |
| namespace_ | string | Optional MTA namespace |
| targetPlatforms | string[] | e.g. `["CF", "NEO"]` |
| validated | bool | Descriptor validation passed |
| createdAt | long | Unix timestamp (ticks) |
| updatedAt | long | Unix timestamp (ticks) |

### Mta (Deployed Solution)

| Field | Type | Description |
|---|---|---|
| id | MtaId (string) | Unique record ID |
| tenantId | string | Owning tenant |
| mtaId | string | MTA application ID |
| version_ | string | Deployed version |
| description | string | Solution description |
| solutionType | SolutionType | `standard`, `provided`, `subscribed` |
| status | MtaStatus | `deploying`, `deployed`, `updating`, `deleting`, `failed`, `deleted` |
| archiveId | string | Source archive reference |
| deployedBy | string | Initiating user |
| spaceId | string | Target CF space / subaccount |
| extensionDescriptor | string | Applied extension YAML |
| modules | MtaModule[] | Individual application/service modules |
| lastOperationId | string | Most recent operation ID |
| completedAt | long | Deployment completion timestamp |

### MtaModule (embedded in Mta)

| Field | Type | Description |
|---|---|---|
| name | string | Module name from descriptor |
| moduleType | ModuleType | Runtime type (java, nodejs, html5, etc.) |
| state | ModuleState | `started`, `stopped`, `starting`, `stopping`, `failed` |
| urls | string[] | Public URLs of the module |

### MtaOperation

| Field | Type | Description |
|---|---|---|
| id | MtaOperationId (string) | Unique operation ID |
| tenantId | string | Owning tenant |
| operationType | OperationType | `deploy`, `update`, `subscribe`, `unsubscribe`, `delete`, `abort` |
| operationStatus | OperationStatus | `queued`, `running`, `finished`, `failed`, `aborted` |
| mtaId | string | Affected MTA application ID |
| mtaVersion | string | Affected version |
| archiveId | string | Source archive (deploy/update only) |
| initiatedBy | string | User who triggered the operation |
| errorMessage | string | Error details (if failed) |
| progressMessage | string | Human-readable status message |
| progressPercent | int | 0–100 percent complete |
| logLines | string[] | Streaming log output lines |
| startedAt | long | Operation start timestamp |
| finishedAt | long | Operation completion timestamp |

### MtaSubscription

| Field | Type | Description |
|---|---|---|
| id | MtaSubscriptionId (string) | Unique record ID |
| tenantId | string | Subscriber tenant |
| mtaId | string | Provider solution MTA ID |
| mtaVersion | string | Subscribed version |
| providerTenantId | string | Provider tenant |
| providerSpaceId | string | Provider CF space |
| subscriptionStatus | SubscriptionStatus | `available`, `subscribing`, `subscribed`, `unsubscribing`, `failed` |
| subscribedBy | string | Initiating user |
| extensionDescriptor | string | Subscriber-specific extension YAML |
| lastOperationId | string | Most recent operation |
| subscribedAt | long | Subscription creation timestamp |
| unsubscribedAt | long | Unsubscription timestamp (if applicable) |

---

## NPV — Physical Deployment View

### Container Resources

| Resource | Value |
|---|---|
| Base Image (build) | `dlang2/ldc-ubuntu:1.40.1` |
| Base Image (runtime) | `ubuntu:24.04` |
| Binary | `uim-solution-lifecycle-platform-service` |
| Exposed Port | `8097/TCP` |
| Run as | Non-root `appuser` (UID 1000) |
| Read-only filesystem | Yes |

### Kubernetes Resources

| Resource | Kind | Description |
|---|---|---|
| `cloud-solution-lifecycle` | Deployment | Single replica, rolling update |
| `cloud-solution-lifecycle` | Service | ClusterIP on port 8097 |
| `solution-lifecycle-config` | ConfigMap | `SOLUTION_LIFECYCLE_HOST`, `SOLUTION_LIFECYCLE_PORT` |

### Resource Limits

| Resource | Request | Limit |
|---|---|---|
| Memory | 64 Mi | 256 Mi |
| CPU | 100 m | 500 m |

### Health Probes

| Probe | Path | Initial Delay | Period |
|---|---|---|---|
| Liveness | `GET /api/v1/health` | 10 s | 30 s |
| Readiness | `GET /api/v1/health` | 5 s | 10 s |

---

## NIV — Information (Interface) View

### REST Contract Shapes

**Upload MTA Archive — POST /api/v1/slm/mta-archives**
```json
Request:  { "fileName": "app.mtar", "mtaId": "com.example.app", "mtaVersion": "1.0.0",
            "fileSizeBytes": 204800, "checksum": "sha256:...", "uploadedBy": "user",
            "namespace": "", "targetPlatforms": ["CF"] }
Response: 201 { "id": "<uuid>", "message": "MTA archive registered" }
```

**Deploy MTA — POST /api/v1/slm/mtas**
```json
Request:  { "archiveId": "<archive-id>", "solutionType": "standard",
            "spaceId": "my-space", "deployedBy": "user",
            "namespace": "", "extensionDescriptor": "" }
Response: 202 { "operationId": "op-tenant-123456", "message": "Deploy operation started" }
```

**Poll Operation — POST /api/v1/slm/operations/{id}/poll**
```json
Request:  (empty body)
Response: 200 { "id": "op-...", "operationStatus": "running",
                "progressPercent": 50, "progressMessage": "In progress",
                "mtaId": "com.example.app", "operationType": "deploy" }
```

**Subscribe — POST /api/v1/slm/subscriptions**
```json
Request:  { "providerMtaId": "com.example.provider", "providerTenantId": "prov-001",
            "providerSpaceId": "prov-space", "subscribedBy": "user",
            "extensionDescriptor": "" }
Response: 202 { "operationId": "op-sub-123456", "message": "Subscribe operation started" }
```

### Error Envelope
```json
{ "error": "MTA archive not found: <id>", "status": 404 }
```

### HTTP Headers

| Header | Direction | Description |
|---|---|---|
| `X-Tenant-Id` | Request | Required; isolates data per tenant |
| `Content-Type: application/json` | Request | Required for POST/PUT |
| `Accept: application/json` | Request | Recommended |
