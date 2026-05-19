# NAFv4 Architecture — Responsibility Management Service

## NV-1: Overview

The **Responsibility Management Service** is a tenant-scoped microservice that provides RACI-based agent determination for business processes. It is deployed as a containerised workload within the UIM Platform, co-located with other BTP-analogous platform services.

**Operational Node**: UIM Platform Kubernetes Cluster  
**Service Port**: 8118  
**Protocol**: HTTP/REST (JSON)

---

## NV-2: Node Connectivity

```
┌─────────────────────────────────────────────────────┐
│               UIM Platform K8s Cluster              │
│                                                     │
│  ┌──────────────────────────────────────────────┐   │
│  │    responsibility (ClusterIP :8118)          │   │
│  │    uim-responsibility-platform-service       │   │
│  └───────────┬──────────────────────────────────┘   │
│              │ X-Tenant-Id (header)                 │
│              │ POST /api/v1/responsibility/determine │
│  ┌───────────▼──────────────────────────────────┐   │
│  │    BTP-analog consumer services              │   │
│  │    (automation-pilot, process-automation…)   │   │
│  └──────────────────────────────────────────────┘   │
│                                                     │
│  ┌──────────────────────────────────────────────┐   │
│  │    identity-authentication / oauth           │   │
│  │    (tenant context validation)               │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

---

## NV-3: System Context

The service fulfils the same role as the **SAP Responsibility Management service** on SAP BTP:
- Consumers call the `/determine` endpoint with a business object reference
- The service resolves which team members are responsible/accountable
- A DeterminationLog is persisted for every call (audit trail)

---

## NV-4: Standards

| Standard       | Usage                                                     |
|----------------|-----------------------------------------------------------|
| REST / JSON    | HTTP API contract                                         |
| RACI model     | MemberRole enum: responsible, accountable, consulted, informed |
| Clean Architecture | Domain → Application → Infrastructure/Presentation  |
| Hexagonal Architecture | Domain ports (repository interfaces) with infra adapters |
| OpenAPI 3.0    | API documentation target (not yet generated)             |
| OCI            | Container image (Docker / Podman compatible)             |

---

## NV-5: Service Responsibilities

| Responsibility              | Owner                                    |
|-----------------------------|------------------------------------------|
| Team/Member management      | ManageTeamsUseCase, ManageTeamMembersUseCase |
| Agent determination logic   | AgentDeterminator (domain service)       |
| Audit trail                 | DetermineAgentsUseCase → DeterminationLogRepository |
| Context/Rule management     | ManageResponsibilityContextsUseCase, ManageResponsibilityRulesUseCase |
| Definition/Scope management | ManageResponsibilityDefinitionsUseCase   |
| HTTP routing                | URLRouter (vibe.d) + 10 Controllers      |
| Configuration               | SrvConfig (env: RESPONSIBILITY_HOST/PORT)|

---

## NV-6: Information Exchange

| Exchange           | Direction          | Format     | Path                                    |
|--------------------|--------------------|------------|-----------------------------------------|
| Determine agents   | Consumer → Service | JSON POST  | `/api/v1/responsibility/determine`      |
| CRUD resources     | Admin → Service    | JSON REST  | `/api/v1/responsibility/*`              |
| Health check       | K8s → Service      | HTTP GET   | `/health`                               |

---

## NV-7: Logical Data Model

Core aggregates:
- **TeamCategory** ← **TeamType** ← **Team** ← **TeamMember** ← **MemberFunction**
- **ResponsibilityContext** ← **ResponsibilityRule**
- **ResponsibilityDefinition** (joins Context + Rule + Team)
- **DeterminationLog** (audit record per determination call)

---

## NV-8: Deployment View

```yaml
# Kubernetes resources
Namespace:  uim-platform
Deployment: responsibility  (replicas: 1)
Service:    responsibility  (ClusterIP: 8118)
ConfigMap:  responsibility-config
  RESPONSIBILITY_HOST: 0.0.0.0
  RESPONSIBILITY_PORT: "8118"
```

Container image: `uim-platform/responsibility:latest`  
Base OS: Alpine 3.20  
Runtime: LDC-compiled D binary (statically linked musl)
